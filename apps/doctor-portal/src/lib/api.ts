/** The single transport-level error type the whole portal maps failures into. */
export class ApiError extends Error {
  constructor(
    public status: number,
    message: string,
  ) {
    super(message);
    this.name = "ApiError";
  }

  get isOffline() {
    return this.status === 0;
  }
}

/** fetch() wrapper: same-origin `/api/*` (proxied to the gateway), JSON in/out,
 * a hard timeout, and normalized errors. Never resolves on a non-2xx. */
export async function apiFetch<T>(path: string, init?: RequestInit): Promise<T> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 15_000);
  try {
    const res = await fetch(`/api${path}`, {
      ...init,
      signal: controller.signal,
      headers: { "Content-Type": "application/json", ...init?.headers },
    });
    if (!res.ok) {
      throw new ApiError(res.status, `Request failed (${res.status})`);
    }
    return res.status === 204 ? (undefined as T) : ((await res.json()) as T);
  } catch (err) {
    if (err instanceof ApiError) throw err;
    // AbortError, DNS failure, offline, CORS → collapse to a single shape.
    throw new ApiError(0, navigator.onLine ? "Network error" : "You are offline");
  } finally {
    clearTimeout(timeout);
  }
}

/** Flip with `VITE_USE_MOCKS=false` once the backend is wired up. Defaults on so
 * the portal is demoable immediately. */
export const USE_MOCKS = import.meta.env.VITE_USE_MOCKS !== "false";
