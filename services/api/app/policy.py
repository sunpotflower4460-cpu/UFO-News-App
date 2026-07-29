"""Source provider policy and the media/rights gate (directive §10-§11).

No production provider may be queried, and no media asset may be served as
displayable, unless its policy/rights are explicitly approved. There is no
default-allow path — an unknown or pending provider is treated the same as a
rejected one. This mirrors the iOS side's rule that a rights-unknown asset is
never rendered inline, only linked to its source.
"""

from __future__ import annotations

from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, HttpUrl


class ApprovalStatus(str, Enum):
    pending = "pending"
    approved = "approved"
    rejected = "rejected"
    suspended = "suspended"


class SourceProviderPolicy(BaseModel):
    provider_id: str
    provider_name: str
    terms_url: HttpUrl
    commercial_use: bool
    automated_retrieval_allowed: bool
    excerpt_allowed: bool
    image_use_allowed: bool
    video_use_allowed: bool
    attribution_text: str
    approved_at: Optional[datetime] = None
    status: ApprovalStatus = ApprovalStatus.pending

    @property
    def is_production_ready(self) -> bool:
        """Only an explicitly approved provider may be queried in production."""
        return self.status == ApprovalStatus.approved


class MediaRightsState(str, Enum):
    pending = "pending"
    approved = "approved"
    rejected = "rejected"


class MediaDisplayPermission(str, Enum):
    allowed = "allowed"
    link_only = "link_only"


def media_is_displayable(
    *, display_permission: MediaDisplayPermission, rights_state: MediaRightsState, source_page_url: Optional[str]
) -> bool:
    """directive §11: an asset renders inline only when all three hold. Any
    other combination must fall back to a link-out ("画像は元の記事でご覧いた
    だけます" / "[元の記事を開く]") — never a best-effort inline render.
    """
    return (
        display_permission == MediaDisplayPermission.allowed
        and rights_state == MediaRightsState.approved
        and bool(source_page_url)
    )


# Sample registry for the local mock server only. Statuses are deliberately
# mixed (one approved, one pending) so contract tests exercise the gate —
# production enablement always comes from the real Source Registry (CLAUDE.md
# §7), never from this file.
DEMO_PROVIDER_REGISTRY: dict[str, SourceProviderPolicy] = {
    "demo_official_registry": SourceProviderPolicy(
        provider_id="demo_official_registry",
        provider_name="Demo Official Records Office",
        terms_url="https://example.org/terms",
        commercial_use=True,
        automated_retrieval_allowed=True,
        excerpt_allowed=True,
        image_use_allowed=True,
        video_use_allowed=False,
        attribution_text="Demo Official Records Office",
        approved_at=datetime(2026, 1, 10),
        status=ApprovalStatus.approved,
    ),
    "demo_wire_service": SourceProviderPolicy(
        provider_id="demo_wire_service",
        provider_name="Demo Wire Service",
        terms_url="https://example.org/terms-wire",
        commercial_use=False,
        automated_retrieval_allowed=False,
        excerpt_allowed=False,
        image_use_allowed=True,
        video_use_allowed=True,
        attribution_text="Demo Wire Service",
        approved_at=None,
        status=ApprovalStatus.pending,
    ),
    # Tier D (SNS) — no automated-retrieval agreement exists with any social
    # platform yet, so this stays `pending` indefinitely until a real, signed
    # Tier D provider agreement replaces it (docs/DATA_SOURCE_REGISTRY.md).
    # `automated_retrieval_allowed=False` means the ingestion worker (Phase 3+)
    # must not poll this platform at all, regardless of this status flag.
    "demo_social_platform": SourceProviderPolicy(
        provider_id="demo_social_platform",
        provider_name="Demo Social Platform",
        terms_url="https://example.org/terms-social",
        commercial_use=False,
        automated_retrieval_allowed=False,
        excerpt_allowed=False,
        image_use_allowed=False,
        video_use_allowed=True,
        attribution_text="Demo Social Platform user post",
        approved_at=None,
        status=ApprovalStatus.pending,
    ),
}
