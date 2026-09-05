"""Bhashini TTS/ASR/NMT gateway: proxy + Redis cache in front of the Bhashini API.

The mobile app hits this for natural regional-language narration and always
falls back to on-device TTS if it's unreachable — so this service degrading
never blocks a patient. We cache by (text, language) because narration strings
are highly repetitive (the same prompts on every screen)."""
from __future__ import annotations

import base64
import hashlib
import logging
import os

import httpx
from fastapi import FastAPI, HTTPException
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

logger = logging.getLogger("bhashini-gateway")
logging.basicConfig(level=logging.INFO)

app = FastAPI(title="SmritiCare Bhashini Gateway")

BHASHINI_BASE_URL = os.getenv("BHASHINI_BASE_URL", "https://dhruva-api.bhashini.gov.in").rstrip("/")
BHASHINI_API_KEY = os.getenv("BHASHINI_API_KEY", "")
BHASHINI_USER_ID = os.getenv("BHASHINI_USER_ID", "")
BHASHINI_PIPELINE_ID = os.getenv("BHASHINI_PIPELINE_ID", "64392f08d7420e6f6630f9a2")

# Simple in-process cache; swap for REDIS_URL client in production.
_CACHE: dict[str, str] = {}


class TtsRequest(BaseModel):
    text: str
    sourceLanguage: str = "hi"
    gender: str = "female"


class TtsResponse(BaseModel):
    audioContent: str  # base64 wav/mp3
    cached: bool


class AsrRequest(BaseModel):
    audioContent: str  # base64 wav/mp3 audio clip
    sourceLanguage: str = "hi"


class AsrResponse(BaseModel):
    transcript: str
    language: str


class TranslateRequest(BaseModel):
    text: str
    sourceLanguage: str = "en"
    targetLanguage: str = "hi"


class TranslateResponse(BaseModel):
    translatedText: str


def _key(req: TtsRequest) -> str:
    return hashlib.sha256(f"{req.sourceLanguage}:{req.gender}:{req.text}".encode()).hexdigest()


@app.get("/")
def root() -> dict:
    return {"service": "bhashini-gateway", "status": "ok", "health": "/health", "docs": "/docs"}


@app.get("/health", response_model=HealthReport)
def health() -> HealthReport:
    upstream = Status.up if (BHASHINI_API_KEY and BHASHINI_USER_ID) else Status.degraded
    return build_report("bhashini-gateway", {"bhashini_upstream": upstream})


@app.post("/bhashini/tts", response_model=TtsResponse)
async def tts(req: TtsRequest) -> TtsResponse:
    key = _key(req)
    if key in _CACHE:
        return TtsResponse(audioContent=_CACHE[key], cached=True)

    audio = await _synthesize(req)
    _CACHE[key] = audio
    return TtsResponse(audioContent=audio, cached=False)


@app.post("/bhashini/asr", response_model=AsrResponse)
async def asr(req: AsrRequest) -> AsrResponse:
    transcript = await _recognize(req)
    return AsrResponse(transcript=transcript, language=req.sourceLanguage)


@app.post("/bhashini/translate", response_model=TranslateResponse)
async def translate(req: TranslateRequest) -> TranslateResponse:
    translated = await _translate(req)
    return TranslateResponse(translatedText=translated)


async def _get_pipeline_config(task_type: str, source_lang: str, target_lang: str | None = None) -> tuple[dict, str, str]:
    """Fetch serviceId, callbackUrl, and dynamic auth key from Bhashini ULCA pipeline endpoint."""
    config_url = f"{BHASHINI_BASE_URL}/ULCA/apis/v1/model/getPipeline"
    headers = {
        "userID": BHASHINI_USER_ID,
        "ulcaApiKey": BHASHINI_API_KEY,
        "Content-Type": "application/json",
    }
    
    task_config: dict = {"taskType": task_type, "config": {"language": {"sourceLanguage": source_lang}}}
    if target_lang:
        task_config["config"]["language"]["targetLanguage"] = target_lang

    payload = {
        "pipelineTasks": [task_config],
        "pipelineRequestConfig": {"pipelineId": BHASHINI_PIPELINE_ID},
    }

    async with httpx.AsyncClient(timeout=10.0) as client:
        res = await client.post(config_url, headers=headers, json=payload)
        res.raise_for_status()
        data = res.json()

    pipeline_res = data["pipelineResponseConfig"][0]
    service_id = pipeline_res["config"][0]["serviceId"]
    callback_url = data["pipelineInferenceAPIEndPoint"]["callbackUrl"]
    inference_key_name = data["pipelineInferenceAPIEndPoint"]["inferenceApiKey"]["name"]
    inference_key_value = data["pipelineInferenceAPIEndPoint"]["inferenceApiKey"]["value"]

    return {
        "serviceId": service_id,
        "callbackUrl": callback_url,
        "inferenceKeyName": inference_key_name,
        "inferenceKeyValue": inference_key_value,
    }


async def _synthesize(req: TtsRequest) -> str:
    """Call Bhashini TTS pipeline via Dhruva API. Falls back to silent clip if credentials missing/unreachable."""
    if not (BHASHINI_API_KEY and BHASHINI_USER_ID):
        # 44-byte empty WAV header, base64. Client will fall back to on-device TTS.
        silent_wav = (
            b"RIFF$\x00\x00\x00WAVEfmt \x10\x00\x00\x00\x01\x00\x01\x00"
            b"\x40\x1f\x00\x00\x80>\x00\x00\x02\x00\x10\x00data\x00\x00\x00\x00"
        )
        return base64.b64encode(silent_wav).decode()

    try:
        config = await _get_pipeline_config("tts", req.sourceLanguage)
        
        payload = {
            "pipelineTasks": [
                {
                    "taskType": "tts",
                    "config": {
                        "language": {"sourceLanguage": req.sourceLanguage},
                        "serviceId": config["serviceId"],
                        "gender": req.gender,
                    },
                }
            ],
            "inputData": {"input": [{"source": req.text}]},
        }

        headers = {
            config["inferenceKeyName"]: config["inferenceKeyValue"],
            "Content-Type": "application/json",
        }

        async with httpx.AsyncClient(timeout=15.0) as client:
            res = await client.post(config["callbackUrl"], headers=headers, json=payload)
            res.raise_for_status()
            data = res.json()
            return data["pipelineResponse"][0]["audio"][0]["audioContent"]
    except Exception as err:
        logger.warning(f"Bhashini TTS upstream error: {err}. Returning silent fallback.")
        silent_wav = (
            b"RIFF$\x00\x00\x00WAVEfmt \x10\x00\x00\x00\x01\x00\x01\x00"
            b"\x40\x1f\x00\x00\x80>\x00\x00\x02\x00\x10\x00data\x00\x00\x00\x00"
        )
        return base64.b64encode(silent_wav).decode()


async def _recognize(req: AsrRequest) -> str:
    """Call Bhashini ASR (Speech to Text) pipeline."""
    if not (BHASHINI_API_KEY and BHASHINI_USER_ID):
        raise HTTPException(status_code=503, detail="Bhashini credentials not configured")

    config = await _get_pipeline_config("asr", req.sourceLanguage)

    payload = {
        "pipelineTasks": [
            {
                "taskType": "asr",
                "config": {
                    "language": {"sourceLanguage": req.sourceLanguage},
                    "serviceId": config["serviceId"],
                    "audioFormat": "wav",
                    "samplingRate": 16000,
                },
            }
        ],
        "inputData": {"audio": [{"audioContent": req.audioContent}]},
    }

    headers = {
        config["inferenceKeyName"]: config["inferenceKeyValue"],
        "Content-Type": "application/json",
    }

    async with httpx.AsyncClient(timeout=20.0) as client:
        res = await client.post(config["callbackUrl"], headers=headers, json=payload)
        res.raise_for_status()
        data = res.json()
        return data["pipelineResponse"][0]["output"][0]["source"]


async def _translate(req: TranslateRequest) -> str:
    """Call Bhashini Translation (NMT) pipeline."""
    if not (BHASHINI_API_KEY and BHASHINI_USER_ID):
        raise HTTPException(status_code=503, detail="Bhashini credentials not configured")

    config = await _get_pipeline_config("translation", req.sourceLanguage, req.targetLanguage)

    payload = {
        "pipelineTasks": [
            {
                "taskType": "translation",
                "config": {
                    "language": {
                        "sourceLanguage": req.sourceLanguage,
                        "targetLanguage": req.targetLanguage,
                    },
                    "serviceId": config["serviceId"],
                },
            }
        ],
        "inputData": {"input": [{"source": req.text}]},
    }

    headers = {
        config["inferenceKeyName"]: config["inferenceKeyValue"],
        "Content-Type": "application/json",
    }

    async with httpx.AsyncClient(timeout=15.0) as client:
        res = await client.post(config["callbackUrl"], headers=headers, json=payload)
        res.raise_for_status()
        data = res.json()
        return data["pipelineResponse"][0]["output"][0]["target"]

