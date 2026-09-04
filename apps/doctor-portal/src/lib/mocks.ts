import type { Severity } from "./tokens";

export interface AnomalyPatient {
  patientId: string;
  name: string;
  region: string;
  severity: Severity;
  metric: string;
  zScore: number;
  baselineReactionMs: number;
  currentReactionMs: number;
  lastUpdated: string;
}

export interface TelemetryPoint {
  /** ISO date at the start of the aggregation window (biweekly). */
  date: string;
  label: string;
  reactionMs: number; // rolling mean reaction time
  patternErrors: number; // rolling mean pattern-recognition errors
  baselineReactionMs: number; // patient's personal baseline (flat reference)
}

export interface PatientRecord {
  patientId: string;
  name: string;
  age: number;
  region: string;
  diagnosis: string;
  lastAssessment: string;
  consentOnFile: boolean;
}

export const delay = (ms: number) => new Promise((r) => setTimeout(r, ms));

export const mockAnomalyPatients: AnomalyPatient[] = [
  { patientId: "p-1001", name: "Kamala Devi", region: "Barmer, RJ", severity: "critical", metric: "Reaction Time Drift", zScore: 3.4, baselineReactionMs: 620, currentReactionMs: 940, lastUpdated: "2026-09-02" },
  { patientId: "p-1044", name: "Ganpat Singh", region: "Barmer, RJ", severity: "serious", metric: "Pattern Recognition Errors", zScore: 2.7, baselineReactionMs: 700, currentReactionMs: 815, lastUpdated: "2026-09-01" },
  { patientId: "p-1002", name: "Ram Prasad", region: "Koraput, OD", severity: "warning", metric: "Reaction Time Drift", zScore: 2.1, baselineReactionMs: 580, currentReactionMs: 665, lastUpdated: "2026-09-03" },
  { patientId: "p-1188", name: "Lakshmi N.", region: "Wayanad, KL", severity: "warning", metric: "Spatial Error", zScore: 2.0, baselineReactionMs: 540, currentReactionMs: 590, lastUpdated: "2026-08-30" },
];

/** Deterministic 6-month biweekly series with an upward drift + gentle noise.
 *  (`_patientId` is accepted for API parity; the mock series is identical.) */
export function mockTelemetrySeries(_patientId: string): TelemetryPoint[] {
  const baseline = 620;
  const points: TelemetryPoint[] = [];
  for (let i = 0; i < 12; i++) {
    const drift = i * 22; // steady worsening
    const noise = Math.round(Math.sin(i * 1.3) * 18); // deterministic wobble
    const d = new Date(2026, 2, 1 + i * 14); // Mar 2026 → ~Aug 2026
    points.push({
      date: d.toISOString().slice(0, 10),
      label: d.toLocaleDateString("en-IN", { month: "short", day: "numeric" }),
      reactionMs: baseline + drift + noise,
      patternErrors: Math.max(0, Math.round(1 + i * 0.4 + Math.sin(i) * 0.8)),
      baselineReactionMs: baseline,
    });
  }
  return points;
}

export const mockPatientRecords: PatientRecord[] = [
  { patientId: "p-1001", name: "Kamala Devi", age: 78, region: "Barmer, RJ", diagnosis: "Alzheimer's (moderate)", lastAssessment: "2026-09-02", consentOnFile: true },
  { patientId: "p-1002", name: "Ram Prasad", age: 71, region: "Koraput, OD", diagnosis: "MCI", lastAssessment: "2026-09-03", consentOnFile: true },
  { patientId: "p-1044", name: "Ganpat Singh", age: 83, region: "Barmer, RJ", diagnosis: "Vascular dementia", lastAssessment: "2026-09-01", consentOnFile: false },
  { patientId: "p-1188", name: "Lakshmi N.", age: 69, region: "Wayanad, KL", diagnosis: "MCI", lastAssessment: "2026-08-30", consentOnFile: true },
];
