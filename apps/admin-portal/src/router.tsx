import { createBrowserRouter, isRouteErrorResponse, Navigate, useRouteError } from "react-router-dom";
import { AppShell } from "./components/AppShell";
import { SystemHealthDashboard } from "./pages/SystemHealthDashboard";
import { RoleManagementScreen } from "./pages/RoleManagementScreen";
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
        ← Back to system health
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
      { path: "/", element: <SystemHealthDashboard /> },
      { path: "/roles", element: <RoleManagementScreen /> },
    ],
  },
]);

