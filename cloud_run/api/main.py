from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from firebase_admin import initialize_app, credentials
from api.routers import task, done

cred = credentials.Certificate('/auth/service_account.json')
initialize_app(cred)

app = FastAPI()
app.include_router(task.router)
app.include_router(done.router)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)
