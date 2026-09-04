import { useQuery } from "@tanstack/react-query";
import { useSearchParams } from "react-router-dom";
import {
  CartesianGrid,
  Line,
  LineChart,
  ReferenceLine,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { QueryBoundary } from "../components/QueryBoundary";
import { fetchTelemetrySeries, qk } from "../lib/queries";
import { viz } from "../lib/tokens";
import type { TelemetryPoint } from "../lib/mocks";

const PATIENTS = [
  { id: "p-1001", name: "Kamala Devi" },
  { id: "p-1002", name: "Ram Prasad" },
  { id: "p-1044", name: "Ganpat Singh" },
  { id: "p-1188", name: "Lakshmi N." },
];

export function TelemetryAnalyticsChart() {
  const [params, setParams] = useSearchParams();
  const patientId = params.get("patient") ?? PATIENTS[0].id;
  const query = useQuery({
    queryKey: qk.series(patientId),
    queryFn: () => fetchTelemetrySeries(patientId),
  });

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-semibold text-ink">Cognitive telemetry — 6 month trend</h2>
          <p className="text-sm text-ink-secondary">Rolling biweekly means vs. personal baseline.</p>
        </div>
        <label className="flex items-center gap-2 text-sm text-ink-secondary">
          Patient
          <select
            value={patientId}
            onChange={(e) => setParams({ patient: e.target.value })}
            className="rounded-md border border-hairline bg-surface px-3 py-1.5 text-ink"
          >
            {PATIENTS.map((p) => (
              <option key={p.id} value={p.id}>
                {p.name}
              </option>
            ))}
          </select>
        </label>
      </div>

      <QueryBoundary query={query}>
        {(data) => (
          // Two small multiples — one measure per axis, never a dual y-axis.
          <div className="grid gap-6 xl:grid-cols-2">
            <TrendChart
              title="Reaction Time Drift"
              unit="ms"
              color={viz.series1}
              data={data}
              dataKey="reactionMs"
              baseline={data[0]?.baselineReactionMs}
            />
            <TrendChart
              title="Pattern Recognition Errors"
              unit="errors"
              color={viz.series2}
              data={data}
              dataKey="patternErrors"
            />
          </div>
        )}
      </QueryBoundary>
    </div>
  );
}

function TrendChart({
  title,
  unit,
  color,
  data,
  dataKey,
  baseline,
}: {
  title: string;
  unit: string;
  color: string;
  data: TelemetryPoint[];
  dataKey: keyof TelemetryPoint;
  baseline?: number;
}) {
  return (
    <figure className="rounded-xl border border-hairline bg-surface p-4">
      <figcaption className="mb-3 flex items-center gap-2">
        <span aria-hidden className="inline-block h-2.5 w-2.5 rounded-full" style={{ background: color }} />
        <span className="text-sm font-medium text-ink">{title}</span>
        <span className="text-xs text-ink-muted">({unit})</span>
      </figcaption>
      <div className="h-64">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data} margin={{ top: 8, right: 16, bottom: 4, left: 0 }}>
            <CartesianGrid stroke={viz.grid} vertical={false} />
            <XAxis
              dataKey="label"
              tick={{ fill: viz.axis, fontSize: 12 }}
              tickLine={false}
              axisLine={{ stroke: viz.baseline }}
            />
            <YAxis
              tick={{ fill: viz.axis, fontSize: 12 }}
              tickLine={false}
              axisLine={false}
              width={44}
            />
            {baseline != null && (
              <ReferenceLine
                y={baseline}
                stroke={viz.baseline}
                strokeDasharray="4 4"
                label={{ value: "Baseline", fill: viz.axis, fontSize: 11, position: "insideTopLeft" }}
              />
            )}
            <Tooltip content={<VizTooltip unit={unit} />} />
            <Line
              type="monotone"
              dataKey={dataKey}
              stroke={color}
              strokeWidth={2}
              dot={false}
              activeDot={{ r: 5, strokeWidth: 0 }}
              isAnimationActive={false}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </figure>
  );
}

interface TooltipProps {
  active?: boolean;
  payload?: Array<{ value: number; payload: TelemetryPoint }>;
  label?: string;
  unit: string;
}
function VizTooltip({ active, payload, label, unit }: TooltipProps) {
  if (!active || !payload?.length) return null;
  return (
    <div className="rounded-md border border-hairline bg-surface px-3 py-2 text-xs shadow-lg">
      <div className="mb-1 font-medium text-ink">{label}</div>
      <div className="tabular-nums text-ink-secondary">
        {payload[0].value} {unit}
      </div>
    </div>
  );
}
