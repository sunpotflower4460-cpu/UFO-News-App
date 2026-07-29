from typing import Optional

from fastapi import APIRouter, HTTPException, Request, Response

from .. import fixtures
from ..schemas import CaseOut, Envelope
from ..util import build_envelope

router = APIRouter()


def _find(case_id: str) -> dict:
    for c in fixtures.CASES:
        if c["id"] == case_id:
            return c
    raise HTTPException(status_code=404, detail="case_not_found")


@router.get("/v1/cases")
def list_cases(request: Request, response: Response) -> Optional[Envelope]:
    cases = [CaseOut(**c) for c in fixtures.CASES]
    env = build_envelope(cases, request=request, response=response)
    if env is None:
        return Response(status_code=304)
    return env


@router.get("/v1/cases/{case_id}")
def case_detail(case_id: str, request: Request, response: Response):
    case = CaseOut(**_find(case_id))
    env = build_envelope(case, request=request, response=response, verified_at=case.last_verified_at)
    if env is None:
        return Response(status_code=304)
    return env


@router.get("/v1/cases/{case_id}/sources")
def case_sources(case_id: str, request: Request, response: Response):
    case = CaseOut(**_find(case_id))
    env = build_envelope(case.sources, request=request, response=response)
    if env is None:
        return Response(status_code=304)
    return env


@router.get("/v1/cases/{case_id}/media")
def case_media(case_id: str, request: Request, response: Response):
    case = CaseOut(**_find(case_id))
    env = build_envelope(case.media, request=request, response=response)
    if env is None:
        return Response(status_code=304)
    return env
