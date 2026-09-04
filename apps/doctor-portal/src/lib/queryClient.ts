import { QueryClient } from "@tanstack/react-query";
import { ApiError } from "./api";

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60_000,
      // Don't hammer a down backend, and never retry a client/offline error.
      retry: (failureCount, error) => {
        if (error instanceof ApiError && (error.isOffline || error.status < 500)) {
          return false;
        }
        return failureCount < 2;
      },
      refetchOnWindowFocus: false,
    },
  },
});
