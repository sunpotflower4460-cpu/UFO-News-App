"""Contract tests for the SkyTrace v1 mock API. These check the shape every
`/v1/*` response must have (docs/openapi/skytrace-v1.yaml) and the rights
gate that decides whether a media asset may be shown inline — the same rule
the iOS `MediaAssetView` enforces on the client (belt and suspenders: a
provider whose policy status changes must not require an app update).
"""

import importlib

from fastapi.testclient import TestClient

REQUIRED_ENVELOPE_FIELDS = {
    "schemaVersion", "generatedAt", "retrievedAt", "verifiedAt",
    "contentRevision", "sourceRevision", "rightsState", "locale", "cacheTTL", "data",
}


def _client():
    from app.main import app
    return TestClient(app)


def test_health_ok():
    resp = _client().get("/v1/health")
    assert resp.status_code == 200
    assert resp.json()["status"] == "ok"


def test_feed_today_envelope_has_all_required_fields():
    resp = _client().get("/v1/feed/today")
    assert resp.status_code == 200
    body = resp.json()
    assert REQUIRED_ENVELOPE_FIELDS.issubset(body.keys()), REQUIRED_ENVELOPE_FIELDS - body.keys()
    assert len(body["data"]["topCases"]) >= 1


def test_every_documented_endpoint_returns_the_full_envelope():
    client = _client()
    case_id = client.get("/v1/cases").json()["data"][0]["id"]
    endpoints = [
        "/v1/feed/today",
        "/v1/cases",
        f"/v1/cases/{case_id}",
        f"/v1/cases/{case_id}/sources",
        f"/v1/cases/{case_id}/media",
        "/v1/briefings/today",
        "/v1/search?q=",
        "/v1/regions",
    ]
    for path in endpoints:
        resp = client.get(path)
        assert resp.status_code == 200, path
        assert REQUIRED_ENVELOPE_FIELDS.issubset(resp.json().keys()), (path, resp.json().keys())


def test_case_detail_404_for_unknown_id_uses_structured_error():
    resp = _client().get("/v1/cases/does-not-exist")
    assert resp.status_code == 404
    body = resp.json()
    assert body["code"] == "case_not_found"
    assert "requestId" in body


def test_request_id_header_always_present():
    resp = _client().get("/v1/health")
    assert resp.headers.get("X-Request-Id")


def test_etag_round_trip_returns_304_on_matching_if_none_match():
    client = _client()
    first = client.get("/v1/feed/today")
    etag = first.headers["etag"]
    assert etag
    second = client.get("/v1/feed/today", headers={"If-None-Match": etag})
    assert second.status_code == 304


def test_search_filters_by_query_text():
    client = _client()
    all_cases = client.get("/v1/search?q=").json()["data"]
    assert len(all_cases) >= 2
    filtered = client.get("/v1/search?q=" + "アリゾナ").json()["data"]
    assert len(filtered) == 1
    assert "アリゾナ" in filtered[0]["title"] or "アリゾナ" in filtered[0]["summary"]


def test_media_rights_gate_only_allows_display_for_approved_provider():
    """directive §11: `displayPermission == allowed` requires `rightsState ==
    approved` — a `pending` provider's asset must degrade to link-only even
    though it otherwise looks displayable (has a sourcePageURL, etc.)."""
    client = _client()
    media = client.get("/v1/cases/case_demo_001/media").json()["data"]
    approved_asset = next(m for m in media if m["id"] == "media_1")
    pending_asset = next(m for m in media if m["id"] == "media_2")
    assert approved_asset["displayPermission"] == "allowed"
    assert approved_asset["mediaURL"] is not None
    assert pending_asset["displayPermission"] == "link_only"
    assert pending_asset["mediaURL"] is None
    assert pending_asset["sourcePageURL"]  # the link-out target must still exist


def test_production_mode_refuses_to_start():
    """The mock server must refuse to boot as `production` rather than
    silently serving fixtures under a production-sounding name."""
    import os
    import subprocess
    import sys

    env = dict(os.environ, SKYTRACE_ENV="production", PYTHONPATH=str(_repo_root()))
    result = subprocess.run(
        [sys.executable, "-c", "import app.main"],
        cwd=str(_repo_root()),
        env=env,
        capture_output=True,
        text=True,
    )
    assert result.returncode != 0
    assert "production" in (result.stdout + result.stderr).lower()


def _repo_root():
    from pathlib import Path
    return Path(__file__).resolve().parents[1]
