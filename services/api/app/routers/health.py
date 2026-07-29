from datetime import datetime, timezone

from fastapi import APIRouter

from ..schemas import SCHEMA_VERSION

router = APIRouter()


@router.get("/v1/health")
def health() -> dict:
    return {"status": "ok", "schemaVersion": SCHEMA_VERSION, "time": datetime.now(timezone.utc).isoformat()}
