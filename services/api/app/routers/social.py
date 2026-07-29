from fastapi import APIRouter, Request, Response

from .. import fixtures
from ..schemas import SocialReportOut
from ..util import build_envelope

router = APIRouter()


@router.get("/v1/social/reports")
def social_reports(request: Request, response: Response):
    """The Premium "SNSでの目撃報告" feed. Items are returned in case-then-
    source order only — no query parameter here ever sorts or filters by a
    computed likelihood; the client's own plain shape-tag/date filter is the
    only narrowing offered (see the iOS `SocialReportsSwipeView` doc comment).
    """
    reports = [SocialReportOut(**r) for r in fixtures.SOCIAL_REPORTS]
    env = build_envelope(reports, request=request, response=response, cache_ttl=300)
    if env is None:
        return Response(status_code=304)
    return env
