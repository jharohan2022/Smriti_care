import { createBrowserRouter, isRouteErrorResponse, Navigate, useRouteError } from "react-router-dom";
import { AppShell } from "./components/AppShell";
import { ClinicalDashboard } from "./pages/ClinicalDashboard";
import { PatientRecordsTable } from "./pages/PatientRecordsTable";
import { TelemetryAnalyticsChart } from "./pages/TelemetryAnalyticsChart";
import { LoginPage } from "./pages/LoginPage";
import { SignupPage } from "./pages/SignupPage";
import { useAuth } from "./lib/authContext";

function RequireAuth({ children }: { children: JSX.Element }) {
  const { isAuthenticated } = useAuth();
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  return children;
}

/** Route-level error boundary for loader/render failures within the shell. */
function RouteError() {
  const error = useRouteError();
  const message = isRouteErrorResponse(error)
    ? `${error.status} ${error.statusText}`
    : error instanceof Error
      ? error.message
      : "Unknown error";
  return (
    <div className="p-10 text-center">
      <h2 className="text-lg font-semibold text-ink">This page failed to load</h2>
      <p className="mt-1 text-sm text-ink-secondary">{message}</p>
      <a href="/" className="mt-4 inline-block text-sm font-medium text-[var(--series-1)] hover:underline">
        ← Back to dashboard
      </a>
    </div>
  );
}

export const router = createBrowserRouter([
  {
    path: "/login",
    element: <LoginPage />,
  },
  {
    path: "/signup",
    element: <SignupPage />,
  },
  {
    element: (
      <RequireAuth>
        <AppShell />
      </RequireAuth>
    ),
    errorElement: <RouteError />,
    children: [
      { path: "/", element: <ClinicalDashboard /> },
      { path: "/analytics", element: <TelemetryAnalyticsChart /> },
      { path: "/records", element: <PatientRecordsTable /> },
    ],
  },
]);

