// force HMR update
import { useParams, Link } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { QueryBoundary } from "../components/QueryBoundary";
import { fetchPatientRecords, qk } from "../lib/queries";
import { TelemetryAnalyticsChart } from "./TelemetryAnalyticsChart";

export function PatientReportPage() {
  const { patientId } = useParams<{ patientId: string }>();
  const query = useQuery({ queryKey: qk.records, queryFn: fetchPatientRecords });

  const handlePrint = () => {
    window.print();
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Link to="/records" className="text-sm font-medium text-[var(--series-1)] hover:underline">
          &larr; Back to Records
        </Link>
      </div>

      <QueryBoundary query={query}>
        {(records) => {
          const patient = records.find((r) => r.patientId === patientId);
          if (!patient) {
            return (
              <div className="rounded-lg border border-[var(--status-critical)] bg-red-500/10 p-6 text-center text-[var(--status-critical)]">
                Patient not found or you don't have access.
              </div>
            );
          }

          return (
            <div className="space-y-6">
              {/* Header Card */}
              <div className="flex flex-wrap items-start justify-between gap-4 rounded-xl border border-hairline bg-surface p-6 shadow-sm">
                <div>
                  <h1 className="text-2xl font-bold text-ink">{patient.name}</h1>
                  <p className="text-sm text-ink-secondary">
                    Patient ID: {patient.patientId} &middot; {patient.age} yrs &middot; {patient.region}
                  </p>
                  <div className="mt-4 flex flex-wrap gap-2">
                    <span className="inline-flex items-center rounded-full bg-sky-500/10 px-2.5 py-0.5 text-xs font-semibold text-[var(--series-1)] border border-[var(--series-1)]/20">
                      {patient.diagnosis}
                    </span>
                    <span className="inline-flex items-center rounded-full bg-slate-500/10 px-2.5 py-0.5 text-xs font-medium text-slate-400 border border-slate-500/20">
                      Last Assessment: {patient.lastAssessment}
                    </span>
                    {patient.consentOnFile ? (
                      <span className="inline-flex items-center rounded-full bg-emerald-500/10 px-2.5 py-0.5 text-xs font-medium text-[var(--status-good)] border border-[var(--status-good)]/20">
                        Consent: ✓ On file
                      </span>
                    ) : (
                      <span className="inline-flex items-center rounded-full bg-red-500/10 px-2.5 py-0.5 text-xs font-medium text-[var(--status-critical)] border border-[var(--status-critical)]/20">
                        Consent: ✕ Missing
                      </span>
                    )}
                  </div>
                </div>
                <button
                  onClick={handlePrint}
                  className="rounded-lg bg-[var(--series-1)] px-4 py-2 text-sm font-semibold text-white shadow-sm hover:opacity-90 print:hidden"
                >
                  Print Report
                </button>
              </div>

              {/* Analytics Section */}
              <div className="rounded-xl border border-hairline bg-surface p-6 shadow-sm">
                <TelemetryAnalyticsChart overridePatientId={patientId} />
              </div>

              {/* Current Regimen Section */}
              <div className="rounded-xl border border-hairline bg-surface p-6 shadow-sm">
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <h2 className="text-xl font-semibold text-ink">Current Regimen</h2>
                    <p className="text-sm text-ink-secondary">Active medications and clinical interventions.</p>
                  </div>
                  <button className="rounded-md border border-hairline bg-plane px-4 py-2 text-sm font-medium text-ink hover:bg-surface transition-colors">
                    Adjust Plan
                  </button>
                </div>
                
                <div className="bg-plane/50 rounded-lg p-4 border border-hairline/50">
                  <ul className="space-y-3">
                    {patientId === "p-1001" ? (
                      <>
                        <li className="flex items-start gap-3">
                          <span className="text-sky-500 mt-1">💊</span>
                          <div>
                            <div className="text-sm font-semibold text-ink">Donepezil 10mg</div>
                            <div className="text-xs text-ink-secondary">Once daily (OD) in the evening</div>
                          </div>
                        </li>
                        <li className="flex items-start gap-3">
                          <span className="text-sky-500 mt-1">💊</span>
                          <div>
                            <div className="text-sm font-semibold text-ink">Memantine 5mg</div>
                            <div className="text-xs text-ink-secondary">Twice daily (BD)</div>
                          </div>
                        </li>
                      </>
                    ) : (
                      <li className="flex items-start gap-3">
                        <span className="text-sky-500 mt-1">💊</span>
                        <div>
                          <div className="text-sm font-semibold text-ink">Standard Dementia Care Plan</div>
                          <div className="text-xs text-ink-secondary">Pending individualized review</div>
                        </div>
                      </li>
                    )}
                  </ul>
                </div>
              </div>
            </div>
          );
        }}
      </QueryBoundary>
    </div>
  );
}
