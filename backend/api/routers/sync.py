from typing import Any

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field

from ..state import ApiState, SyncEventRecord
from .auth import require_session
from .deps import get_api_state

router = APIRouter(tags=["sync"])


class SyncEvent(BaseModel):
    event_id: str = Field(min_length=1)
    type: str = Field(min_length=1)
    occurred_at_iso: str = Field(min_length=1)
    turn_id: str | None = None
    metrics: dict[str, Any] = Field(default_factory=dict)


class SyncEnvelope(BaseModel):
    device_id: str = Field(min_length=1)
    events: list[SyncEvent] = Field(default_factory=list)


class SyncResponse(BaseModel):
    accepted: int
    deduplicated: int
    device_id: str
    status: str


@router.post("/sync/events", response_model=SyncResponse)
def sync_events(
    envelope: SyncEnvelope,
    session=Depends(require_session),
    state: ApiState = Depends(get_api_state),
) -> SyncResponse:
    seen_event_ids = state.seen_event_ids_by_user[session.user_id]
    user_events = state.events_by_user[session.user_id]

    accepted = 0
    deduplicated = 0

    for event in envelope.events:
        if event.event_id in seen_event_ids:
            deduplicated += 1
            continue

        seen_event_ids.add(event.event_id)
        user_events.append(
            SyncEventRecord(
                event_id=event.event_id,
                user_id=session.user_id,
                type=event.type,
                occurred_at_iso=event.occurred_at_iso,
                turn_id=event.turn_id,
                metrics=event.metrics,
            )
        )
        accepted += 1

    return SyncResponse(
        accepted=accepted,
        deduplicated=deduplicated,
        device_id=envelope.device_id,
        status="queued",
    )
