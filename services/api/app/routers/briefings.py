from fastapi import APIRouter, Request, Response

from .. import fixtures
from ..schemas import BriefingOut
from ..util import build_envelope

router = APIRouter()


@router.get("/v1/briefings/today")
def briefing_today(request: Request, response: Response):
    briefing = BriefingOut(**fixtures.BRIEFING_TODAY)
    env = build_envelope(briefing, request=request, response=response, cache_ttl=300)
    if env is None:
        return Response(status_code=304)
    return env
