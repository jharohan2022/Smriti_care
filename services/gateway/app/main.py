"""API gateway / BFF. Fans health checks out to every service so the admin
portal has a single /admin/health endpoint, and forwards patient/portal traffic
to the right microservice."""
from __future__ import annotations

import asyncio
import os
import sys
from pathlib import Path

import httpx
from fastapi import FastAPI, Response
from fastapi.middleware.cors import CORSMiddleware

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

app = FastAPI(title="SmritiCare Gateway")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

SERVICES = {
    "identity": os.getenv("IDENTITY_URL", "http://localhost:8001"),
    "telemetry": os.getenv("TELEMETRY_URL", "http://localhost:8002"),
    "bhashini": os.getenv("BHASHINI_URL", "http://localhost:8003"),
}


@app.get("/")
def root() -> dict:
    """Friendly index so opening the gateway in a browser isn't a bare 404."""
    return {
        "service": "SmritiCare Gateway (BFF)",
        "status": "ok",
        "endpoints": {
            "aggregated_health": "/admin/health",
            "gateway_health": "/health",
            "interactive_docs": "/docs",
        },
        "downstream": SERVICES,
    }


@app.get("/favicon.ico", include_in_schema=False)
def favicon() -> Response:
    return Response(status_code=204)


@app.get("/health", response_model=HealthReport)
def health() -> HealthReport:
    return build_report("gateway")


async def _probe(client: httpx.AsyncClient, name: str, url: str) -> dict:
    try:
        r = await client.get(f"{url}/health", timeout=3.0)
        r.raise_for_status()
        body = r.json()
        return {"id": name, "name": body.get("service", name), "status": body.get("status", "up"),
                "uptime_s": body.get("uptime_s", 0)}
    except (httpx.HTTPError, ValueError):
        return {"id": name, "name": name, "status": Status.down.value, "uptime_s": 0}


@app.get("/admin/health")
async def admin_health() -> list[dict]:
    """Aggregated health for the admin SystemHealthDashboard."""
    async with httpx.AsyncClient() as client:
        results = await asyncio.gather(
            *(_probe(client, name, url) for name, url in SERVICES.items())
        )
    return list(results)


from fastapi import Request
from starlette.responses import StreamingResponse


@app.api_route("/{service_name}/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"])
async def forward(service_name: str, path: str, request: Request):
    if service_name not in SERVICES:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail=f"Service '{service_name}' not found")

    target_base = SERVICES[service_name]
    target_url = f"{target_base}/{service_name}/{path}"
    if request.url.query:
        target_url += f"?{request.url.query}"

    body = await request.body()
    headers = dict(request.headers)
    headers.pop("host", None)
    headers.pop("content-length", None)

    async with httpx.AsyncClient() as client:
        resp = await client.request(
            method=request.method,
            url=target_url,
            content=body,
            headers=headers,
            timeout=30.0,
        )
        return Response(
            content=resp.content,
            status_code=resp.status_code,
            headers=dict(resp.headers),
            media_type=resp.headers.get("content-type"),
        )

