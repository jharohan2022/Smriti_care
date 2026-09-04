import type { ServiceStatus } from "./tokens";

export interface ServiceHealth {
  id: string;
  name: string;
  kind: "gateway" | "bhashini" | "db-sync" | "service";
  status: ServiceStatus;
  uptimePct: number;
  latencyMs: number;
  lastChecked: string;
}

export interface LatencyPoint {
  label: string;
  latencyMs: number;
}

export interface Region {
  id: string;
  name: string;
  status: ServiceStatus;
  ashaCount: number;
  patientCount: number;
}

export interface AshaWorker {
  ashaId: string;
  name: string;
  region: string;
  assignedPatients: number;
}

export const delay = (ms: number) => new Promise((r) => setTimeout(r, ms));

export const mockServices: ServiceHealth[] = [
  { id: "gateway", name: "API Gateway", kind: "gateway", status: "up", uptimePct: 99.98, latencyMs: 42, lastChecked: "2026-09-03T10:31:00Z" },
  { id: "bhashini", name: "Bhashini TTS/ASR Gateway", kind: "bhashini", status: "degraded", uptimePct: 98.7, latencyMs: 620, lastChecked: "2026-09-03T10:31:00Z" },
  { id: "telemetry-sync", name: "Telemetry DB-Sync Endpoint", kind: "db-sync", status: "up", uptimePct: 99.95, latencyMs: 88, lastChecked: "2026-09-03T10:31:00Z" },
  { id: "identity", name: "Identity Service", kind: "service", status: "up", uptimePct: 99.99, latencyMs: 35, lastChecked: "2026-09-03T10:31:00Z" },
  { id: "postgres", name: "PostgreSQL (primary)", kind: "db-sync", status: "up", uptimePct: 99.99, latencyMs: 12, lastChecked: "2026-09-03T10:31:00Z" },
  { id: "redis", name: "Redis", kind: "service", status: "up", uptimePct: 99.97, latencyMs: 3, lastChecked: "2026-09-03T10:31:00Z" },
];

/** Deterministic 24h latency series for the Bhashini gateway (single series). */
export function mockGatewayLatency(): LatencyPoint[] {
  return Array.from({ length: 24 }, (_, h) => ({
    label: `${String(h).padStart(2, "0")}:00`,
    latencyMs: 380 + Math.round(Math.sin(h / 2) * 120 + (h > 18 ? 180 : 0)),
  }));
}

export const mockRegions: Region[] = [
  { id: "rj-barmer", name: "Barmer, Rajasthan", status: "up", ashaCount: 12, patientCount: 143 },
  { id: "od-koraput", name: "Koraput, Odisha", status: "degraded", ashaCount: 8, patientCount: 96 },
  { id: "kl-wayanad", name: "Wayanad, Kerala", status: "up", ashaCount: 6, patientCount: 71 },
];

export const mockAshaWorkers: AshaWorker[] = [
  { ashaId: "asha-01", name: "Sunita Meena", region: "rj-barmer", assignedPatients: 14 },
  { ashaId: "asha-02", name: "Pushpa Nag", region: "od-koraput", assignedPatients: 11 },
  { ashaId: "asha-03", name: "Rekha Nair", region: "kl-wayanad", assignedPatients: 9 },
  { ashaId: "asha-04", name: "Manju Devi", region: "rj-barmer", assignedPatients: 13 },
];
