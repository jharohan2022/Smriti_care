import type { ReactNode } from "react";
import { ApiError } from "../lib/api";

interface QueryLike<T> {
  isPending: boolean;
  isError: boolean;
  error: unknown;
  data: T | undefined;
  refetch: () => void;
}

/** Standardizes the loading / error / empty / data states for a TanStack query
 * so every page renders network states the same way. */
export function QueryBoundary<T>({
  query,
  children,
  isEmpty,
  emptyLabel = "No data yet.",
}: {
  query: QueryLike<T>;
  children: (data: T) => ReactNode;
  isEmpty?: (data: T) => boolean;
  emptyLabel?: string;
}) {
  if (query.isPending) {
    return (
      <div className="flex h-48 items-center justify-center text-ink-muted">
        <span className="animate-pulse">Loading…</span>
      </div>
    );
  }

  if (query.isError) {
    const err = query.error;
    const message =
      err instanceof ApiError
        ? err.isOffline
          ? "You appear to be offline."
          : err.message
        : "Unexpected error.";
    return (
      <div className="flex h-48 flex-col items-center justify-center gap-3 text-center">
        <p className="text-ink-secondary">{message}</p>
        <button
          onClick={() => query.refetch()}
          className="rounded-md border border-hairline px-4 py-2 text-sm font-medium text-ink hover:bg-plane"
        >
          Retry
        </button>
      </div>
    );
  }

  const data = query.data as T;
  if (isEmpty?.(data)) {
    return <div className="flex h-48 items-center justify-center text-ink-muted">{emptyLabel}</div>;
  }

  return <>{children(data)}</>;
}
