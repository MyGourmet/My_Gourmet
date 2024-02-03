#! /bin/bash

# uvicorn のサーバーを立ち上げる
poetry run uvicorn api.main:app --host 0.0.0.0 --port 8000