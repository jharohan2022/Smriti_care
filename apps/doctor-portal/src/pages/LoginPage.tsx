import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../lib/authContext";

export function LoginPage() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const res = await fetch("/api/identity/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          username,
          password,
          role: "doctor",
        }),
      });

      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error(data.detail || "Authentication failed. Check your Doctor credentials.");
      }

      const user = await res.json();
      login(user);
      navigate("/");
    } catch (err: any) {
      setError(err.message || "Failed to log in.");
    } finally {
      setLoading(false);
    }
  };

  const handleQuickLogin = () => {
    setUsername("dr.sharma");
    setPassword("password123");
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-plane p-4">
      <div className="w-full max-w-md rounded-2xl border border-hairline bg-surface p-8 shadow-xl">
        <div className="mb-6 text-center">
          <div className="inline-flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-tr from-sky-500 to-indigo-600 text-2xl text-white shadow-md">
            🩺
          </div>
          <h1 className="mt-4 text-2xl font-bold tracking-tight text-ink">Smarana Clinician</h1>
          <p className="mt-1 text-sm text-ink-secondary">Neurologist & Doctor Clinical Portal</p>
        </div>

        {error && (
          <div className="mb-4 rounded-lg bg-red-500/10 p-3 text-sm text-red-600 border border-red-500/20">
            {error}
          </div>
        )}

        <form onSubmit={handleLogin} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-ink-secondary mb-1">
              Doctor ID / Username
            </label>
            <input
              type="text"
              required
              placeholder="e.g. dr.sharma"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="w-full rounded-lg border border-hairline bg-plane px-3 py-2 text-sm text-ink placeholder-ink-muted focus:border-sky-500 focus:outline-none focus:ring-1 focus:ring-sky-500"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-ink-secondary mb-1">
              Password
            </label>
            <input
              type="password"
              required
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full rounded-lg border border-hairline bg-plane px-3 py-2 text-sm text-ink placeholder-ink-muted focus:border-sky-500 focus:outline-none focus:ring-1 focus:ring-sky-500"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full rounded-lg bg-sky-600 py-2.5 text-sm font-semibold text-white shadow-md transition hover:bg-sky-500 disabled:opacity-50"
          >
            {loading ? "Verifying Credentials..." : "Sign In to Clinic"}
          </button>
        </form>

        <div className="mt-6 pt-4 border-t border-hairline">
          <button
            type="button"
            onClick={handleQuickLogin}
            className="w-full rounded-lg border border-dashed border-sky-400/50 bg-sky-500/5 py-2 text-xs font-medium text-sky-600 hover:bg-sky-500/10"
          >
            ⚡ Auto-fill Demo Neurologist Account (Dr. Sharma)
          </button>
        </div>

        <div className="mt-6 text-center text-xs text-ink-secondary">
          Don't have a clinician account?{" "}
          <Link to="/signup" className="font-semibold text-sky-600 hover:underline">
            Register as Doctor
          </Link>
        </div>
      </div>
    </div>
  );
}
