import { Component, type ErrorInfo, type ReactNode } from "react";

interface Props {
  children: ReactNode;
  fallback?: (error: Error, reset: () => void) => ReactNode;
}
interface State {
  error: Error | null;
}

/** Catches render-time exceptions anywhere below it so a single broken widget
 * can't white-screen the whole portal. Pair with route-level errorElement for
 * loader/action errors. */
export class ErrorBoundary extends Component<Props, State> {
  state: State = { error: null };

  static getDerivedStateFromError(error: Error): State {
    return { error };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    // Wire to Sentry/OTel here.
    console.error("Render error:", error, info.componentStack);
  }

  reset = () => this.setState({ error: null });

  render() {
    const { error } = this.state;
    if (!error) return this.props.children;
    if (this.props.fallback) return this.props.fallback(error, this.reset);
    return (
      <div className="m-6 rounded-lg border border-[var(--status-critical)] bg-[color-mix(in_srgb,var(--status-critical)_8%,transparent)] p-6">
        <h2 className="text-lg font-semibold text-ink">Something went wrong</h2>
        <p className="mt-1 text-sm text-ink-secondary">{error.message}</p>
        <button
          onClick={this.reset}
          className="mt-4 rounded-md bg-[var(--series-1)] px-4 py-2 text-sm font-medium text-white"
        >
          Try again
        </button>
      </div>
    );
  }
}
