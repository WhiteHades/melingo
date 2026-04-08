from fastapi.testclient import TestClient

from backend.api.main import app


def test_sync_endpoint_accepts_events() -> None:
    client = TestClient(app)
    auth_response = client.post(
        "/v1/auth/start",
        json={"device_id": "dev-01", "provider": "anon"},
    )
    token = auth_response.json()["session_token"]

    response = client.post(
        "/v1/sync/events",
        headers={"X-Session-Token": token},
        json={
            "device_id": "dev-01",
            "events": [
                {
                    "event_id": "evt-001",
                    "type": "session_started",
                    "occurred_at_iso": "2026-04-07T10:00:00Z",
                    "turn_id": None,
                    "metrics": {},
                }
            ],
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["accepted"] == 1
    assert payload["deduplicated"] == 0
    assert payload["status"] == "queued"
