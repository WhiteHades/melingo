from fastapi import APIRouter, Depends, Header, HTTPException
from pydantic import BaseModel, Field

from ..state import ApiState, UserSession
from .deps import get_api_state

router = APIRouter(tags=["auth"])


class AuthStartRequest(BaseModel):
    device_id: str = Field(min_length=1)
    provider: str = Field(default="anon", min_length=1)


class AuthStartResponse(BaseModel):
    user_id: str
    device_id: str
    session_token: str


@router.post("/auth/start", response_model=AuthStartResponse)
def auth_start(
    request: AuthStartRequest,
    state: ApiState = Depends(get_api_state),
) -> AuthStartResponse:
    user_id = f"user_{request.device_id}"
    session_token = f"session_{request.device_id}"

    state.sessions_by_device[request.device_id] = UserSession(
        device_id=request.device_id,
        user_id=user_id,
        session_token=session_token,
    )

    return AuthStartResponse(
        user_id=user_id,
        device_id=request.device_id,
        session_token=session_token,
    )


def require_session(
    x_session_token: str | None = Header(default=None, alias="X-Session-Token"),
    state: ApiState = Depends(get_api_state),
) -> UserSession:
    if x_session_token is None or not x_session_token:
        raise HTTPException(status_code=401, detail="missing session token")

    for session in state.sessions_by_device.values():
        if session.session_token == x_session_token:
            return session

    raise HTTPException(status_code=401, detail="invalid session token")
