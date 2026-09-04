"""Shared health-check protocol used by every service and read by the admin portal."""
from __future__ import annotations

import time
from enum import Enum

from pydantic import BaseModel


class Status(str, Enum):
    up = "up"
    degraded = "degraded"
    down = "down"


class HealthReport(BaseModel):
    service: str
    status: Status
    version: str = "0.1.0"
    uptime_s: float
    dependencies: dict[str, Status] = {}


_STARTED = time.monotonic()


def build_report(service: str, dependencies: dict[str, Status] | None = None) -> HealthReport:
    deps = dependencies or {}
    # A service is only as healthy as its hardest-down dependency.
    if Status.down in deps.values():
        status = Status.degraded
    else:
        status = Status.up
    return HealthReport(
        service=service,
        status=status,
        uptime_s=round(time.monotonic() - _STARTED, 1),
        dependencies=deps,
    )
