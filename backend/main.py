from fastapi import FastAPI

from app.api import router

app = FastAPI(title="API", version="0.1.0")
app.include_router(router)


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}
