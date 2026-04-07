from fastapi.testclient import TestClient

from backend.api.main import app


def test_sync_endpoint_accepts_events() -> None:
    client = TestClient(app)
    response = client.post(
        "/v1/sync/events",
        json={
            "device_id": "dev-01",
            "events": [{"type": "session_started", "timestamp": "2026-04-07T10:00:00Z"}],
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["accepted"] == 1
    assert payload["status"] == "queued"
