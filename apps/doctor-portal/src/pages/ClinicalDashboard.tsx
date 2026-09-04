import { useQuery } from "@tanstack/react-query";
import { Link } from "react-router-dom";
import { QueryBoundary } from "../components/QueryBoundary";
import { fetchAnomalyPatients, qk } from "../lib/queries";
import { severity, type Severity } from "../lib/tokens";
import type { AnomalyPatient } from "../lib/mocks";

export function ClinicalDashboard() {
  const query = useQuery({ queryKey: qk.anomalies, queryFn: fetchAnomalyPatients });

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-xl font-semibold text-ink">Active cognitive anomalies</h2>
        <p className="text-sm text-ink-secondary">
          Patients whose rolling telemetry has crossed their personal baseline + 2σ.
        </p>
      </div>

      <QueryBoundary query={query} isEmpty={(d) => d.length === 0} emptyLabel="No active anomalies 🎉">
        {(patients) => (
          <>
            <StatTiles patients={patients} />
            <AnomalyTable patients={patients} />
          </>
        )}
      </QueryBoundary>
    </div>
  );
}

function StatTiles({ patients }: { patients: AnomalyPatient[] }) {
  const count = (s: Severity) => patients.filter((p) => p.severity === s).length;
  const tiles: { label: string; value: number; sev?: Severity }[] = [
    { label: "Monitored", value: patients.length },
    { label: severity.critical.label, value: count("critical"), sev: "critical" },
    { label: severity.serious.label, value: count("serious"), sev: "serious" },
    { label: severity.warning.label, value: count("warning"), sev: "warning" },
  ];
  return (
    <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
      {tiles.map((t) => (
        <div key={t.label} className="rounded-xl border border-hairline bg-surface p-4">
          <div className="flex items-center gap-2">
            {t.sev && (
              <span
                aria-hidden
                className="inline-block h-2.5 w-2.5 rounded-full"
                style={{ background: severity[t.sev].color }}
              />
            )}
            <span className="text-sm text-ink-secondary">{t.label}</span>
          </div>
          <div className="mt-2 text-3xl font-semibold tabular-nums text-ink">{t.value}</div>
        </div>
      ))}
    </div>
  );
}

export function SeverityBadge({ sev }: { sev: Severity }) {
  const s = severity[sev];
  // Icon + label + color — status is never conveyed by color alone.
  const icon = sev === "critical" ? "▲" : sev === "serious" ? "◆" : sev === "warning" ? "●" : "✓";
  return (
    <span
      className="inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium"
      style={{ color: s.color, background: `color-mix(in srgb, ${s.color} 12%, transparent)` }}
    >
      <span aria-hidden>{icon}</span>
      {s.label}
    </span>
  );
}

function AnomalyTable({ patients }: { patients: AnomalyPatient[] }) {
  return (
    <div className="overflow-hidden rounded-xl border border-hairline bg-surface">
      <table className="w-full text-sm">
        <thead className="border-b border-hairline text-left text-ink-muted">
          <tr>
            <th className="px-4 py-3 font-medium">Patient</th>
            <th className="px-4 py-3 font-medium">Region</th>
            <th className="px-4 py-3 font-medium">Signal</th>
            <th className="px-4 py-3 text-right font-medium">z-score</th>
            <th className="px-4 py-3 text-right font-medium">Baseline → Current</th>
            <th className="px-4 py-3 font-medium">Severity</th>
            <th className="px-4 py-3" />
          </tr>
        </thead>
        <tbody>
          {patients.map((p) => (
            <tr key={p.patientId} className="border-b border-hairline last:border-0">
              <td className="px-4 py-3 font-medium text-ink">{p.name}</td>
              <td className="px-4 py-3 text-ink-secondary">{p.region}</td>
              <td className="px-4 py-3 text-ink-secondary">{p.metric}</td>
              <td className="px-4 py-3 text-right tabular-nums text-ink">{p.zScore.toFixed(1)}</td>
              <td className="px-4 py-3 text-right tabular-nums text-ink-secondary">
                {p.baselineReactionMs} → <span className="font-semibold text-ink">{p.currentReactionMs} ms</span>
              </td>
              <td className="px-4 py-3">
                <SeverityBadge sev={p.severity} />
              </td>
              <td className="px-4 py-3 text-right">
                <Link
                  to={`/analytics?patient=${p.patientId}`}
                  className="text-sm font-medium text-[var(--series-1)] hover:underline"
                >
                  View trend →
                </Link>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
