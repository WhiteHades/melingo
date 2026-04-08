from collections import defaultdict
from dataclasses import dataclass, field
from typing import Any


@dataclass
class UserSession:
    device_id: str
    user_id: str
    session_token: str


@dataclass
class ProfileRecord:
    user_id: str
    display_name: str
    language_code: str
    level: str
    weekly_goal_minutes: int
    updated_at_iso: str
    server_version: int


@dataclass
class SyncEventRecord:
    event_id: str
    user_id: str
    type: str
    occurred_at_iso: str
    turn_id: str | None
    metrics: dict[str, Any]


@dataclass
class ApiState:
    sessions_by_device: dict[str, UserSession] = field(default_factory=dict)
    profiles_by_user: dict[str, ProfileRecord] = field(default_factory=dict)
    seen_event_ids_by_user: dict[str, set[str]] = field(
        default_factory=lambda: defaultdict(set)
    )
    events_by_user: dict[str, list[SyncEventRecord]] = field(
        default_factory=lambda: defaultdict(list)
    )
