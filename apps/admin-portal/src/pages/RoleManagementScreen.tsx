import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { QueryBoundary } from "../components/QueryBoundary";
import { StatusBadge } from "./SystemHealthDashboard";
import { fetchAshaWorkers, fetchRegions, qk, reassignAsha } from "../lib/queries";
import type { AshaWorker, Region } from "../lib/mocks";

export function RoleManagementScreen() {
  const regions = useQuery({ queryKey: qk.regions, queryFn: fetchRegions });
  const asha = useQuery({ queryKey: qk.asha, queryFn: fetchAshaWorkers });

  return (
    <div className="space-y-8">
      <div>
        <h2 className="text-xl font-semibold text-ink">Roles &amp; regional deployments</h2>
        <p className="text-sm text-ink-secondary">
          Assign ASHA workers to regions and monitor per-region deployment health.
        </p>
      </div>

      <section className="space-y-3">
        <h3 className="text-sm font-semibold uppercase tracking-wide text-ink-muted">Regional deployments</h3>
        <QueryBoundary query={regions} isEmpty={(d) => d.length === 0}>
          {(rows) => <RegionsTable regions={rows} />}
        </QueryBoundary>
      </section>

      <section className="space-y-3">
        <h3 className="text-sm font-semibold uppercase tracking-wide text-ink-muted">ASHA worker assignments</h3>
        <QueryBoundary query={asha} isEmpty={(d) => d.length === 0}>
          {(workers) => <AshaTable workers={workers} regions={regions.data ?? []} />}
        </QueryBoundary>
      </section>
    </div>
  );
}

function RegionsTable({ regions }: { regions: Region[] }) {
  return (
    <div className="overflow-hidden rounded-xl border border-hairline bg-surface">
      <table className="w-full text-sm">
        <thead className="border-b border-hairline text-left text-ink-muted">
          <tr>
            <th className="px-4 py-3 font-medium">Region</th>
            <th className="px-4 py-3 font-medium">Status</th>
            <th className="px-4 py-3 text-right font-medium">ASHA workers</th>
            <th className="px-4 py-3 text-right font-medium">Patients</th>
          </tr>
        </thead>
        <tbody>
          {regions.map((r) => (
            <tr key={r.id} className="border-b border-hairline last:border-0">
              <td className="px-4 py-3 font-medium text-ink">{r.name}</td>
              <td className="px-4 py-3"><StatusBadge status={r.status} /></td>
              <td className="px-4 py-3 text-right tabular-nums text-ink-secondary">{r.ashaCount}</td>
              <td className="px-4 py-3 text-right tabular-nums text-ink-secondary">{r.patientCount}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function AshaTable({ workers, regions }: { workers: AshaWorker[]; regions: Region[] }) {
  const qc = useQueryClient();
  const mutation = useMutation({
    mutationFn: ({ ashaId, region }: { ashaId: string; region: string }) => reassignAsha(ashaId, region),
    onSuccess: () => qc.invalidateQueries({ queryKey: qk.asha }),
  });

  return (
    <div className="overflow-hidden rounded-xl border border-hairline bg-surface">
      <table className="w-full text-sm">
        <thead className="border-b border-hairline text-left text-ink-muted">
          <tr>
            <th className="px-4 py-3 font-medium">ASHA worker</th>
            <th className="px-4 py-3 text-right font-medium">Assigned patients</th>
            <th className="px-4 py-3 font-medium">Region</th>
          </tr>
        </thead>
        <tbody>
          {workers.map((w) => {
            const pending = mutation.isPending && mutation.variables?.ashaId === w.ashaId;
            return (
              <tr key={w.ashaId} className="border-b border-hairline last:border-0">
                <td className="px-4 py-3 font-medium text-ink">{w.name}</td>
                <td className="px-4 py-3 text-right tabular-nums text-ink-secondary">{w.assignedPatients}</td>
                <td className="px-4 py-3">
                  <select
                    defaultValue={w.region}
                    disabled={pending}
                    onChange={(e) => mutation.mutate({ ashaId: w.ashaId, region: e.target.value })}
                    className="rounded-md border border-hairline bg-surface px-2 py-1 text-ink disabled:opacity-50"
                  >
                    {regions.map((r) => (
                      <option key={r.id} value={r.id}>
                        {r.name}
                      </option>
                    ))}
                  </select>
                  {pending && <span className="ml-2 text-xs text-ink-muted">saving…</span>}
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
      {mutation.isError && (
        <div className="border-t border-hairline px-4 py-2 text-sm text-[var(--status-critical)]">
          Could not save the assignment — please retry.
        </div>
      )}
    </div>
  );
}
