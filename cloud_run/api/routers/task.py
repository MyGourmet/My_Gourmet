# Third Party Library
from fastapi import APIRouter, Depends, Request  # type: ignore
from firebase_admin import firestore  # type: ignore
from google.cloud import storage  # type: ignore

# First Party Library
from api.schemas.classify_photos import (  # type: ignore
    save_image,
    update_user_status,
)

router = APIRouter()


# Firestore クライアントの取得
def get_firestore_client():
    return firestore.client()


def get_storage_client():
    return storage.Client()


@router.post("/saveImage")
async def save_image_endpoint(
    request: Request,
    db=Depends(get_firestore_client),
    storage_client=Depends(get_storage_client),
):
    body = await request.json()
    auth_header = request.headers.get("Authorization")
    access_token = (
        auth_header.split(" ")[1]
        if auth_header and auth_header.startswith("Bearer ")
        else None
    )
    user_id = body.get("userId")

    return save_image(
        user_id=user_id,
        access_token=access_token,
        db=db,
        storage_client=storage_client,
    )


@router.post("/updateUserStatus")
async def update_user_status_endpoint(
    request: Request, db=Depends(get_firestore_client)
):
    # リクエストからデータを抽出
    body = await request.json()
    auth_header = request.headers.get("Authorization")
    access_token = (
        auth_header.split(" ")[1]
        if auth_header and auth_header.startswith("Bearer ")
        else None
    )
    user_id = body.get("userId")

    # update_user_status関数を呼び出し、dbを引数として渡す
    return update_user_status(
        user_id=user_id, access_token=access_token, db=db
    )
