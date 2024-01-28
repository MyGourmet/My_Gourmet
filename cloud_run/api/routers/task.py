from typing import List
from fastapi import APIRouter, Request, Depends
from google.cloud import storage
import api.schemas.task as task_schema
from api.schemas.classify_photos import save_image, update_user_status
from firebase_admin import firestore

router = APIRouter()

# Firestore クライアントの取得
def get_firestore_client():
    return firestore.client()

# def get_storage_client():
#     return storage.Client()

@router.post("/saveImage")
async def save_image_endpoint(request: Request, db=Depends(get_firestore_client)):
    body = await request.json()
    auth_header = request.headers.get('Authorization')
    access_token = auth_header.split(" ")[1] if auth_header and auth_header.startswith("Bearer ") else None
    user_id = body.get("userId")
    
    return save_image(user_id=user_id, access_token=access_token, db=db)

@router.post("/updateUserStatus")
async def update_user_status_endpoint(request: Request, db=Depends(get_firestore_client)):
    # リクエストからデータを抽出
    body = await request.json()
    auth_header = request.headers.get('Authorization')
    access_token = auth_header.split(" ")[1] if auth_header and auth_header.startswith("Bearer ") else None
    user_id = body.get("userId")
    
    # update_user_status関数を呼び出し、dbを引数として渡す
    return update_user_status(user_id=user_id, access_token=access_token, db=db)



@router.get("/tasks", response_model=List[task_schema.Task])
async def list_tasks():
    return [task_schema.Task(id=1, title="1つ目のTODOタスク")]


@router.post("/tasks", response_model=task_schema.TaskCreateResponse)
async def create_task(task_body: task_schema.TaskCreate):
    return task_schema.TaskCreateResponse(id=1, **task_body.dict())


@router.put("/tasks/{task_id}", response_model=task_schema.TaskCreateResponse)
async def update_task(task_id: int, task_body: task_schema.TaskCreate):
    return task_schema.TaskCreateResponse(id=task_id, **task_body.dict())


@router.delete("/tasks/{task_id}", response_model=None)
async def delete_task(task_id: int):
    return