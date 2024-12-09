import asyncio
import os
import sys
sys.path.insert(1, os.path.join(sys.path[0], '..'))
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.router import router_clients


def create_fastapi_app():
    app = FastAPI(title="FastAPI")

    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # Разрешить запросы с любых источников
        allow_credentials=True,  # Разрешить использование кук
        allow_methods=["*"],  # Разрешить все методы
        allow_headers=["*"],  # Разрешить все заголовки
    )

    return app


app = create_fastapi_app()
app.include_router(router_clients)

if __name__ == "__main__":
    uvicorn.run(
        app="main:app",
        reload=True,
    )
