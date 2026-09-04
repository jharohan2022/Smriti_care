# Architecture — SmritiCare

## 1. Design principles

1. **Offline-first, not offline-tolerant.** The patient never sees a spinner waiting
   on a network. Every write (game telemetry, routine completion) lands in a local
   Isar store first and is pushed later by the sync engine. The UI reads local state.
2. **Zero-authentication for patients.** A patient device is bound to an identity at
   provisioning time (ASHA-issued `deviceId` + server-issued `patientId`, stored in
   the OS keystore). No login screen ever. See §4.
3. **Zero-literacy UI.** Patient screens are photographic, icon-first, with TTS
   narration on every screen and tap targets ≥ 150×150 dp. No free text input.
4. **Graceful degradation everywhere.** Bhashini TTS unreachable → on-device TTS.
   Backend unreachable → local queue. A web query fails → typed error boundary with
   retry, never a blank screen.

## 2. High-level data flow

```
 Patient device (Flutter, patient flavor)
   │  plays memory game → GameTelemetryScreen captures reactionMs, spatialError
   │  writes TelemetryEvent → Isar (outbox)                     [always succeeds]
   │
   ├── (opportunistic) SyncManager batches outbox → POST /telemetry/batch
   │
 ASHA device (Flutter, asha flavor)                            [triage + ferry]
   │  pulls assigned patients, reviews compliance, forces sync when on wifi
   │
 ┌─────────────────────── Backend (FastAPI microservices) ───────────────────────┐
 │  gateway → identity-service (auth, device binding)                             │
 │          → telemetry-service (ingest, rolling baseline, anomaly z-score)       │
 │          → bhashini-gateway (TTS/ASR proxy + Redis cache)                      │
 │  PostgreSQL (system of record)   Redis (cache, rate-limit, sync locks)         │
 └────────────────────────────────────────────────────────────────────────────────┘
   │
 Doctor portal (React)  → reads baselines, drift analytics, exports DPDP reports
 Admin portal (React)   → reads /health of each service, manages ASHA↔patient links
```

## 3. Telemetry schema (the clinical signal)

`GameTelemetryScreen` emits one `TelemetryEvent` per game trial:

| field | type | meaning |
|-------|------|---------|
| `eventId` | uuid (client-generated) | idempotency key — dedupes retried batches |
| `patientId` | string | device-bound |
| `gameId` | string | which cognitive task |
| `reactionMs` | int | reaction time (primary drift signal) |
| `spatialErrorPx` | double | tap distance from target centroid |
| `patternErrors` | int | wrong selections in a recognition trial |
| `capturedAt` | int (epoch ms) | client clock; server also stamps `receivedAt` |
| `synced` | bool (local only) | outbox flag |

The **doctor portal** plots `reactionMs` ("Reaction Time Drift") and `patternErrors`
("Pattern Recognition Errors") as monthly rolling means against each patient's
personal baseline. The **telemetry-service** flags a patient when a rolling window
crosses `baseline + 2σ` (anomaly), which surfaces on the `ClinicalDashboard`.

## 4. Device-bound patient identity (zero-auth)

- Provisioning (done by ASHA, online): ASHA app calls `POST /identity/provision`
  with `{ashaId, patientProfile}` → server returns `{patientId, provisioningToken}`.
- The patient device stores `{patientId, deviceSecret}` in `flutter_secure_storage`
  (Android Keystore / iOS Keychain). All patient API calls sign with `deviceSecret`.
- The patient **never authenticates interactively**. Loss/reset is an ASHA-driven
  re-provision, not a patient-facing recovery flow.

## 5. Offline sync protocol (mobile)

- **Outbox pattern.** Every telemetry write is a row in Isar with `synced=false`.
- **Batched push.** `SyncManager` drains the outbox in batches of N (default 50)
  when connectivity is `online`, using client-generated `eventId`s so the endpoint
  is **idempotent** — a half-failed batch is safe to retry.
- **Backoff.** Exponential backoff with jitter on failure; state is observable
  (`SyncState.idle | syncing | offlineQueued | error`) and rendered by
  `OfflineSyncManager` on the ASHA panel.
- **No destructive local delete** until the server ACKs the `eventId`.

## 6. DPDP compliance notes (India Digital Personal Data Protection Act, 2023)

- **Data minimization.** Telemetry carries no free-text PII; patient names/photos
  live only in `identity-service` behind access control.
- **Purpose limitation + audit.** `PatientRecordsTable` export is logged
  (who/when/what patient) server-side.
- **Consent + erasure.** `identity-service` holds consent artifacts and supports
  erasure requests; telemetry is keyed by `patientId` so it can be tombstoned.
- **Regional data residency.** Deployments are region-scoped (see admin
  `RoleManagementScreen` → regional deployments).

## 7. Error boundaries

- **Mobile:** `ApiClient` maps Dio errors to a sealed `ApiFailure` (network, timeout,
  server, unauthorized). Screens render local data regardless; only explicit
  actions surface failures.
- **Web:** React Router `errorElement` + a React `ErrorBoundary` catch render errors;
  TanStack Query surfaces fetch errors through a `QueryBoundary` with retry; an
  `OfflineBanner` reflects `navigator.onLine`.
