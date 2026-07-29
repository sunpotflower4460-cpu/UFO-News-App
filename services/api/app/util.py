"""Shared envelope/ETag helpers so every router builds responses the same way."""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from typing import Optional

from fastapi import Request, Response
from fastapi.encoders import jsonable_encoder

from .schemas import Envelope

CONTENT_REVISION = 1
SOURCE_REVISION = 1


def etag_for(payload) -> str:
    """A stable ETag derived from the serialised payload. Real production
    revisions should come from a monotonic `content_revision` counter per the
    directive, not a content hash — a hash is used here only because the mock
    server has no database to hold that counter.
    """
    encoded = json.dumps(jsonable_encoder(payload), sort_keys=True, default=str).encode("utf-8")
    return '"' + hashlib.sha256(encoded).hexdigest()[:32] + '"'


def build_envelope(
    data,
    *,
    request: Request,
    response: Response,
    verified_at: Optional[datetime] = None,
    cache_ttl: int = 60,
    rights_state: str = "approved",
) -> Optional[Envelope]:
    """Wraps `data` in the required response envelope (directive §9) and sets
    the ETag/Cache-Control headers the iOS client's `SkyTraceAPIClient` relies
    on for `If-None-Match` revalidation. Returns `None` (with `response`
    already set to 304) when the caller's `If-None-Match` matches — per HTTP,
    a 304 must carry no body, so the route handler must return an empty
    `Response` in that case rather than this envelope.
    """
    now = datetime.now(timezone.utc)
    locale = (request.headers.get("Accept-Language") or "ja").split(",")[0].split("-")[0] or "ja"
    envelope = Envelope(
        generatedAt=now,
        retrievedAt=now,
        verifiedAt=verified_at,
        contentRevision=CONTENT_REVISION,
        sourceRevision=SOURCE_REVISION,
        rightsState=rights_state,
        locale=locale,
        cacheTTL=cache_ttl,
        data=data,
    )
    # ETag reflects `data` only — `generatedAt`/`retrievedAt` are wrapper
    # metadata that change on every fetch and must not defeat revalidation.
    tag = etag_for(jsonable_encoder(data, by_alias=True))
    response.headers["ETag"] = tag
    response.headers["Cache-Control"] = f"max-age={cache_ttl}"
    if request.headers.get("if-none-match") == tag:
        response.status_code = 304
        return None
    return envelope
