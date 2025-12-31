from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import router

app = FastAPI(title="API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://myapp-web.fly.dev",
        "http://localhost:5173",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}
