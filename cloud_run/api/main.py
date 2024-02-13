# Third Party Library
from fastapi import FastAPI  # type: ignore
from fastapi.middleware.cors import CORSMiddleware  # type: ignore
from firebase_admin import credentials, initialize_app  # type: ignore

# First Party Library
from api.routers import task  # type: ignore

cred = credentials.Certificate("/auth/service_account.json")
initialize_app(cred)

app = FastAPI()
app.include_router(task.router)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
