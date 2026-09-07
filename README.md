# Smarana — AI MedTech Platform for Dementia Care in Remote Regions

> _Smriti (स्मृति) = "memory". An offline-first platform connecting elderly dementia
> patients, ASHA/caregivers, neurologists, and system administrators._

This is a **monorepo** containing four role-specific frontends and a microservices
backend. The design north-star is **offline-first**: the patient/ASHA mobile app is
fully functional without connectivity and reconciles with the backend opportunistically.

## Roles → Apps

| Role | Surface | Stack | Location |
|------|---------|-------|----------|
| **Patient** | Mobile | Flutter + Riverpod + Isar | `apps/mobile` (flavor `patient`) |
| **ASHA / Caregiver** | Mobile | Flutter + Riverpod + Isar | `apps/mobile` (flavor `asha`) |
| **Doctor / Neurologist** | Web | React + TS + Tailwind + Recharts | `apps/doctor-portal` |
| **Admin** | Web | React + TS + Tailwind + Recharts | `apps/admin-portal` |
| **Backend** | Services | FastAPI + PostgreSQL + Redis + Bhashini | `services/*` |

The Patient and ASHA panels ship from **one Flutter codebase** using
[flavors](https://docs.flutter.dev/deployment/flavors) (`main_patient.dart`,
`main_asha.dart`). They share the offline database, sync engine, connectivity
service and Bhashini TTS client — the ASHA app is the device that ferries a
patient's telemetry to the backend, so co-locating the sync core avoids drift.

## Monorepo layout

```
SIH/
├── README.md
├── docs/
│   └── ARCHITECTURE.md            # data flow, offline-sync protocol, DPDP notes
├── infra/
│   └── docker-compose.yml         # postgres, redis, all services, portals
├── apps/
│   ├── mobile/                    # Flutter — Patient + ASHA (flavors)
│   │   ├── pubspec.yaml
│   │   └── lib/
│   │       ├── main_patient.dart          # entrypoint → patient flavor
│   │       ├── main_asha.dart             # entrypoint → asha flavor
│   │       ├── bootstrap.dart             # shared app boot (DI, Isar, ProviderScope)
│   │       ├── core/
│   │       │   ├── config/flavor_config.dart
│   │       │   ├── router/patient_router.dart
│   │       │   ├── router/asha_router.dart
│   │       │   ├── theme/app_theme.dart
│   │       │   ├── services/tts_service.dart          # Bhashini + on-device fallback
│   │       │   ├── services/connectivity_service.dart
│   │       │   ├── services/device_identity_service.dart
│   │       │   ├── database/isar_service.dart
│   │       │   ├── database/models/{telemetry_event,patient_local,sync_envelope}.dart
│   │       │   ├── sync/sync_manager.dart             # batched, resumable outbox
│   │       │   └── api/api_client.dart                # Dio + typed error boundary
│   │       └── features/
│   │           ├── patient/
│   │           │   ├── welcome/patient_welcome_screen.dart
│   │           │   ├── dashboard/easy_dashboard_screen.dart
│   │           │   ├── games/game_telemetry_screen.dart
│   │           │   └── widgets/{giant_button,photo_card,tts_narrator}.dart
│   │           └── asha/
│   │               ├── patients/patient_list_screen.dart
│   │               ├── patients/patient_detail_screen.dart
│   │               ├── sync/offline_sync_manager.dart
│   │               └── widgets/status_dot.dart
│   ├── doctor-portal/             # React + Vite + TS
│   │   └── src/
│   │       ├── main.tsx / App.tsx / router.tsx
│   │       ├── lib/{api,queryClient,tokens}.ts
│   │       ├── components/{ErrorBoundary,OfflineBanner,AppShell,QueryBoundary}.tsx
│   │       └── pages/{ClinicalDashboard,TelemetryAnalyticsChart,PatientRecordsTable}.tsx
│   └── admin-portal/              # React + Vite + TS
│       └── src/
│           ├── main.tsx / App.tsx / router.tsx
│           ├── lib/{api,queryClient,tokens}.ts
│           ├── components/{ErrorBoundary,OfflineBanner,AppShell}.tsx
│           └── pages/{SystemHealthDashboard,RoleManagementScreen}.tsx
├── services/
│   ├── gateway/                   # BFF / auth edge / request fan-out
│   ├── telemetry-service/         # ingest game telemetry, run anomaly detection
│   ├── identity-service/          # device-bound patient identity, ASHA/doctor auth
│   ├── bhashini-gateway/          # proxy + cache for Bhashini TTS/ASR
│   └── shared/                    # pydantic schemas, db session, health protocol
└── packages/
    └── ts-shared/                 # shared TypeScript domain types for both portals
```

## Quick start

```bash
# Backend + databases
docker compose -f infra/docker-compose.yml up -d

# Doctor portal
cd apps/doctor-portal && npm install && npm run dev

# Admin portal
cd apps/admin-portal && npm install && npm run dev

# Mobile (Patient flavor)
cd apps/mobile && flutter pub get && flutter run --flavor patient -t lib/main_patient.dart

# Mobile (ASHA flavor)
cd apps/mobile && flutter run --flavor asha -t lib/main_asha.dart
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the offline-sync protocol,
telemetry schema, and DPDP (Digital Personal Data Protection Act) handling.
