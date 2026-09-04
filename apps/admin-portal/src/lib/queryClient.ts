import { QueryClient } from "@tanstack/react-query";
import { ApiError } from "./api";

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 15_000, // health data should feel fresher than clinical data
      retry: (failureCount, error) => {
        if (error instanceof ApiError && (error.isOffline || error.status < 500)) return false;
        return failureCount < 2;
      },
      refetchOnWindowFocus: true,
    },
  },
});
