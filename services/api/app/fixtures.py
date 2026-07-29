"""Deterministic mock data for the local API. This is a development/contract
fixture, not a production data source — every case is `isDemo: true` and the
server refuses to start in `--env production` without real provider
credentials (see `main.py`), so this module can never be mistaken for a live
feed (directive §14 "Release: fixture禁止").
"""

from __future__ import annotations

from datetime import datetime, timezone

from .policy import DEMO_PROVIDER_REGISTRY, MediaDisplayPermission, MediaRightsState, media_is_displayable

_NOW = datetime(2026, 7, 13, 22, 40, tzinfo=timezone.utc)


def _media_asset(
    id: str, kind: str, provider_id: str, rights_state: MediaRightsState, source_page_url: str, caption: str,
    *, source_id: str,
) -> dict:
    policy = DEMO_PROVIDER_REGISTRY[provider_id]
    # The gate is evaluated here, once, from the provider's real approval
    # status — a router must never hand-set `displayPermission` itself.
    displayable = media_is_displayable(
        display_permission=MediaDisplayPermission.allowed if policy.is_production_ready else MediaDisplayPermission.link_only,
        rights_state=rights_state,
        source_page_url=source_page_url,
    )
    return {
        "id": id,
        "kind": kind,
        "rightsState": rights_state.value,
        "displayPermission": (MediaDisplayPermission.allowed if displayable else MediaDisplayPermission.link_only).value,
        "sourcePageURL": source_page_url,
        "mediaURL": source_page_url if displayable else None,
        "thumbnailURL": None,
        "attributionText": policy.attribution_text,
        "licenseNote": None,
        # Internal-only: which SourceReference this asset illustrates. Not part
        # of the public `MediaAssetOut` schema (pydantic drops unknown keys by
        # default) — used only by `social_reports()` below to attach the right
        # media to the right `.social` source.
        "sourceID": source_id,
    }


CASES: list[dict] = [
    {
        "id": "case_demo_001",
        "slug": "demo-satellite-pass",
        "title": "アタカマ砂漠で観測された整列する光の列",
        "summary": "複数の観測者が、夜空を等間隔で移動する光点を報告。直近の衛星打ち上げ後の可視パスと時刻・方角が一致した。",
        "occurredAtStart": _NOW.isoformat(),
        "publishedAt": _NOW.isoformat(),
        "updatedAt": _NOW.isoformat(),
        "lastVerifiedAt": _NOW.isoformat(),
        "locationPrecision": "approximate",
        "latitude": -23.65,
        "longitude": -70.40,
        "countryCode": "CL",
        "regionName": "アントファガスタ州",
        "localityName": "アタカマ砂漠",
        "status": "explained",
        "sourceCount": 3,
        "independentReportCount": 2,
        "isDemo": True,
        # Internal-only, mirrors the iOS `UAPCase.shapeTags` fixture field —
        # not part of the minimal v1 `Case` schema (D-NF-007), used only by
        # `social_reports()` for the SNS feed's plain categorical filter.
        "shapeTags": ["光点", "整列", "移動"],
        "sources": [
            {
                "id": "src_1",
                "outletName": "Demo Official Records Office",
                "sourceType": "official",
                "title": "夜間可視衛星パスの記録",
                "publishedAt": _NOW.isoformat(),
                "retrievedAt": _NOW.isoformat(),
                "role": "supports",
                "url": "https://example.org/records/pass-1",
            },
            {
                "id": "src_2",
                "outletName": "Demo Wire Service",
                "sourceType": "press",
                "title": "住民が報告した『光の列』",
                "publishedAt": _NOW.isoformat(),
                "retrievedAt": _NOW.isoformat(),
                "role": "supports",
                "url": "https://example.org/wire/lights",
            },
            {
                "id": "src_social_1",
                "outletName": "Demo Social Platform user",
                "sourceType": "social",
                "title": "夜空の光点を撮影したという投稿",
                "publishedAt": _NOW.isoformat(),
                "retrievedAt": _NOW.isoformat(),
                "role": "contextualizes",
                "url": "https://example.org/social/post-1",
            },
        ],
        "media": [
            _media_asset(
                "media_1", "image", "demo_official_registry", MediaRightsState.approved,
                "https://example.org/records/pass-1", "衛星パスの記録画像", source_id="src_1",
            ),
            _media_asset(
                "media_2", "video", "demo_wire_service", MediaRightsState.pending,
                "https://example.org/wire/lights", "住民撮影の映像（権利確認待ち）", source_id="src_2",
            ),
            _media_asset(
                "media_3", "video", "demo_social_platform", MediaRightsState.pending,
                "https://example.org/social/post-1", "投稿映像（権利確認待ち）", source_id="src_social_1",
            ),
        ],
    },
    {
        "id": "case_demo_002",
        "slug": "demo-insufficient-data",
        "title": "アリゾナ西の空で輝いた動かない一点",
        "summary": "日没後の西の低空で、明るく瞬く一点が観測された。方位・時刻は金星の位置と一致する。",
        "occurredAtStart": _NOW.isoformat(),
        "publishedAt": _NOW.isoformat(),
        "updatedAt": _NOW.isoformat(),
        "lastVerifiedAt": None,
        "locationPrecision": "region_only",
        "latitude": 33.45,
        "longitude": -112.07,
        "countryCode": "US",
        "regionName": "アリゾナ州",
        "localityName": None,
        "status": "explained",
        "sourceCount": 1,
        "independentReportCount": 1,
        "isDemo": True,
        "shapeTags": ["光点", "静止"],
        "sources": [
            {
                "id": "src_3",
                "outletName": "Demo Wire Service",
                "sourceType": "press",
                "title": "『西の空の謎の光』への問い合わせ",
                "publishedAt": _NOW.isoformat(),
                "retrievedAt": _NOW.isoformat(),
                "role": "supports",
                "url": "https://example.org/wire/venus",
            },
        ],
        "media": [],
    },
]

def social_reports() -> list[dict]:
    """Builds the "SNSでの目撃報告" feed items from `CASES`, in case-then-source
    order — never sorted or filtered by a computed likelihood (mirrors the iOS
    `[UAPCase].socialReportCandidates` derivation exactly, so both sides stay
    the same shape even before the two are wired together end-to-end).
    """
    reports: list[dict] = []
    for case in CASES:
        for source in case["sources"]:
            if source["sourceType"] != "social":
                continue
            reports.append({
                "id": f"{case['id']}_{source['id']}",
                "caseId": case["id"],
                "caseTitle": case["title"],
                "caseStatus": case["status"],
                "caseShapeTags": case.get("shapeTags", []),
                "source": source,
                "media": [m for m in case["media"] if m.get("sourceID") == source["id"]],
                "isDemo": case["isDemo"],
            })
    return reports


SOCIAL_REPORTS: list[dict] = social_reports()

BRIEFING_TODAY: dict = {
    "id": "briefing_demo_today",
    "date": _NOW.isoformat(),
    "headline": "今日の空のニュースまとめ",
    "summary": "今日は2件のニュースを整理しました。1件は衛星の可視パスと一致、1件は金星の見え方と一致しました。",
    "usedCaseCount": len(CASES),
    "sourceCount": sum(len(c["sources"]) for c in CASES),
    "readingMinutes": 3,
    "generatedAt": _NOW.isoformat(),
    "disclosure": "ai_reviewed",
}
