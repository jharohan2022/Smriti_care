import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../lib/authContext";

export function SignupPage() {
  const [name, setName] = useState("");
  const [username, setUsername] = useState("");
  const [department, setDepartment] = useState("National Health Mission / SIH");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      const res = await fetch("/api/identity/auth/signup", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          username,
          password,
          name,
          role: "admin",
          region: department,
        }),
      });

      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error(data.detail || "Registration failed. Try a different username.");
      }

      const user = await res.json();
      login(user);
      navigate("/");
    } catch (err: any) {
      setError(err.message || "Failed to register admin account.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-plane p-4">
      <div className="w-full max-w-md rounded-2xl border border-hairline bg-surface p-8 shadow-xl">
        <div className="mb-6 text-center">
          <div className="inline-flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-tr from-amber-500 to-rose-600 text-2xl text-white shadow-md">
            🛡️
          </div>
          <h1 className="mt-4 text-2xl font-bold tracking-tight text-ink">Admin Registration</h1>
          <p className="mt-1 text-sm text-ink-secondary">Provision new System Administrator credentials</p>
        </div>

        {error && (
          <div className="mb-4 rounded-lg bg-red-500/10 p-3 text-sm text-red-600 border border-red-500/20">
            {error}
          </div>
        )}

        <form onSubmit={handleSignup} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-ink-secondary mb-1">
              Administrator Full Name
            </label>
            <input
              type="text"
              required
              placeholder="e.g. Rajesh Sharma"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full rounded-lg border border-hairline bg-plane px-3 py-2 text-sm text-ink placeholder-ink-muted focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-ink-secondary mb-1">
              Admin Username / Operator ID
            </label>
            <input
              type="text"
              required
              placeholder="e.g. sysadmin.rajesh"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="w-full rounded-lg border border-hairline bg-plane px-3 py-2 text-sm text-ink placeholder-ink-muted focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-ink-secondary mb-1">
              Department / Ministry Jurisdiction
            </label>
            <input
              type="text"
              required
              placeholder="e.g. National Health Mission"
              value={department}
              onChange={(e) => setDepartment(e.target.value)}
              className="w-full rounded-lg border border-hairline bg-plane px-3 py-2 text-sm text-ink placeholder-ink-muted focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-ink-secondary mb-1">
              Master Password
            </label>
            <input
              type="password"
              required
              placeholder="Create secure admin password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full rounded-lg border border-hairline bg-plane px-3 py-2 text-sm text-ink placeholder-ink-muted focus:border-amber-500 focus:outline-none focus:ring-1 focus:ring-amber-500"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full rounded-lg bg-amber-600 py-2.5 text-sm font-semibold text-white shadow-md transition hover:bg-amber-500 disabled:opacity-50"
          >
            {loading ? "Registering Administrator..." : "Create Admin Credentials"}
          </button>
        </form>

        <div className="mt-6 text-center text-xs text-ink-secondary">
          Already have credentials?{" "}
          <Link to="/login" className="font-semibold text-amber-600 hover:underline">
            Sign In here
          </Link>
        </div>
      </div>
    </div>
  );
}
