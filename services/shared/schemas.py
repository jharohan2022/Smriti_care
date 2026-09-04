"""Wire-format schemas shared across services. Mirrors the mobile TelemetryEvent
and the doctor portal's TypeScript types so the contract is defined once."""
from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field


class TelemetryEventIn(BaseModel):
    """One game trial as sent by the mobile outbox. `eventId` is the idempotency key."""

    eventId: str
    patientId: str
    gameId: str
    reactionMs: int = Field(ge=0)
    spatialErrorPx: float = Field(ge=0)
    patternErrors: int = Field(ge=0)
    capturedAt: datetime


class TelemetryBatchIn(BaseModel):
    events: list[TelemetryEventIn]


class BatchAck(BaseModel):
    accepted: int
    duplicates: int  # eventIds already stored — safely ignored


class Severity(str):
    good = "good"
    warning = "warning"
    serious = "serious"
    critical = "critical"


class AnomalyPatient(BaseModel):
    patientId: str
    name: str
    region: str
    severity: str
    metric: str
    zScore: float
    baselineReactionMs: int
    currentReactionMs: int
    lastUpdated: str


class TelemetryPoint(BaseModel):
    date: str
    label: str
    reactionMs: float
    patternErrors: float
    baselineReactionMs: float
