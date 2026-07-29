from fastapi import APIRouter, Request, Response

from .. import fixtures
from ..schemas import CaseOut, TodayFeedOut
from ..util import build_envelope

router = APIRouter()


@router.get("/v1/feed/today")
def feed_today(request: Request, response: Response):
    feed = TodayFeedOut(
        date=fixtures._NOW,
        lastUpdatedAt=fixtures._NOW,
        topCases=[CaseOut(**c) for c in fixtures.CASES],
        newReportCount=len(fixtures.CASES),
        mergedCaseCount=0,
    )
    env = build_envelope(feed, request=request, response=response, cache_ttl=30)
    if env is None:
        return Response(status_code=304)
    return env
