from fastapi import APIRouter, Depends
from pydantic import BaseModel

from ..state import ApiState
from .auth import require_session
from .deps import get_api_state

router = APIRouter(tags=["stats"])


class StatsSummaryResponse(BaseModel):
    session_count: int
    avg_asr_latency_ms: int
    avg_tutor_latency_ms: int
    avg_tts_latency_ms: int
    replay_count: int
    interruption_count: int


@router.get("/stats/summary", response_model=StatsSummaryResponse)
def stats_summary(
    session=Depends(require_session),
    state: ApiState = Depends(get_api_state),
) -> StatsSummaryResponse:
    events = state.events_by_user.get(session.user_id, [])

    turn_ids: set[str] = set()
    asr_latencies: list[int] = []
    tutor_latencies: list[int] = []
    tts_latencies: list[int] = []
    replay_count = 0
    interruption_count = 0

    for event in events:
        if event.turn_id:
            turn_ids.add(event.turn_id)

        if event.type == "asr_result":
            latency_ms = event.metrics.get("latencyMs")
            if isinstance(latency_ms, int):
                asr_latencies.append(latency_ms)
        elif event.type == "tutor_result":
            latency_ms = event.metrics.get("latencyMs")
            if isinstance(latency_ms, int):
                tutor_latencies.append(latency_ms)
        elif event.type == "tts_result":
            latency_ms = event.metrics.get("latencyMs")
            if isinstance(latency_ms, int):
                tts_latencies.append(latency_ms)
        elif event.type == "tts_replay":
            replay_count += 1
        elif event.type == "tts_interrupted":
            interruption_count += 1

    return StatsSummaryResponse(
        session_count=len(turn_ids),
        avg_asr_latency_ms=_avg_int(asr_latencies),
        avg_tutor_latency_ms=_avg_int(tutor_latencies),
        avg_tts_latency_ms=_avg_int(tts_latencies),
        replay_count=replay_count,
        interruption_count=interruption_count,
    )


def _avg_int(values: list[int]) -> int:
    if not values:
        return 0
    return round(sum(values) / len(values))
