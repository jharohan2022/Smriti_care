import { useState } from "react";
import { NavLink, Outlet, useNavigate } from "react-router-dom";
import { OfflineBanner } from "./OfflineBanner";
import { useAuth } from "../lib/authContext";

const nav = [
  { to: "/", label: "Clinical Dashboard", end: true },
  { to: "/analytics", label: "Telemetry Analytics" },
  { to: "/records", label: "Patient Records" },
];

export function AppShell() {
  const [dark, setDark] = useState(
    () => document.documentElement.getAttribute("data-theme") === "dark",
  );
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const toggleTheme = () => {
    const next = dark ? "light" : "dark";
    document.documentElement.setAttribute("data-theme", next);
    setDark(!dark);
  };

  const handleLogout = () => {
    logout();
    navigate("/login");
  };

  return (
    <div className="flex h-full">
      <aside className="hidden w-64 shrink-0 flex-col border-r border-hairline bg-surface p-4 md:flex justify-between">
        <div>
          <div className="mb-6 px-2">
            <div className="text-lg font-bold text-ink flex items-center gap-2">
              <span className="text-xl">🩺</span> SmritiCare
            </div>
            <div className="text-xs text-ink-muted">Clinician & Neurology Portal</div>
          </div>
          <nav className="flex flex-col gap-1">
            {nav.map((n) => (
              <NavLink
                key={n.to}
                to={n.to}
                end={n.end}
                className={({ isActive }) =>
                  `rounded-md px-3 py-2 text-sm font-medium ${
                    isActive ? "bg-[var(--series-1)] text-white shadow-sm" : "text-ink-secondary hover:bg-plane"
                  }`
                }
              >
                {n.label}
              </NavLink>
            ))}
          </nav>
        </div>

        {/* Doctor User Badge */}
        <div className="border-t border-hairline pt-4">
          <div className="flex items-center gap-3 px-2 py-2">
            <div className="flex h-9 w-9 items-center justify-center rounded-full bg-sky-500/15 text-sm font-bold text-sky-600">
              {user?.name ? user.name.replace("Dr. ", "").charAt(0) : "D"}
            </div>
            <div className="min-w-0 flex-1">
              <div className="truncate text-xs font-semibold text-ink">{user?.name || "Dr. Aarav Sharma"}</div>
              <div className="truncate text-[11px] text-ink-muted">{user?.region || "AIIMS New Delhi"}</div>
            </div>
          </div>
          <button
            onClick={handleLogout}
            className="mt-2 w-full rounded-md border border-hairline px-3 py-1.5 text-xs font-medium text-red-500 hover:bg-red-500/10 transition text-left flex items-center justify-between"
          >
            <span>Sign Out</span>
            <span>⎋</span>
          </button>
        </div>
      </aside>

      <div className="flex min-w-0 flex-1 flex-col">
        <OfflineBanner />
        <header className="flex items-center justify-between border-b border-hairline bg-surface px-6 py-3">
          <h1 className="text-base font-semibold text-ink">Neurology · Cognitive Monitoring</h1>
          <div className="flex items-center gap-3">
            <span className="hidden sm:inline-block text-xs text-ink-secondary bg-plane px-2.5 py-1 rounded-full border border-hairline">
              Online: {user?.name || "Dr. Sharma"}
            </span>
            <button
              onClick={toggleTheme}
              className="rounded-md border border-hairline px-3 py-1.5 text-sm text-ink hover:bg-plane transition"
            >
              {dark ? "☀ Light" : "☾ Dark"}
            </button>
          </div>
        </header>
        <main className="min-h-0 flex-1 overflow-auto p-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
}

