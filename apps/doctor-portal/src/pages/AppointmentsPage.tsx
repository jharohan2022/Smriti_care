import { useState } from "react";

export function AppointmentsPage() {
  const [appointments, setAppointments] = useState([
    { id: 1, patient: "Kamala Devi", date: "2026-09-06", time: "10:30 AM", type: "Video Consult", status: "Upcoming", asha: "Meena Patel" },
    { id: 2, patient: "Ram Prasad", date: "2026-09-08", time: "02:00 PM", type: "Clinic Visit", status: "Pending", asha: "Sunita Verma" },
    { id: 3, patient: "Lakshmi N.", date: "2026-09-04", time: "11:00 AM", type: "Video Consult", status: "Completed", asha: "Priya Singh" },
  ]);

  const handleApprove = (id: number) => {
    setAppointments(appointments.map(apt => apt.id === id ? { ...apt, status: "Upcoming" } : apt));
  };

  const handleAction = (action: string) => {
    alert(`${action} functionality will be integrated with the backend API.`);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-semibold text-ink">Appointments & Scheduling</h2>
          <p className="text-sm text-ink-secondary">Manage upcoming video consultations and clinic visits.</p>
        </div>
        <button 
          onClick={() => handleAction('New Appointment modal')}
          className="rounded-md bg-[var(--series-1)] px-4 py-2 text-sm font-medium text-white hover:opacity-90"
        >
          + New Appointment
        </button>
      </div>

      <div className="overflow-hidden rounded-xl border border-hairline bg-surface">
        <table className="w-full text-sm">
          <thead className="border-b border-hairline text-left text-ink-muted">
            <tr>
              <th className="px-4 py-3 font-medium">Date & Time</th>
              <th className="px-4 py-3 font-medium">Patient</th>
              <th className="px-4 py-3 font-medium">Type</th>
              <th className="px-4 py-3 font-medium">ASHA Assigned</th>
              <th className="px-4 py-3 font-medium">Status</th>
              <th className="px-4 py-3 font-medium">Actions</th>
            </tr>
          </thead>
          <tbody>
            {appointments.map((apt) => (
              <tr key={apt.id} className="border-b border-hairline last:border-0 hover:bg-plane/50 transition-colors">
                <td className="px-4 py-3 font-medium text-ink">
                  {apt.date} <span className="text-ink-secondary font-normal ml-1">{apt.time}</span>
                </td>
                <td className="px-4 py-3 text-[var(--series-1)]">{apt.patient}</td>
                <td className="px-4 py-3 text-ink-secondary">
                  <span className="inline-flex items-center gap-1.5">
                    {apt.type === "Video Consult" ? "📹" : "🏥"} {apt.type}
                  </span>
                </td>
                <td className="px-4 py-3 text-ink-secondary">{apt.asha}</td>
                <td className="px-4 py-3">
                  {apt.status === "Upcoming" ? (
                    <span className="inline-flex rounded-full bg-sky-500/10 px-2.5 py-0.5 text-xs font-medium text-sky-600 border border-sky-500/20">
                      Upcoming
                    </span>
                  ) : apt.status === "Pending" ? (
                    <span className="inline-flex rounded-full bg-amber-500/10 px-2.5 py-0.5 text-xs font-medium text-amber-600 border border-amber-500/20">
                      Pending Approval
                    </span>
                  ) : (
                    <span className="inline-flex rounded-full bg-emerald-500/10 px-2.5 py-0.5 text-xs font-medium text-emerald-600 border border-emerald-500/20">
                      Completed
                    </span>
                  )}
                </td>
                <td className="px-4 py-3">
                  {apt.status === "Pending" ? (
                    <>
                      <button onClick={() => handleApprove(apt.id)} className="text-[var(--status-good)] hover:underline text-xs font-medium mr-3">Approve</button>
                      <button onClick={() => handleAction('Reschedule modal')} className="text-amber-500 hover:underline text-xs font-medium">Reschedule</button>
                    </>
                  ) : (
                    <>
                      <button onClick={() => handleAction('Edit appointment modal')} className="text-ink-secondary hover:underline text-xs font-medium mr-3">Edit</button>
                      {apt.status === "Upcoming" && (
                        <button onClick={() => handleAction('Join Video Call')} className="text-[var(--series-1)] hover:underline text-xs font-medium">Join Call</button>
                      )}
                    </>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
