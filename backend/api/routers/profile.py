from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field

from ..state import ApiState, ProfileRecord
from .auth import require_session
from .deps import get_api_state

router = APIRouter(tags=["profile"])


class ProfileUpsertRequest(BaseModel):
    display_name: str = Field(min_length=1)
    language_code: str = Field(min_length=1)
    level: str = Field(min_length=1)
    weekly_goal_minutes: int = Field(ge=1)
    updated_at_iso: str = Field(min_length=1)


class ProfileUpsertResponse(BaseModel):
    user_id: str
    server_version: int
    conflict_resolved: bool


class ProfileReadResponse(BaseModel):
    user_id: str
    display_name: str
    language_code: str
    level: str
    weekly_goal_minutes: int
    updated_at_iso: str
    server_version: int


@router.put("/profile", response_model=ProfileUpsertResponse)
def upsert_profile(
    request: ProfileUpsertRequest,
    session=Depends(require_session),
    state: ApiState = Depends(get_api_state),
) -> ProfileUpsertResponse:
    existing = state.profiles_by_user.get(session.user_id)
    incoming_ts = request.updated_at_iso

    if existing is None:
        record = ProfileRecord(
            user_id=session.user_id,
            display_name=request.display_name,
            language_code=request.language_code,
            level=request.level,
            weekly_goal_minutes=request.weekly_goal_minutes,
            updated_at_iso=request.updated_at_iso,
            server_version=1,
        )
        state.profiles_by_user[session.user_id] = record
        return ProfileUpsertResponse(
            user_id=session.user_id,
            server_version=record.server_version,
            conflict_resolved=False,
        )

    if incoming_ts >= existing.updated_at_iso:
        updated = ProfileRecord(
            user_id=session.user_id,
            display_name=request.display_name,
            language_code=request.language_code,
            level=request.level,
            weekly_goal_minutes=request.weekly_goal_minutes,
            updated_at_iso=request.updated_at_iso,
            server_version=existing.server_version + 1,
        )
        state.profiles_by_user[session.user_id] = updated
        return ProfileUpsertResponse(
            user_id=session.user_id,
            server_version=updated.server_version,
            conflict_resolved=False,
        )

    return ProfileUpsertResponse(
        user_id=session.user_id,
        server_version=existing.server_version,
        conflict_resolved=True,
    )


@router.get("/profile", response_model=ProfileReadResponse | None)
def read_profile(
    session=Depends(require_session),
    state: ApiState = Depends(get_api_state),
) -> ProfileReadResponse | None:
    record = state.profiles_by_user.get(session.user_id)
    if record is None:
        return None

    return ProfileReadResponse(
        user_id=record.user_id,
        display_name=record.display_name,
        language_code=record.language_code,
        level=record.level,
        weekly_goal_minutes=record.weekly_goal_minutes,
        updated_at_iso=record.updated_at_iso,
        server_version=record.server_version,
    )
