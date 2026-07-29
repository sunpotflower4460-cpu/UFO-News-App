from collections import Counter

from fastapi import APIRouter, Request, Response

from .. import fixtures
from ..schemas import RegionOut
from ..util import build_envelope

router = APIRouter()


@router.get("/v1/regions")
def regions(request: Request, response: Response):
    counts = Counter((c["countryCode"], c["regionName"]) for c in fixtures.CASES)
    out = [RegionOut(countryCode=cc, regionName=name, caseCount=n) for (cc, name), n in counts.items()]
    env = build_envelope(out, request=request, response=response, cache_ttl=3600)
    if env is None:
        return Response(status_code=304)
    return env
