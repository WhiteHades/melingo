from fastapi.testclient import TestClient

from backend.api.main import app


def test_auth_profile_sync_stats_roundtrip() -> None:
    client = TestClient(app)

    auth_response = client.post(
        "/v1/auth/start",
        json={
            "device_id": "dev-android-01",
            "provider": "anon",
        },
    )
    assert auth_response.status_code == 200
    auth_payload = auth_response.json()
    assert auth_payload["user_id"] == "user_dev-android-01"
    assert auth_payload["session_token"] == "session_dev-android-01"

    headers = {"X-Session-Token": auth_payload["session_token"]}

    upsert_response = client.put(
        "/v1/profile",
        headers=headers,
        json={
            "display_name": "efaz",
            "language_code": "de",
            "level": "a2",
            "weekly_goal_minutes": 120,
            "updated_at_iso": "2026-04-08T09:00:00Z",
        },
    )
    assert upsert_response.status_code == 200
    upsert_payload = upsert_response.json()
    assert upsert_payload["server_version"] == 1
    assert upsert_payload["conflict_resolved"] is False

    stale_update_response = client.put(
        "/v1/profile",
        headers=headers,
        json={
            "display_name": "efaz-old",
            "language_code": "de",
            "level": "a1",
            "weekly_goal_minutes": 60,
            "updated_at_iso": "2026-04-01T09:00:00Z",
        },
    )
    assert stale_update_response.status_code == 200
    stale_payload = stale_update_response.json()
    assert stale_payload["conflict_resolved"] is True
    assert stale_payload["server_version"] == 1

    profile_response = client.get("/v1/profile", headers=headers)
    assert profile_response.status_code == 200
    profile_payload = profile_response.json()
    assert profile_payload["display_name"] == "efaz"
    assert profile_payload["weekly_goal_minutes"] == 120

    sync_response = client.post(
        "/v1/sync/events",
        headers=headers,
        json={
            "device_id": "dev-android-01",
            "events": [
                {
                    "event_id": "evt-1",
                    "type": "asr_result",
                    "occurred_at_iso": "2026-04-08T10:00:00Z",
                    "turn_id": "turn-1",
                    "metrics": {"latencyMs": 100, "confidence": 0.9},
                },
                {
                    "event_id": "evt-2",
                    "type": "tutor_result",
                    "occurred_at_iso": "2026-04-08T10:00:01Z",
                    "turn_id": "turn-1",
                    "metrics": {
                        "latencyMs": 80,
                        "mistakeTags": ["grammar:agreement"],
                    },
                },
                {
                    "event_id": "evt-3",
                    "type": "tts_result",
                    "occurred_at_iso": "2026-04-08T10:00:02Z",
                    "turn_id": "turn-1",
                    "metrics": {"latencyMs": 120},
                },
                {
                    "event_id": "evt-4",
                    "type": "tts_replay",
                    "occurred_at_iso": "2026-04-08T10:00:03Z",
                    "turn_id": "turn-1",
                    "metrics": {"audioBytes": 2048},
                },
            ],
        },
    )
    assert sync_response.status_code == 200
    sync_payload = sync_response.json()
    assert sync_payload["accepted"] == 4
    assert sync_payload["deduplicated"] == 0

    dedupe_response = client.post(
        "/v1/sync/events",
        headers=headers,
        json={
            "device_id": "dev-android-01",
            "events": [
                {
                    "event_id": "evt-1",
                    "type": "asr_result",
                    "occurred_at_iso": "2026-04-08T10:00:00Z",
                    "turn_id": "turn-1",
                    "metrics": {"latencyMs": 100, "confidence": 0.9},
                }
            ],
        },
    )
    assert dedupe_response.status_code == 200
    dedupe_payload = dedupe_response.json()
    assert dedupe_payload["accepted"] == 0
    assert dedupe_payload["deduplicated"] == 1

    stats_response = client.get("/v1/stats/summary", headers=headers)
    assert stats_response.status_code == 200
    stats_payload = stats_response.json()
    assert stats_payload["session_count"] == 1
    assert stats_payload["avg_asr_latency_ms"] == 100
    assert stats_payload["avg_tutor_latency_ms"] == 80
    assert stats_payload["avg_tts_latency_ms"] == 120
    assert stats_payload["replay_count"] == 1
    assert stats_payload["interruption_count"] == 0


def test_protected_routes_reject_missing_session_token() -> None:
    client = TestClient(app)

    response = client.get("/v1/profile")
    assert response.status_code == 401
    assert response.json()["detail"] == "missing session token"
