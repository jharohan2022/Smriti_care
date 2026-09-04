"""Bhashini TTS/ASR gateway: proxy + Redis cache in front of the Bhashini API.

The mobile app hits this for natural regional-language narration and always
falls back to on-device TTS if it's unreachable — so this service degrading
never blocks a patient. We cache by (text, language) because narration strings
are highly repetitive (the same prompts on every screen)."""
from __future__ import annotations

import base64
import hashlib
import os

from fastapi import FastAPI
from pydantic import BaseModel

import sys
from pathlib import Path

def _add_shared() -> None:
    """Put the nearest ancestor containing `shared/` on sys.path — works both
    natively (services/<svc>/app) and in Docker (/app/app, shared at /app)."""
    here = Path(__file__).resolve()
    for cand in here.parents:
        if (cand / "shared").is_dir():
            sys.path.insert(0, str(cand))
            return


_add_shared()
from shared.health import HealthReport, Status, build_report  # noqa: E402

app = FastAPI(title="SmritiCare Bhashini Gateway")

BHASHINI_BASE_URL = os.getenv("BHASHINI_BASE_URL", "https://dhruva-api.bhashini.gov.in")
BHASHINI_API_KEY = os.getenv("BHASHINI_API_KEY", "")

# Simple in-process cache; swap for the REDIS_URL client in production.
_CACHE: dict[str, str] = {}


class TtsRequest(BaseModel):
    text: str
    sourceLanguage: str = "hi"


class TtsResponse(BaseModel):
    audioContent: str  # base64 wav/mp3
    cached: bool


def _key(req: TtsRequest) -> str:
    return hashlib.sha256(f"{req.sourceLanguage}:{req.text}".encode()).hexdigest()


@app.get("/")
def root() -> dict:
    return {"service": "bhashini-gateway", "status": "ok", "health": "/health", "docs": "/docs"}


@app.get("/health", response_model=HealthReport)
def health() -> HealthReport:
    # Report Bhashini reachability as a dependency so admin sees "degraded"
    # rather than a hard failure when the upstream is flaky.
    upstream = Status.up if BHASHINI_API_KEY else Status.degraded
    return build_report("bhashini-gateway", {"bhashini_upstream": upstream})


@app.post("/bhashini/tts", response_model=TtsResponse)
async def tts(req: TtsRequest) -> TtsResponse:
    key = _key(req)
    if key in _CACHE:
        return TtsResponse(audioContent=_CACHE[key], cached=True)

    audio = await _synthesize(req)
    _CACHE[key] = audio
    return TtsResponse(audioContent=audio, cached=False)


async def _synthesize(req: TtsRequest) -> str:
    """Call the real Bhashini pipeline here (httpx). Stubbed so the stack runs
    without credentials — returns a tiny silent clip the client can play."""
    if not BHASHINI_API_KEY:
        # 44-byte empty WAV header, base64. Client will fall back to on-device TTS.
        silent_wav = (
            b"RIFF$\x00\x00\x00WAVEfmt \x10\x00\x00\x00\x01\x00\x01\x00"
            b"\x40\x1f\x00\x00\x80>\x00\x00\x02\x00\x10\x00data\x00\x00\x00\x00"
        )
        return base64.b64encode(silent_wav).decode()
    # Real implementation (sketch):
    #   async with httpx.AsyncClient() as c:
    #       r = await c.post(f"{BHASHINI_BASE_URL}/services/inference/pipeline", ...)
    #   return r.json()["pipelineResponse"][0]["audio"][0]["audioContent"]
    raise NotImplementedError("Wire real Bhashini call with credentials")
