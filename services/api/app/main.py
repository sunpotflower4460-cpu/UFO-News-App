"""SkyTrace v1 API — local mock server (Phase 2 foundation).

This app exists to let the iOS `SkyTraceAPIClient` and backend contract be
built and tested end-to-end with no external credentials. It is explicitly
NOT a production backend: it serves only the fixtures in `fixtures.py`, all
marked `isDemo: true`, and it refuses to start in `production` mode at all
(directive §14 "Release: fixture禁止... API未設定なら明示エラー" — the
analogous backend-side rule is "a production-mode process must never be able
to serve fixture data").
"""

from __future__ import annotations

import os
import sys
import uuid

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse

from .routers import briefings, cases, feed, health, regions, search, social
from .schemas import SCHEMA_VERSION

RUNTIME_MODE = os.environ.get("SKYTRACE_ENV", "fixture")

if RUNTIME_MODE == "production":
    # No production provider credentials or database are wired up in this
    # scaffold. Failing loudly here is the backend-side mirror of the iOS
    # `UnconfiguredCaseRepository` seam — an explicit error, never a silent
    # fixture fallback dressed up as real news.
    sys.exit(
        "SkyTrace API: SKYTRACE_ENV=production is not supported by this mock "
        "server. It only ever serves fixture data. Point the iOS client at a "
        "real backend deployment for production use."
    )

app = FastAPI(title="SkyTrace API (local mock)", version=SCHEMA_VERSION)

app.include_router(health.router)
app.include_router(feed.router)
app.include_router(cases.router)
app.include_router(briefings.router)
app.include_router(search.router)
app.include_router(regions.router)
app.include_router(social.router)


@app.middleware("http")
async def request_id_middleware(request: Request, call_next):
    """Every response carries an `X-Request-Id` — required for the structured,
    content-free logging CLAUDE.md §5 asks for ("structured logs without
    sensitive content"), and echoed so client-side error reports can be
    correlated with a specific server request.
    """
    request_id = request.headers.get("x-request-id") or str(uuid.uuid4())
    response = await call_next(request)
    response.headers["X-Request-Id"] = request_id
    return response


@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    request_id = request.headers.get("x-request-id") or str(uuid.uuid4())
    return JSONResponse(
        status_code=exc.status_code,
        content={"code": str(exc.detail), "message": str(exc.detail), "requestId": request_id},
        headers={"X-Request-Id": request_id},
    )


@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    request_id = request.headers.get("x-request-id") or str(uuid.uuid4())
    return JSONResponse(
        status_code=500,
        content={"code": "internal_error", "message": "unexpected server error", "requestId": request_id},
        headers={"X-Request-Id": request_id},
    )
