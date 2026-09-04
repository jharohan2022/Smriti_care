import { apiFetch, USE_MOCKS } from "./api";
import {
  delay,
  mockAshaWorkers,
  mockGatewayLatency,
  mockRegions,
  mockServices,
  type AshaWorker,
  type LatencyPoint,
  type Region,
  type ServiceHealth,
} from "./mocks";

export async function fetchServiceHealth(): Promise<ServiceHealth[]> {
  if (USE_MOCKS) {
    await delay(400);
    return mockServices;
  }
  return apiFetch<ServiceHealth[]>("/admin/health");
}

export async function fetchGatewayLatency(): Promise<LatencyPoint[]> {
  if (USE_MOCKS) {
    await delay(400);
    return mockGatewayLatency();
  }
  return apiFetch<LatencyPoint[]>("/admin/bhashini/latency?window=24h");
}

export async function fetchRegions(): Promise<Region[]> {
  if (USE_MOCKS) {
    await delay(300);
    return mockRegions;
  }
  return apiFetch<Region[]>("/admin/regions");
}

export async function fetchAshaWorkers(): Promise<AshaWorker[]> {
  if (USE_MOCKS) {
    await delay(300);
    return mockAshaWorkers;
  }
  return apiFetch<AshaWorker[]>("/admin/asha");
}

/** Reassign an ASHA worker to a region. Optimistically updated by the caller. */
export async function reassignAsha(ashaId: string, region: string): Promise<void> {
  if (USE_MOCKS) {
    await delay(400);
    return;
  }
  await apiFetch(`/admin/asha/${ashaId}`, {
    method: "PATCH",
    body: JSON.stringify({ region }),
  });
}

export const qk = {
  health: ["health"] as const,
  latency: ["gateway-latency"] as const,
  regions: ["regions"] as const,
  asha: ["asha"] as const,
};
