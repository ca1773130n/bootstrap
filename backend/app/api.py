from fastapi import APIRouter

router = APIRouter(prefix="/api")


@router.get("/ping")
async def ping() -> dict[str, str]:
    return {"ping": "pong"}
