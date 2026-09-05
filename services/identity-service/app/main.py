"""Identity service: device-bound patient identity (zero-auth) + ASHA/doctor auth.

Patients never log in. An ASHA worker provisions a device once; the device then
signs every request with the secret it was issued (verified here). DPDP consent
artifacts live alongside the patient profile so erasure can be honored."""
from __future__ import annotations

import secrets
import sys
from pathlib import Path

from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel

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

app = FastAPI(title="SmritiCare Identity Service")

# patientId -> {"secret", "profile", "consent"}  (swap for PostgreSQL).
_DEVICES: dict[str, dict] = {}
_SEQ = 1000


class PatientProfile(BaseModel):
    name: str
    region: str
    ashaId: str
    consentGiven: bool = False


class ProvisionResponse(BaseModel):
    patientId: str
    deviceSecret: str


@app.get("/")
def root() -> dict:
    return {"service": "identity-service", "status": "ok", "health": "/health", "docs": "/docs"}


@app.get("/health", response_model=HealthReport)
def health() -> HealthReport:
    return build_report("identity-service")


@app.post("/identity/provision", response_model=ProvisionResponse)
def provision(profile: PatientProfile) -> ProvisionResponse:
    """Called by the ASHA app (online) to bind a new patient device."""
    if not profile.consentGiven:
        raise HTTPException(status_code=422, detail="Consent is required before provisioning (DPDP).")
    global _SEQ
    _SEQ += 1
    patient_id = f"p-{_SEQ}"
    device_secret = secrets.token_urlsafe(32)
    _DEVICES[patient_id] = {
        "secret": device_secret,
        "profile": profile.model_dump(),
        "consent": profile.consentGiven,
    }
    return ProvisionResponse(patientId=patient_id, deviceSecret=device_secret)


@app.get("/identity/verify")
def verify(
    x_patient_id: str = Header(...),
    x_device_secret: str = Header(...),
) -> dict[str, bool]:
    """Constant-time verification of the device-bound credentials."""
    record = _DEVICES.get(x_patient_id)
    if not record or not secrets.compare_digest(record["secret"], x_device_secret):
        raise HTTPException(status_code=401, detail="Invalid device credentials")
    return {"ok": True}


class LoginRequest(BaseModel):
    username: str
    password: str = ""
    role: str = "patient"  # patient, asha, doctor, admin
    language: str = "hi"


class SignupRequest(BaseModel):
    username: str
    password: str = ""
    name: str = ""
    role: str = "patient"
    region: str = "default"
    language: str = "hi"
    additionalInfo: dict = {}


class AuthResponse(BaseModel):
    token: str
    userId: str
    name: str
    role: str
    language: str = "hi"
    region: str = "default"


_USERS: dict[str, dict] = {
    "dr.sharma": {
        "password": "password123",
        "name": "Dr. Aarav Sharma",
        "role": "doctor",
        "region": "AIIMS New Delhi",
    },
    "admin": {
        "password": "admin",
        "name": "System Administrator",
        "role": "admin",
        "region": "Central Health HQ",
    },
    "asha-001": {
        "password": "1234",
        "name": "Sunita Devi (ASHA)",
        "role": "asha",
        "region": "Rampur Sub-Center",
    },
    "ramesh-p": {
        "password": "",
        "name": "Ramesh Kumar",
        "role": "patient",
        "region": "Rampur Village",
    },
}


@app.post("/identity/auth/login", response_model=AuthResponse)
def login(req: LoginRequest) -> AuthResponse:
    user_key = req.username.strip().lower()
    user = _USERS.get(user_key)
    
    # Auto-register new users on first login for smooth demo / developer access
    if not user:
        user = {
            "password": req.password,
            "name": req.username.split("@")[0].title() if "@" in req.username else req.username.title(),
            "role": req.role,
            "region": "Central Health HQ" if req.role == "admin" else ("AIIMS New Delhi" if req.role == "doctor" else "Local"),
            "language": req.language,
        }
        _USERS[user_key] = user
    elif req.password and user.get("password") and user["password"] != req.password:
        raise HTTPException(status_code=401, detail="Invalid password for existing user")

    token = f"jwt-token-{secrets.token_hex(16)}"
    return AuthResponse(
        token=token,
        userId=user_key,
        name=user.get("name", req.username),
        role=user.get("role", req.role),
        language=user.get("language", req.language),
        region=user.get("region", "Default"),
    )


@app.post("/identity/auth/signup", response_model=AuthResponse)
def signup(req: SignupRequest) -> AuthResponse:
    user_key = req.username.strip().lower()
    if user_key in _USERS:
        raise HTTPException(status_code=409, detail="User already exists with this ID / Username")
    
    _USERS[user_key] = {
        "password": req.password,
        "name": req.name or req.username,
        "role": req.role,
        "region": req.region,
        "language": req.language,
        "additionalInfo": req.additionalInfo,
    }
    
    token = f"jwt-token-{secrets.token_hex(16)}"
    return AuthResponse(
        token=token,
        userId=user_key,
        name=req.name or req.username,
        role=req.role,
        language=req.language,
        region=req.region,
    )


@app.delete("/identity/{patient_id}")
def erase(patient_id: str) -> dict[str, bool]:
    """DPDP erasure: tombstone the identity. Telemetry is keyed by patientId and
    is purged separately by the telemetry service."""
    _DEVICES.pop(patient_id, None)
    return {"erased": True}

