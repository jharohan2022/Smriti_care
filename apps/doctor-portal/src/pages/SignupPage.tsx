import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../lib/authContext";

export function SignupPage() {
  const [name, setName] = useState("");
  const [username, setUsername] = useState("");
  const [hospital, setHospital] = useState("");
  const [specialty, setSpecialty] = useState("Neurology");
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
          role: "doctor",
          region: hospital,
          additionalInfo: { specialty },
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
      setError(err.message || "Failed to register doctor account.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-plane p-4">
      <div className="w-full max-w-md rounded-2xl border border-hairline bg-surface p-8 shadow-xl">
        <div className="mb-6 text-center">
          <div className="inline-flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-tr from-sky-500 to-indigo-600 text-2xl text-white shadow-md">
            🩺
          </div>
          <h1 className="mt-4 text-2xl font-bold tracking-tight text-ink">Clinician Registration</h1>
          <p className="mt-1 text-sm text-ink-secondary">Create your SmritiCare medical credentials</p>
        </div>

        {error && (
          <div className="mb-4 rounded-lg bg-red-500/10 p-3 text-sm text-red-600 border border-red-500/20">
            {error}
          </div>
        )}

        <form onSubmit={handleSignup} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-ink-secondary mb-1">
              Full Name (with Dr. prefix)
            </label>
            <input
              type="text"
              required
              placeholder="e.g. Dr. Priya Nair"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full rounded-lg border border-hairline bg-plane px-3 py-2 text-sm text-ink placeholder-ink-muted focus:border-sky-500 focus:outline-none focus:ring-1 focus:ring-sky-500"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-ink-secondary mb-1">
              Doctor Username / ID
            </label>
            <input
              type="text"
              required
              placeholder="e.g. dr.priya"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="w-full rounded-lg border border-hairline bg-plane px-3 py-2 text-sm text-ink placeholder-ink-muted focus:border-sky-500 focus:outline-none focus:ring-1 focus:ring-sky-500"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-semibold uppercase tracking-wider text-ink-secondary mb-1">
                Specialty
              </label>
              <select
                value={specialty}
                onChange={(e) => setSpecialty(e.target.value)}
                className="w-full rounded-lg border border-hairline bg-plane px-3 py-2 text-sm text-ink focus:border-sky-500 focus:outline-none focus:ring-1 focus:ring-sky-500"
              >
                <option value="Neurology">Neurology</option>
                <option value="Geriatrics">Geriatrics</option>
                <option value="Psychiatry">Psychiatry</option>
                <option value="General Medicine">General Medicine</option>
              </select>
            </div>
            <div>
              <label className="block text-xs font-semibold uppercase tracking-wider text-ink-secondary mb-1">
                Hospital / Institution
              </label>
              <input
                type="text"
                required
                placeholder="e.g. NIMHANS"
                value={hospital}
                onChange={(e) => setHospital(e.target.value)}
                className="w-full rounded-lg border border-hairline bg-plane px-3 py-2 text-sm text-ink placeholder-ink-muted focus:border-sky-500 focus:outline-none focus:ring-1 focus:ring-sky-500"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-ink-secondary mb-1">
              Password
            </label>
            <input
              type="password"
              required
              placeholder="Create strong password"
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
            {loading ? "Registering Profile..." : "Create Clinician Profile"}
          </button>
        </form>

        <div className="mt-6 text-center text-xs text-ink-secondary">
          Already registered?{" "}
          <Link to="/login" className="font-semibold text-sky-600 hover:underline">
            Sign In here
          </Link>
        </div>
      </div>
    </div>
  );
}
