"""Response schemas for the SkyTrace v1 API (docs/openapi/skytrace-v1.yaml is
the human-readable contract; this module is its Python mirror so the mock
server and contract tests share one source of truth for field names).
"""

from __future__ import annotations

from datetime import datetime
from typing import Generic, Optional, TypeVar

from pydantic import BaseModel, Field

SCHEMA_VERSION = "1.0.0"


class SourceOut(BaseModel):
    id: str
    outlet_name: str = Field(alias="outletName")
    source_type: str = Field(alias="sourceType")
    title: str
    published_at: Optional[datetime] = Field(default=None, alias="publishedAt")
    retrieved_at: datetime = Field(alias="retrievedAt")
    role: str
    url: Optional[str] = None

    model_config = {"populate_by_name": True}


class MediaAssetOut(BaseModel):
    id: str
    kind: str
    rights_state: str = Field(alias="rightsState")
    display_permission: str = Field(alias="displayPermission")
    source_page_url: str = Field(alias="sourcePageURL")
    media_url: Optional[str] = Field(default=None, alias="mediaURL")
    thumbnail_url: Optional[str] = Field(default=None, alias="thumbnailURL")
    attribution_text: str = Field(alias="attributionText")
    license_note: Optional[str] = Field(default=None, alias="licenseNote")

    model_config = {"populate_by_name": True}


class CaseOut(BaseModel):
    id: str
    slug: str
    title: str
    summary: str
    occurred_at_start: Optional[datetime] = Field(default=None, alias="occurredAtStart")
    published_at: datetime = Field(alias="publishedAt")
    updated_at: datetime = Field(alias="updatedAt")
    last_verified_at: Optional[datetime] = Field(default=None, alias="lastVerifiedAt")
    location_precision: str = Field(alias="locationPrecision")
    latitude: float
    longitude: float
    country_code: str = Field(alias="countryCode")
    region_name: str = Field(alias="regionName")
    locality_name: Optional[str] = Field(default=None, alias="localityName")
    status: str
    source_count: int = Field(alias="sourceCount")
    independent_report_count: int = Field(alias="independentReportCount")
    sources: list[SourceOut] = []
    media: list[MediaAssetOut] = []
    is_demo: bool = Field(default=True, alias="isDemo")

    model_config = {"populate_by_name": True}


class BriefingOut(BaseModel):
    id: str
    date: datetime
    headline: str
    summary: str
    used_case_count: int = Field(alias="usedCaseCount")
    source_count: int = Field(alias="sourceCount")
    reading_minutes: int = Field(alias="readingMinutes")
    generated_at: datetime = Field(alias="generatedAt")
    disclosure: str

    model_config = {"populate_by_name": True}


class TodayFeedOut(BaseModel):
    date: datetime
    last_updated_at: datetime = Field(alias="lastUpdatedAt")
    top_cases: list[CaseOut] = Field(alias="topCases")
    new_report_count: int = Field(alias="newReportCount")
    merged_case_count: int = Field(alias="mergedCaseCount")

    model_config = {"populate_by_name": True}


class RegionOut(BaseModel):
    country_code: str = Field(alias="countryCode")
    region_name: str = Field(alias="regionName")
    case_count: int = Field(alias="caseCount")

    model_config = {"populate_by_name": True}


T = TypeVar("T")


class Envelope(BaseModel, Generic[T]):
    """Every `/v1/*` response is wrapped in this envelope (directive §9). All
    nine fields are required — a response missing one is a contract violation,
    not an optional nicety, since the iOS client's schema validation and cache
    logic (ETag, staleness banners, "最終更新") depend on every one of them.
    """

    schema_version: str = Field(default=SCHEMA_VERSION, alias="schemaVersion")
    generated_at: datetime = Field(alias="generatedAt")
    retrieved_at: datetime = Field(alias="retrievedAt")
    verified_at: Optional[datetime] = Field(default=None, alias="verifiedAt")
    content_revision: int = Field(alias="contentRevision")
    source_revision: int = Field(alias="sourceRevision")
    rights_state: str = Field(alias="rightsState")
    locale: str = "ja"
    cache_ttl: int = Field(alias="cacheTTL")
    data: T

    model_config = {"populate_by_name": True}


class ErrorOut(BaseModel):
    code: str
    message: str
    request_id: str = Field(alias="requestId")

    model_config = {"populate_by_name": True}
