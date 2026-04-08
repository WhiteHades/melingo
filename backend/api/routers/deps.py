from fastapi import Request

from ..state import ApiState


def get_api_state(request: Request) -> ApiState:
    return request.app.state.api_state
