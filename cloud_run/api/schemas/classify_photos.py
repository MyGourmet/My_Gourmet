# Standard Library
import logging
import os
import tempfile
import uuid
from datetime import datetime, timezone
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
# logging.basicConfig(level=logging.ERROR)


app = FastAPI()

# Constants
MODEL_BUCKET_NAME = "model-jp-my-gourmet-image-classification-2023-08"
GCS_PREFIX = "photo-jp-my-gourmet-image-classification-2023-08"
PROJECT = "my-gourmet-160fb.appspot.com"
READY_FOR_USE = "readyForUse"


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
        raise HTTPException(
            status_code=500,
            detail="Error fetching image: {e}",
        )

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
        raise HTTPException(
            status_code=500,
            detail="Error processing image: {e}",
        )

    finally:
        if os.path.exists(temp_local_path):
            os.remove(temp_local_path)


def save_to_cloud_storage(
    content: bytes,
    filename: str,
    bucket: storage.Bucket,
    user_id: str,
) -> str:
    try:
        logging.info(f"Preparing to upload image to Cloud Storage: {filename}")
        """Firebase Storageに画像をアップロードし、公開URLを取得する"""
        blob = bucket.blob(f"{GCS_PREFIX}/{user_id}/{filename}")
        blob.upload_from_string(content, content_type="image/jpeg")

        # ファイルを公開して、公開URLを取得
        blob.make_public()
        image_url = blob.public_url
        return image_url

    except Exception as e:
        logging.error(f"Failed to upload image to Cloud Storage: {e}")
        raise HTTPException(
            status_code=500,
            detail="An error occurred while saving to Firestore: {e}",
        )


def save_to_firestore(
    image_url: str,
    shot_at: datetime,
    user_id: str,
    db,
) -> Tuple[bool, str]:
    logging.info(f"Preparing to save image URL to Firestore: {image_url}")
    try:
        # Firestoreに保存するデータを作成
        photo_data = {
            "createdAt": datetime.utcnow(),
            "updatedAt": datetime.utcnow(),
            # "shotAt": shot_at,
            "userId": user_id,
            "url": image_url,
            "otherUrls": [],
            "tags": [],
            "storeId": None,
            "areaStoreIds": [],
        }

        # Firestoreの`users`コレクションにデータを保存
        user_ref = db.collection("users").document(user_id)
        doc_id = shot_at.strftime("%Y%m%d_%H%M%S")
        user_ref.collection("photos").document(doc_id).set(photo_data)

        return True, "Firestore update successful"
    except Exception as e:
        logging.error(f"An error occurred while saving to Firestore: {e}")
        raise HTTPException(
            status_code=500,
            detail="An error occurred while saving to Firestore: {e}",
        )


def get_latest_document_id(user_id: str, db) -> str:
    photos_ref = db.collection("users").document(user_id).collection("photos")
    # IDに基づいて最新のドキュメントを取得
    latest_photos = (
        photos_ref.order_by("__name__", direction="DESCENDING").limit(1).get()
    )
    latest_photo_id = latest_photos[0].id  # 最新のドキュメントIDを取得
    return latest_photo_id


# def get_latest_photo_datetime(user_id: str, db) -> datetime:
#     # ユーザーの最新の写真の情報を取得
#     photos_ref = db.collection("users").document(user_id).collection("photos")
#     # IDに基づいて最新のドキュメントを取得
#     latest_photos = (
#         photos_ref.order_by("__name__", direction="DESCENDING").limit(1).get()
#     )
#     latest_photo = list(latest_photos)

#     # 写真が存在する場合はそのタイムスタンプを、存在しない場合は現在時刻を使用
#     if latest_photo:
#         return latest_photo[0].to_dict()["createdAt"]
#     else:
#         # Firestoreのタイムスタンプはdatetimeオブジェクトとして取得されます
#         return datetime.now(timezone.utc)


# 以下の関数は、取得した最新のドキュメントIDから日時情報を抽出します
def extract_datetime_from_id(document_id: str) -> datetime:
    # ドキュメントIDから日時情報を抽出
    # 形式: 'YYYYMMDD_HHMMSS'
    date_time_str = document_id[:8] + " " + document_id[9:15]
    # 文字列からdatetimeオブジェクトを作成
    date_time_obj = datetime.strptime(date_time_str, "%Y%m%d %H%M%S")
    return date_time_obj


# いらない？？
@app.post("/saveImage")
def save_image(
    user_id: str, access_token: str, db, storage_client
) -> Dict[str, str]:
    if not access_token:
        raise HTTPException(
            status_code=401,
            detail="not provided AccessToken",
        )

    if not user_id:
        raise HTTPException(status_code=400, detail="not provided userId")
    logging.info(
        f"Processing saveImage request for user: {user_id} with accessToken: [REDACTED]"
    )

    # この辺あとでリファクタ
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

    # Firestoreの更新ロジック
    users_ref = db.collection("users")
    user_doc_ref = users_ref.document(user_id)
    photo_count = 0

    photos_ref = user_doc_ref.collection("photos")
    photos_doc_snapshot = photos_ref.limit(1).get()
    has_fetched_before = any(photos_doc_snapshot)

    # ドキュメントの最新時刻を取得
    latest_photo_datetime = datetime.now(timezone.utc)
    if has_fetched_before:
        latest_photo_id = get_latest_document_id(user_id, db)
        latest_photo_datetime = extract_datetime_from_id(latest_photo_id)
        latest_photo_datetime = latest_photo_datetime.replace(
            tzinfo=timezone.utc
        )

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

            # Google Photos APIから撮影日時を取得し、取得できない場合はこの写真の処理をスキップ
            shot_at = photo.get("mediaMetadata", {}).get("creationTime")
            if not shot_at:
                logging.info(
                    f"No shot_at time for photo {photo['filename']}. Skipping."
                )
                continue  # 撮影日時が取得できない場合は次の写真へ

            # APIから取得した日時文字列をdatetimeオブジェクトに変換
            shot_at_datetime = datetime.strptime(
                shot_at, "%Y-%m-%dT%H:%M:%S%z"
            )

            # 2回目以降利用で、かつ撮影日時が latest_photo_datetime よりも新しいか確認
            # TODO: 撮影日時ではなく、保存日時に差し替えないといけないかも？。
            if has_fetched_before and shot_at_datetime < latest_photo_datetime:
                # 古い写真が見つかったら、処理を終了
                user_doc_ref.update({"classifyPhotosStatus": READY_FOR_USE})
                return {"message": "Successfully processed photos"}

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
                filename = f"{uuid.uuid4()}.jpg"  # 一意のファイル名を生成
                image_url = save_to_cloud_storage(
                    content, filename, bucket, user_id
                )
                result, message = save_to_firestore(
                    image_url,
                    shot_at_datetime,
                    user_id,
                    db,
                )

                if result:
                    logging.info(f"photo_count: {photo_count}")
                    photo_count += 1  # 写真を正常に保存したらカウントを1増やす
                    # 8枚の写真が処理されたらclassifyPhotosStatusを更新
                    if photo_count == 8:
                        logging.info(f"classifyPhotosStatus: {READY_FOR_USE}")
                        user_doc_ref.update(
                            {"classifyPhotosStatus": READY_FOR_USE}
                        )
                        # TODO: 以下のtry exceptはあとで消す。
                        try:
                            doc_snapshot = user_doc_ref.get()
                            if doc_snapshot.exists:
                                current_status = doc_snapshot.to_dict().get(
                                    "classifyPhotosStatus", "not set"
                                )
                                logging.info(
                                    f"Current classifyPhotosStatus is: {current_status}"
                                )
                            else:
                                logging.error("Document does not exist.")
                        except Exception as e:
                            logging.error(f"Failed to read document: {e}")

                else:
                    logging.error(message)
                    raise HTTPException(status_code=500, detail=message)

        next_token = photos_data.get("nextPageToken")
        if not next_token:
            break

    # 処理が終わったら最後のアクセス時刻を更新
    # user_doc_ref.set({"lastAccessed": datetime.now(timezone.utc)}, merge=True)
    user_doc_ref.update({"classifyPhotosStatus": READY_FOR_USE})
    return {"message": "Successfully processed photos"}


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
