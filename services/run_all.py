"""Run the whole SmritiCare backend natively — no Docker required.

The services use in-memory stores, so this is all you need for local dev/demo:

    python services/run_all.py

Ports match what the gateway and the Vite dev-proxies expect:
    identity-service   ->  http://localhost:8001
    telemetry-service  ->  http://localhost:8002
    bhashini-gateway   ->  http://localhost:8003
    gateway (BFF)      ->  http://localhost:8080   (portals talk to this)

Press Ctrl+C to stop them all.
"""
from __future__ import annotations

import signal
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent

# (service dir, uvicorn target, port)
SERVICES = [
    ("identity-service", "app.main:app", 8001),
    ("telemetry-service", "app.main:app", 8002),
    ("bhashini-gateway", "app.main:app", 8003),
    ("gateway", "app.main:app", 8080),
]


def main() -> int:
    procs: list[subprocess.Popen] = []
    print("Starting SmritiCare backend (native, no Docker)...\n")

    for name, target, port in SERVICES:
        cwd = ROOT / name
        proc = subprocess.Popen(
            [sys.executable, "-m", "uvicorn", target, "--host", "0.0.0.0", "--port", str(port)],
            cwd=cwd,
        )
        procs.append(proc)
        print(f"  * {name:<18} http://localhost:{port}")
        time.sleep(0.4)  # let the gateway's deps bind before it probes them

    print("\nAll services up. Gateway/health: http://localhost:8080/admin/health")
    print("Press Ctrl+C to stop.\n")

    def shutdown(*_: object) -> None:
        print("\nStopping services...")
        for p in procs:
            p.terminate()

    signal.signal(signal.SIGINT, shutdown)
    if hasattr(signal, "SIGTERM"):
        signal.signal(signal.SIGTERM, shutdown)

    # Block until any child exits (or Ctrl+C), then tear the rest down.
    try:
        while True:
            for p in procs:
                if p.poll() is not None:
                    raise KeyboardInterrupt
            time.sleep(0.5)
    except KeyboardInterrupt:
        pass
    finally:
        for p in procs:
            if p.poll() is None:
                p.terminate()
        for p in procs:
            try:
                p.wait(timeout=5)
            except subprocess.TimeoutExpired:
                p.kill()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
