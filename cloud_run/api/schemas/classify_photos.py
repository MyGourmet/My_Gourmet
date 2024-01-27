from firebase_admin import firestore
from fastapi import HTTPException

def update_user_status(user_id: str, access_token: str, db):
    
    if not access_token:
        raise HTTPException(status_code=401, detail="アクセストークンが提供されていないか無効です")

    if not user_id:
        raise HTTPException(status_code=400, detail="userIdが提供されていません")

    # Firestoreの更新ロジック
    users_ref = db.collection("users")
    user_doc_ref = users_ref.document(user_id)
    new_state = "readyForUser"
    user_doc_ref.update({"classifyPhotosStatus": new_state})
    return {"message": "正常に更新されました"}
