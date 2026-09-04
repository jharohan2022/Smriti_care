import { useEffect, useState } from "react";

/** Tracks the browser's connectivity. */
export function useOnline() {
  const [online, setOnline] = useState(navigator.onLine);
  useEffect(() => {
    const on = () => setOnline(true);
    const off = () => setOnline(false);
    window.addEventListener("online", on);
    window.addEventListener("offline", off);
    return () => {
      window.removeEventListener("online", on);
      window.removeEventListener("offline", off);
    };
  }, []);
  return online;
}

/** A slim banner shown only while offline. Clinical data may be stale — say so
 * rather than pretending everything is live. */
export function OfflineBanner() {
  const online = useOnline();
  if (online) return null;
  return (
    <div
      role="status"
      className="flex items-center justify-center gap-2 bg-[var(--status-warning)] px-4 py-1.5 text-sm font-medium text-black"
    >
      <span aria-hidden>⚠</span>
      You are offline — showing the last loaded data. Live updates are paused.
    </div>
  );
}
