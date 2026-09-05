import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { useNavigate } from "react-router-dom";
import { QueryBoundary } from "../components/QueryBoundary";
import { useOnline } from "../components/OfflineBanner";
import { apiFetch, USE_MOCKS } from "../lib/api";
import { fetchPatientRecords, qk } from "../lib/queries";
import type { PatientRecord } from "../lib/mocks";

/** DPDP note: export is limited to records with consent on file, and every
 * export is audited (who/when/which patients) before the file is produced. */
async function logExport(patientIds: string[]): Promise<void> {
  if (USE_MOCKS) return;
  await apiFetch("/records/export-audit", {
    method: "POST",
    body: JSON.stringify({ patientIds, purpose: "clinical-review" }),
  });
}

function toCsv(rows: PatientRecord[]): string {
  const header = ["patientId", "name", "age", "region", "diagnosis", "lastAssessment"];
  const escape = (v: string | number) => `"${String(v).replace(/"/g, '""')}"`;
  const lines = rows.map((r) =>
    [r.patientId, r.name, r.age, r.region, r.diagnosis, r.lastAssessment].map(escape).join(","),
  );
  return [header.join(","), ...lines].join("\n");
}

export function PatientRecordsTable() {
  const navigate = useNavigate();
  const query = useQuery({ queryKey: qk.records, queryFn: fetchPatientRecords });
  const online = useOnline();
  const [exporting, setExporting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleExport(records: PatientRecord[]) {
    setError(null);
    const consented = records.filter((r) => r.consentOnFile);
    if (consented.length === 0) {
      setError("No records have consent on file to export.");
      return;
    }
    setExporting(true);
    try {
      await logExport(consented.map((r) => r.patientId)); // audit BEFORE producing data
      const blob = new Blob([toCsv(consented)], { type: "text/csv" });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `smarana-records-${new Date().toISOString().slice(0, 10)}.csv`;
      a.click();
      URL.revokeObjectURL(url);
    } catch {
      setError("Export could not be audited — aborted for compliance. Try again when online.");
    } finally {
      setExporting(false);
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-semibold text-ink">Patient records</h2>
          <p className="text-sm text-ink-secondary">
            Consent-gated · every export is audited (DPDP Act, 2023).
          </p>
        </div>
        <QueryBoundary query={query}>
          {(records) => (
            <button
              disabled={!online || exporting}
              onClick={() => handleExport(records)}
              className="rounded-md bg-[var(--series-1)] px-4 py-2 text-sm font-medium text-white disabled:opacity-40"
              title={online ? "Export consented records" : "Unavailable offline"}
            >
              {exporting ? "Exporting…" : "Export CSV"}
            </button>
          )}
        </QueryBoundary>
      </div>

      {error && (
        <div className="rounded-md border border-[var(--status-critical)] bg-[color-mix(in_srgb,var(--status-critical)_8%,transparent)] px-4 py-2 text-sm text-ink">
          {error}
        </div>
      )}

      <QueryBoundary query={query} isEmpty={(d) => d.length === 0}>
        {(records) => (
          <div className="overflow-hidden rounded-xl border border-hairline bg-surface">
            <table className="w-full text-sm">
              <thead className="border-b border-hairline text-left text-ink-muted">
                <tr>
                  <th className="px-4 py-3 font-medium">Patient</th>
                  <th className="px-4 py-3 font-medium">Age</th>
                  <th className="px-4 py-3 font-medium">Region</th>
                  <th className="px-4 py-3 font-medium">Diagnosis</th>
                  <th className="px-4 py-3 font-medium">Last assessment</th>
                  <th className="px-4 py-3 font-medium">Consent</th>
                </tr>
              </thead>
              <tbody>
                {records.map((r) => (
                  <tr 
                    key={r.patientId} 
                    onClick={() => navigate(`/records/${r.patientId}`)}
                    className="border-b border-hairline last:border-0 cursor-pointer hover:bg-white/5 transition-colors group"
                  >
                    <td className="px-4 py-3 font-medium text-[var(--series-1)] group-hover:underline">{r.name}</td>
                    <td className="px-4 py-3 tabular-nums text-ink-secondary">{r.age}</td>
                    <td className="px-4 py-3 text-ink-secondary">{r.region}</td>
                    <td className="px-4 py-3 text-ink-secondary">{r.diagnosis}</td>
                    <td className="px-4 py-3 tabular-nums text-ink-secondary">{r.lastAssessment}</td>
                    <td className="px-4 py-3">
                      {r.consentOnFile ? (
                        <span className="inline-flex items-center gap-1 text-[var(--status-good)]">
                          <span aria-hidden>✓</span> On file
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 text-[var(--status-critical)]">
                          <span aria-hidden>✕</span> Missing — excluded
                        </span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </QueryBoundary>
    </div>
  );
}
