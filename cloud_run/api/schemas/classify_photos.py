from datetime import datetime
import uuid
from google.cloud import storage
from fastapi import FastAPI, HTTPException
import requests
from datetime import datetime
import logging
from typing import Optional, Tuple, Dict, Any
import traceback

app = FastAPI()

def get_photos_from_google_photo_api(
    access_token: str,
    page_size: int = 10, 
    next_page_token: Optional[str] = None
) -> Dict[str, Any]:
    try:
        search_request_data = {"pageSize": page_size}
        if next_page_token:
            search_request_data["pageToken"] = next_page_token

        response = requests.post(
            "https://photoslibrary.googleapis.com/v1/mediaItems:search",
            headers={"Authorization": f"Bearer {access_token}"},
            json=search_request_data,
            timeout=10
        )
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        logging.error(f"Request failed: {e}")
        return {}

def save_to_firestore(
    image_url: str,
    user_id: str,
    db,
) -> Tuple[bool, str]:
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

        # Firestoreの`users`コレクションにデータを保存
        user_ref = db.collection("users").document(user_id)
        photo_id = str(uuid.uuid4())
        user_ref.collection("photos").document(photo_id).set(photo_data)
        return True, "Firestore update successful"
    except Exception as e:
        logging.error(f"An error occurred while saving to Firestore: {e}")
        return False, str(e)

@app.post("/saveImage")
def save_image(
    user_id: str, 
    access_token: str, 
    db
) -> Dict[str, str]:
    if not access_token:
        raise HTTPException(status_code=401, detail="アクセストークンが提供されていないか無効です")

    if not user_id:
        raise HTTPException(status_code=400, detail="userIdが提供されていません")

    # bucket = storage_client.bucket("my-gourmet-160fb.appspot.com")
    next_token: Optional[str] = None
    for _ in range(1):
        photos_data = get_photos_from_google_photo_api(
            access_token, page_size=20, next_page_token=next_token
        )
        if not photos_data.get("mediaItems"):
            logging.info("No mediaItems found in the response.")
            return {"message": "No media items found"}, 200

        for photo in photos_data["mediaItems"]:
            result, message = save_to_firestore(
                photo["baseUrl"],user_id, db
            )
            if not result:
                logging.error(message)
                return {"error": message}, 500

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
        raise HTTPException(status_code=401, detail="アクセストークンが提供されていないか無効です")

    if not user_id:
        raise HTTPException(status_code=400, detail="userIdが提供されていません")

    # Firestoreの更新ロジック
    users_ref = db.collection("users")
    user_doc_ref = users_ref.document(user_id)
    new_state = "readyForUse"
    user_doc_ref.update({"classifyPhotosStatus": new_state})
    return {"message": "正常に更新されました"}
