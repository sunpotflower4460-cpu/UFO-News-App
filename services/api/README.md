# SkyTrace API — local mock server (Phase 2 foundation)

This is a local, fixture-backed implementation of `docs/openapi/skytrace-v1.yaml`
so the iOS `SkyTraceAPIClient`/Production repositories and backend contract can
be built and tested without any production credentials, cloud contract, or
real news provider (SKYTRACE_NEWS_FIRST_PRODUCTION_DIRECTIVE §8/§19).

It is **not** a production backend:

- All data comes from `app/fixtures.py` and every case is `isDemo: true`.
- Setting `SKYTRACE_ENV=production` makes the process refuse to start at all
  — see `test_production_mode_refuses_to_start` in `tests/test_contract.py`.
- There is no database, queue, ingestion worker, or real Source Registry —
  those are Phase 3+ work once real providers are approved.

## Run it

```bash
cd services/api
python3 -m venv .venv && source .venv/bin/activate   # optional
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

Then, e.g.:

```bash
curl -s http://127.0.0.1:8000/v1/feed/today | python3 -m json.tool
```

## Test it

```bash
cd services/api
pip install -r requirements.txt
pytest tests/ -v
```

## What's implemented

- Every endpoint in `docs/openapi/skytrace-v1.yaml`:
  `/v1/health`, `/v1/feed/today`, `/v1/cases`, `/v1/cases/{id}`,
  `/v1/cases/{id}/sources`, `/v1/cases/{id}/media`, `/v1/briefings/today`,
  `/v1/search`, `/v1/regions`.
- The required response envelope (`schemaVersion`, `generatedAt`,
  `retrievedAt`, `verifiedAt`, `contentRevision`, `sourceRevision`,
  `rightsState`, `locale`, `cacheTTL`) on every response.
- ETag / `If-None-Match` revalidation (`304` with no body on a match).
- `X-Request-Id` on every response, including error responses.
- The media rights gate (`app/policy.py`): `displayPermission` is computed
  from a `SourceProviderPolicy`'s approval status and the asset's
  `rightsState`, mirroring the iOS `MediaAssetView` gate so both sides refuse
  to show an unapproved asset even if the other side has a bug.
- A structured `ErrorOut` body (`code`/`message`/`requestId`) for HTTP errors.

## What's intentionally not implemented (see docs/DECISIONS.md)

- PostgreSQL/PostGIS, Redis, ingestion workers, clustering, AI synthesis
  pipeline, Admin console — Phase 3/4/5 per the directive's phase plan.
- Real provider adapters (RSS/API/manual) — `app/policy.py`'s
  `DEMO_PROVIDER_REGISTRY` exists only to exercise the rights gate in tests.
- Auth/entitlement verification — the mock server serves every case to every
  caller; StoreKit entitlement gating stays client-side (Free preview vs.
  Plus full content) until a real backend needs to enforce it server-side too.
