"""Telemetry ingest + anomaly detection.

Key contract with the mobile app: POST /telemetry/batch is IDEMPOTENT — it keys
on client-generated eventIds, so a half-failed batch is always safe to retry.
This is what lets the offline outbox drain without ever double-counting.
"""
from __future__ import annotations

import statistics
from collections import defaultdict
from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

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
from shared.health import HealthReport, build_report  # noqa: E402
from shared.schemas import (  # noqa: E402
    AnomalyPatient,
    BatchAck,
    TelemetryBatchIn,
    TelemetryEventIn,
    TelemetryPoint,
)

app = FastAPI(title="SmritiCare Telemetry Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten to the portal origins in production
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- In-memory store (swap for PostgreSQL via the DATABASE_URL in production) ---
# eventId -> event, giving O(1) idempotent de-dup.
_EVENTS: dict[str, TelemetryEventIn] = {}
_PATIENT_META = {
    "p-1001": {"name": "Kamala Devi", "region": "Barmer, RJ", "baseline": 620},
    "p-1002": {"name": "Ram Prasad", "region": "Koraput, OD", "baseline": 580},
    "p-1044": {"name": "Ganpat Singh", "region": "Barmer, RJ", "baseline": 700},
}


@app.get("/")
def root() -> dict:
    return {"service": "telemetry-service", "status": "ok", "health": "/health", "docs": "/docs"}


@app.get("/health", response_model=HealthReport)
def health() -> HealthReport:
    return build_report("telemetry-service")


@app.post("/telemetry/batch", response_model=BatchAck)
def ingest_batch(batch: TelemetryBatchIn) -> BatchAck:
    """Idempotent bulk ingest. Duplicates (by eventId) are counted, not re-stored."""
    accepted = duplicates = 0
    for event in batch.events:
        if event.eventId in _EVENTS:
            duplicates += 1
            continue
        _EVENTS[event.eventId] = event
        accepted += 1
    return BatchAck(accepted=accepted, duplicates=duplicates)


def _rolling_z(patient_id: str) -> tuple[float, int]:
    """Return (z-score, current mean reaction) for a patient's recent reactions
    against their personal baseline. Empty history → (0, baseline)."""
    baseline = _PATIENT_META.get(patient_id, {}).get("baseline", 600)
    reactions = [e.reactionMs for e in _EVENTS.values() if e.patientId == patient_id]
    if len(reactions) < 2:
        return 0.0, baseline
    recent = reactions[-10:]
    mean = statistics.fmean(recent)
    stdev = statistics.pstdev(reactions) or 1.0
    return (mean - baseline) / stdev, round(mean)


def _severity(z: float) -> str:
    if z >= 3.0:
        return "critical"
    if z >= 2.5:
        return "serious"
    if z >= 2.0:
        return "warning"
    return "good"


@app.get("/telemetry/anomalies", response_model=list[AnomalyPatient])
def anomalies() -> list[AnomalyPatient]:
    """Patients whose rolling reaction-time mean has crossed baseline + 2σ."""
    out: list[AnomalyPatient] = []
    patient_ids = {e.patientId for e in _EVENTS.values()} or set(_PATIENT_META)
    for pid in patient_ids:
        z, current = _rolling_z(pid)
        if z < 2.0:
            continue
        meta = _PATIENT_META.get(pid, {"name": pid, "region": "—", "baseline": 600})
        out.append(
            AnomalyPatient(
                patientId=pid,
                name=meta["name"],
                region=meta["region"],
                severity=_severity(z),
                metric="Reaction Time Drift",
                zScore=round(z, 1),
                baselineReactionMs=meta["baseline"],
                currentReactionMs=current,
                lastUpdated=datetime.now(timezone.utc).date().isoformat(),
            )
        )
    out.sort(key=lambda a: a.zScore, reverse=True)
    return out


@app.get("/telemetry/patients/{patient_id}/series", response_model=list[TelemetryPoint])
def series(patient_id: str) -> list[TelemetryPoint]:
    """Biweekly rolling means for the doctor portal's trend chart."""
    baseline = _PATIENT_META.get(patient_id, {}).get("baseline", 600)
    buckets: dict[str, list[TelemetryEventIn]] = defaultdict(list)
    for e in _EVENTS.values():
        if e.patientId != patient_id:
            continue
        # 14-day bucket: floor the ISO week to the nearest even week.
        iso = e.capturedAt.isocalendar()
        fortnight = iso.week // 2
        buckets[f"{iso.year}-{fortnight:02d}"].append(e)

    points: list[TelemetryPoint] = []
    for key in sorted(buckets):
        evs = buckets[key]
        points.append(
            TelemetryPoint(
                date=key,
                label=evs[0].capturedAt.strftime("%b %d"),
                reactionMs=round(statistics.fmean(e.reactionMs for e in evs), 1),
                patternErrors=round(statistics.fmean(e.patternErrors for e in evs), 1),
                baselineReactionMs=baseline,
            )
        )
    return points
