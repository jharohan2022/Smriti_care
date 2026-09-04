// Chart roles map to the CSS variables in index.css, so light/dark swap in one
// place and Recharts is written against roles, never raw hex.
export const viz = {
  series1: "var(--series-1)", // Reaction Time Drift
  series2: "var(--series-2)", // Pattern Recognition Errors
  grid: "var(--gridline)",
  baseline: "var(--baseline)",
  axis: "var(--text-muted)",
  text: "var(--text-secondary)",
  surface: "var(--surface-1)",
} as const;

export type Severity = "good" | "warning" | "serious" | "critical";

export const severity: Record<Severity, { color: string; label: string }> = {
  good: { color: "var(--status-good)", label: "Stable" },
  warning: { color: "var(--status-warning)", label: "Watch" },
  serious: { color: "var(--status-serious)", label: "Concerning" },
  critical: { color: "var(--status-critical)", label: "Critical" },
};
