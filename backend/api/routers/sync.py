from fastapi import APIRouter
from pydantic import BaseModel, Field

router = APIRouter(tags=["sync"])


class SyncEnvelope(BaseModel):
    device_id: str = Field(min_length=1)
    events: list[dict[str, object]] = Field(default_factory=list)


@router.post("/sync/events")
def sync_events(envelope: SyncEnvelope) -> dict[str, object]:
    return {
        "accepted": len(envelope.events),
        "device_id": envelope.device_id,
        "status": "queued",
    }
