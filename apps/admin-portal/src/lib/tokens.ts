export const viz = {
  series1: "var(--series-1)",
  series2: "var(--series-2)",
  grid: "var(--gridline)",
  baseline: "var(--baseline)",
  axis: "var(--text-muted)",
  text: "var(--text-secondary)",
  surface: "var(--surface-1)",
} as const;

export type ServiceStatus = "up" | "degraded" | "down";

export const serviceStatus: Record<ServiceStatus, { color: string; label: string; icon: string }> = {
  up: { color: "var(--status-good)", label: "Operational", icon: "✓" },
  degraded: { color: "var(--status-warning)", label: "Degraded", icon: "●" },
  down: { color: "var(--status-critical)", label: "Down", icon: "▲" },
};
