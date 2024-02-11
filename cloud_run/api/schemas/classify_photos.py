# Standard Library
import logging
import os
import tempfile
import uuid
from datetime import datetime
from typing import Any, Dict, Optional, Tuple

# Third Party Library
import numpy as np
import requests  # type: ignore
import tensorflow as tf  # type: ignore
from fastapi import FastAPI, HTTPException  # type: ignore
from google.cloud import storage  # type: ignore
from tensorflow.keras.preprocessing.image import (  # type: ignore
    img_to_array,
    load_img,
)

logging.basicConfig(level=logging.INFO)

app = FastAPI()

# Constants
MODEL_BUCKET_NAME = "model-jp-my-gourmet-image-classification-2023-08"
GCS_PREFIX = "photo-jp-my-gourmet-image-classification-2023-08"
PROJECT = "my-gourmet-160fb.appspot.com"


def get_photos_from_google_photo_api(
    access_token: str, page_size: int, next_page_token: Optional[str] = None
) -> Dict[str, Any]:
    logging.info(
        f"Fetching photos with pageSize={page_size} and nextPageToken={next_page_token}"
    )
    try:
        search_request_data = {"pageSize": page_size}
        if next_page_token:
            search_request_data["pageToken"] = next_page_token

        response = requests.post(
            "https://photoslibrary.googleapis.com/v1/mediaItems:search",
            headers={"Authorization": f"Bearer {access_token}"},
            json=search_request_data,
            timeout=10,
        )
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        logging.error(f"Request failed: {e}")
        return {}


def classify_image(
    url: str,
    interpreter: tf.lite.Interpreter,
    input_details: Any,
    output_details: Any,
    image_size: int = 224,
) -> Tuple[Optional[int], Optional[bytes]]:
    logging.info(f"Starting classification for image: {url}")
    try:
        response = requests.get(url)
        response.raise_for_status()
    except requests.RequestException as e:
        logging.error(f"Error fetching image: {e}")
        return None, None

    try:
        _, temp_local_path = tempfile.mkstemp()
        with open(temp_local_path, "wb") as f:
            f.write(response.content)

        img = load_img(temp_local_path, target_size=(image_size, image_size))
        x = img_to_array(img)
        x /= 255.0
        x = np.expand_dims(x, axis=0)

        interpreter.set_tensor(input_details[0]["index"], x)
        interpreter.invoke()

        result = interpreter.get_tensor(output_details[0]["index"])
        predicted = result.argmax()

        return predicted, response.content

    except Exception as e:
        logging.error(f"Error processing image: {e}")
        return None, None

    finally:
        if os.path.exists(temp_local_path):
            os.remove(temp_local_path)


def save_to_cloud_storage(
    content: bytes,
    filename: str,
    bucket: storage.Bucket,
    user_id: str,
) -> None:
    try:
        logging.info(f"Preparing to upload image to Cloud Storage: {filename}")
        prefix = f"{GCS_PREFIX}/{user_id}/"
        blob = bucket.blob(prefix + filename)
        blob.upload_from_string(content)
        logging.info(
            f"Successfully uploaded image to Cloud Storage: {filename}"
        )
    except Exception as e:
        logging.error(f"Failed to upload image to Cloud Storage: {e}")


def save_to_firestore(
    image_url: str,
    user_id: str,
    db,
) -> Tuple[bool, str]:
    logging.info(f"Preparing to save image URL to Firestore: {image_url}")
    try:
        # Firestoreに保存するデータを作成
        photo_data = {
            "createdAt": datetime.utcnow(),
            "updatedAt": datetime.utcnow(),
            "userId": user_id,
            "url": image_url,
            "otherUrls": [],
            "tags": [],
            "storeId": None,
            "areaStoreIds": [],
        }
        logging.info(f"Generated photo data for Firestore: {photo_data}")

        # Firestoreの`users`コレクションにデータを保存
        user_ref = db.collection("users").document(user_id)
        photo_id = str(uuid.uuid4())
        logging.info(f"Generated unique photo ID: {photo_id}")

        user_ref.collection("photos").document(photo_id).set(photo_data)
        logging.info(f"Successfully saved image URL to Firestore: {image_url}")
        return True, "Firestore update successful"
    except Exception as e:
        logging.error(f"An error occurred while saving to Firestore: {e}")
        return False, str(e)


@app.post("/saveImage")
def save_image(
    user_id: str, access_token: str, db, storage_client
) -> Dict[str, str]:
    if not access_token:
        raise HTTPException(
            status_code=401,
            detail="アクセストークンが提供されていないか無効です",
        )

    if not user_id:
        raise HTTPException(
            status_code=400, detail="userIdが提供されていません"
        )
    logging.info(
        f"Processing saveImage request for user: {user_id} with accessToken: [REDACTED]"
    )
    image_size = 224

    bucket = storage_client.bucket(PROJECT)
    model_bucket = storage_client.bucket(MODEL_BUCKET_NAME)
    _, model_local_path = tempfile.mkstemp()
    blob_model = model_bucket.blob("gourmet_cnn_vgg_final.tflite")
    blob_model.download_to_filename(model_local_path)
    interpreter = tf.lite.Interpreter(model_path=model_local_path)
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    classes = [
        "ramen",
        "japanese_food",
        "international_cuisine",
        "cafe",
        "other",
    ]

    next_token: Optional[str] = None
    for _ in range(1):
        photos_data = get_photos_from_google_photo_api(
            access_token, page_size=50, next_page_token=next_token
        )
        if not photos_data.get("mediaItems"):
            logging.info("No mediaItems found in the response.")
            return {"message": "No media items found"}

        for photo in photos_data["mediaItems"]:
            if "screenshot" in photo["filename"].lower():
                continue  # スクリーンショットを含む画像を除外

            predicted, content = classify_image(
                photo["baseUrl"],
                interpreter,
                input_details,
                output_details,
                image_size,
            )
            # predictedがNoneでないことを確認してからリストをインデックス参照する
            if (
                predicted is not None
                and content
                and classes[predicted] in classes[:-1]
            ):  # "other" is excluded
                # GCSにアップロードし、そのパスを取得
                filename = photo["filename"]
                save_to_cloud_storage(content, filename, bucket, user_id)
                gcs_image_path = f"https://storage.cloud.google.com/{PROJECT}/{GCS_PREFIX}/{user_id}/{filename}"

                # Firestoreにパスを保存
                result, message = save_to_firestore(
                    gcs_image_path, user_id, db
                )
                if not result:
                    logging.error(message)
                    raise HTTPException(status_code=500, detail=message)

        next_token = photos_data.get("nextPageToken")
        if not next_token:
            break

    # Firestoreの更新ロジック
    users_ref = db.collection("users")
    user_doc_ref = users_ref.document(user_id)
    new_state = "readyForUse"
    user_doc_ref.update({"classifyPhotosStatus": new_state})
    return {"message": "正常に更新されました"}


def update_user_status(user_id: str, access_token: str, db):
    if not access_token:
        raise HTTPException(
            status_code=401,
            detail="アクセストークンが提供されていないか無効です",
        )

    if not user_id:
        raise HTTPException(
            status_code=400, detail="userIdが提供されていません"
        )

    # Firestoreの更新ロジック
    users_ref = db.collection("users")
    user_doc_ref = users_ref.document(user_id)
    new_state = "readyForUse"
    user_doc_ref.update({"classifyPhotosStatus": new_state})
    return {"message": "Successfully processed photos"}