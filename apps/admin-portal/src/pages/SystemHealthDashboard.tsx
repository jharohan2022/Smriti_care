import { useQuery } from "@tanstack/react-query";
import {
  Area,
  AreaChart,
  CartesianGrid,
  ReferenceLine,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { QueryBoundary } from "../components/QueryBoundary";
import { fetchGatewayLatency, fetchServiceHealth, qk } from "../lib/queries";
import { serviceStatus, viz, type ServiceStatus } from "../lib/tokens";
import type { ServiceHealth } from "../lib/mocks";

const SLA_MS = 500;

export function SystemHealthDashboard() {
  const health = useQuery({ queryKey: qk.health, queryFn: fetchServiceHealth, refetchInterval: 30_000 });
  const latency = useQuery({ queryKey: qk.latency, queryFn: fetchGatewayLatency });

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-xl font-semibold text-ink">System health</h2>
        <p className="text-sm text-ink-secondary">
          Microservice uptime — including the Bhashini TTS/ASR gateway and DB-sync endpoints.
        </p>
      </div>

      <QueryBoundary query={health} isEmpty={(d) => d.length === 0}>
        {(services) => (
          <>
            <HealthTiles services={services} />
            <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
              {services.map((s) => (
                <ServiceCard key={s.id} service={s} />
              ))}
            </div>
          </>
        )}
      </QueryBoundary>

      <figure className="rounded-xl border border-hairline bg-surface p-4">
        <figcaption className="mb-3 flex items-center gap-2">
          <span aria-hidden className="inline-block h-2.5 w-2.5 rounded-full" style={{ background: viz.series1 }} />
          <span className="text-sm font-medium text-ink">Bhashini gateway latency</span>
          <span className="text-xs text-ink-muted">(ms, last 24h · SLA {SLA_MS}ms)</span>
        </figcaption>
        <div className="h-56">
          <QueryBoundary query={latency}>
            {(points) => (
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={points} margin={{ top: 8, right: 16, bottom: 4, left: 0 }}>
                  <defs>
                    <linearGradient id="lat" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor={viz.series1} stopOpacity={0.28} />
                      <stop offset="100%" stopColor={viz.series1} stopOpacity={0.02} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid stroke={viz.grid} vertical={false} />
                  <XAxis dataKey="label" tick={{ fill: viz.axis, fontSize: 12 }} tickLine={false} axisLine={{ stroke: viz.baseline }} interval={3} />
                  <YAxis tick={{ fill: viz.axis, fontSize: 12 }} tickLine={false} axisLine={false} width={44} />
                  <ReferenceLine y={SLA_MS} stroke={viz.baseline} strokeDasharray="4 4" label={{ value: "SLA", fill: viz.axis, fontSize: 11, position: "insideTopLeft" }} />
                  <Tooltip
                    contentStyle={{ background: viz.surface, border: "1px solid var(--gridline)", borderRadius: 8, fontSize: 12 }}
                    labelStyle={{ color: "var(--text-primary)" }}
                  />
                  <Area type="monotone" dataKey="latencyMs" stroke={viz.series1} strokeWidth={2} fill="url(#lat)" isAnimationActive={false} />
                </AreaChart>
              </ResponsiveContainer>
            )}
          </QueryBoundary>
        </div>
      </figure>
    </div>
  );
}

function HealthTiles({ services }: { services: ServiceHealth[] }) {
  const count = (s: ServiceStatus) => services.filter((x) => x.status === s).length;
  const avgUptime = (services.reduce((a, s) => a + s.uptimePct, 0) / services.length).toFixed(2);
  const tiles = [
    { label: "Avg uptime", value: `${avgUptime}%` },
    { label: serviceStatus.up.label, value: count("up"), status: "up" as const },
    { label: serviceStatus.degraded.label, value: count("degraded"), status: "degraded" as const },
    { label: serviceStatus.down.label, value: count("down"), status: "down" as const },
  ];
  return (
    <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
      {tiles.map((t) => (
        <div key={t.label} className="rounded-xl border border-hairline bg-surface p-4">
          <div className="flex items-center gap-2">
            {"status" in t && t.status && (
              <span aria-hidden className="inline-block h-2.5 w-2.5 rounded-full" style={{ background: serviceStatus[t.status].color }} />
            )}
            <span className="text-sm text-ink-secondary">{t.label}</span>
          </div>
          <div className="mt-2 text-3xl font-semibold tabular-nums text-ink">{t.value}</div>
        </div>
      ))}
    </div>
  );
}

export function StatusBadge({ status }: { status: ServiceStatus }) {
  const s = serviceStatus[status];
  return (
    <span
      className="inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium"
      style={{ color: s.color, background: `color-mix(in srgb, ${s.color} 12%, transparent)` }}
    >
      <span aria-hidden>{s.icon}</span>
      {s.label}
    </span>
  );
}

function ServiceCard({ service }: { service: ServiceHealth }) {
  const overSla = service.latencyMs > SLA_MS;
  return (
    <div className="rounded-xl border border-hairline bg-surface p-4">
      <div className="flex items-start justify-between gap-2">
        <div>
          <div className="font-medium text-ink">{service.name}</div>
          <div className="text-xs uppercase tracking-wide text-ink-muted">{service.kind}</div>
        </div>
        <StatusBadge status={service.status} />
      </div>
      <div className="mt-4 grid grid-cols-2 gap-2 text-sm">
        <div>
          <div className="text-ink-muted">Uptime</div>
          <div className="tabular-nums text-ink">{service.uptimePct}%</div>
        </div>
        <div>
          <div className="text-ink-muted">Latency</div>
          <div className={`tabular-nums ${overSla ? "text-[var(--status-serious)]" : "text-ink"}`}>{service.latencyMs} ms</div>
        </div>
      </div>
    </div>
  );
}
