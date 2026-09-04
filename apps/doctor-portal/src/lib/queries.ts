import { apiFetch, USE_MOCKS } from "./api";
import {
  delay,
  mockAnomalyPatients,
  mockPatientRecords,
  mockTelemetrySeries,
  type AnomalyPatient,
  type PatientRecord,
  type TelemetryPoint,
} from "./mocks";

/** Patients whose rolling cognitive metrics have crossed their baseline + 2σ. */
export async function fetchAnomalyPatients(): Promise<AnomalyPatient[]> {
  if (USE_MOCKS) {
    await delay(500);
    return mockAnomalyPatients;
  }
  return apiFetch<AnomalyPatient[]>("/telemetry/anomalies");
}

export async function fetchTelemetrySeries(patientId: string): Promise<TelemetryPoint[]> {
  if (USE_MOCKS) {
    await delay(500);
    return mockTelemetrySeries(patientId);
  }
  return apiFetch<TelemetryPoint[]>(`/telemetry/patients/${patientId}/series?window=6m`);
}

export async function fetchPatientRecords(): Promise<PatientRecord[]> {
  if (USE_MOCKS) {
    await delay(400);
    return mockPatientRecords;
  }
  return apiFetch<PatientRecord[]>("/records");
}

export const qk = {
  anomalies: ["anomalies"] as const,
  series: (id: string) => ["series", id] as const,
  records: ["records"] as const,
};
