from fastapi import APIRouter, Query, Request, Response

from .. import fixtures
from ..schemas import CaseOut
from ..util import build_envelope

router = APIRouter()


@router.get("/v1/search")
def search(request: Request, response: Response, q: str = Query(default="")) -> object:
    needle = q.strip()
    matches = [
        CaseOut(**c) for c in fixtures.CASES
        if not needle or needle in c["title"] or needle in c["summary"]
    ]
    env = build_envelope(matches, request=request, response=response, cache_ttl=30)
    if env is None:
        return Response(status_code=304)
    return env
