import { useState } from "react";
import { useNavigate } from "react-router-dom";

export function MessagesPage() {
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const navigate = useNavigate();

  const messages = [
    { 
      id: 1, 
      sender: "Meena Patel (ASHA)", 
      patient: "Kamala Devi",
      patientId: "p-1001",
      patientInfo: "78 yrs • Alzheimer's (moderate) • Barmer, RJ",
      date: "Today, 09:15 AM", 
      subject: "Patient refusing to play games this week", 
      read: false,
      body: "Dr. Sharma, Kamala has been very agitated the last two days and refuses to open the app. Her family says she is sleeping less. Should we hold off on the games?"
    },
    { 
      id: 2, 
      sender: "System Alert", 
      patient: "Ganpat Singh", 
      patientId: "p-1044",
      patientInfo: "83 yrs • Vascular dementia • Barmer, RJ",
      date: "Yesterday, 04:30 PM", 
      subject: "Anomaly Detected: Pattern Error spike", 
      read: true,
      body: "Automated alert: Ganpat Singh's pattern recognition errors have crossed the 2σ threshold above baseline in the last 14 days. Please review telemetry analytics."
    },
    { 
      id: 3, 
      sender: "Sunita Verma (ASHA)", 
      patient: "Ram Prasad", 
      patientId: "p-1002",
      patientInfo: "71 yrs • MCI • Koraput, OD",
      date: "Sep 03, 11:00 AM", 
      subject: "New medication started, mild nausea reported", 
      read: true,
      body: "We started the new Vitamin B12 regimen as you prescribed. He is reporting some mild nausea in the mornings. I have told him to take it after meals. I will monitor for 3 more days."
    },
  ];

  const selectedMsg = messages.find((m) => m.id === selectedId);

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-semibold text-ink">ASHA Communications</h2>
          <p className="text-sm text-ink-secondary">Secure messages and field alerts from ASHA workers.</p>
        </div>
        <button className="rounded-md bg-[var(--series-1)] px-4 py-2 text-sm font-medium text-white hover:opacity-90">
          Compose Message
        </button>
      </div>

      <div className="flex rounded-xl border border-hairline bg-surface overflow-hidden min-h-[500px]">
        {/* Inbox Sidebar */}
        <div className="w-1/3 border-r border-hairline flex flex-col">
          <div className="p-4 border-b border-hairline bg-plane/30">
            <input 
              type="text" 
              placeholder="Search messages..." 
              className="w-full rounded-md border border-hairline bg-surface px-3 py-1.5 text-sm text-ink placeholder:text-ink-muted focus:outline-none focus:ring-1 focus:ring-sky-500"
            />
          </div>
          <div className="flex-1 overflow-y-auto">
            {messages.map((msg) => (
              <div 
                key={msg.id} 
                onClick={() => setSelectedId(msg.id)}
                className={`p-4 border-b border-hairline cursor-pointer transition-colors ${selectedId === msg.id ? 'bg-sky-500/10 border-l-4 border-l-sky-600' : !msg.read ? 'bg-sky-500/5 border-l-4 border-l-sky-500' : 'hover:bg-plane border-l-4 border-l-transparent'}`}
              >
                <div className="flex justify-between items-baseline mb-1">
                  <span className={`text-sm ${!msg.read ? 'font-bold text-ink' : 'font-medium text-ink-secondary'}`}>{msg.sender}</span>
                  <span className="text-[10px] text-ink-muted">{msg.date}</span>
                </div>
                <div className="text-xs font-semibold text-ink mb-1 truncate">{msg.subject}</div>
                <div className="text-xs text-[var(--series-1)]">Re: {msg.patient}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Message Viewer */}
        {selectedMsg ? (
          <div className="flex-1 flex flex-col p-6 bg-surface">
            <div className="border-b border-hairline pb-4 mb-4">
              <div className="flex justify-between items-start mb-2">
                <h3 className="text-lg font-semibold text-ink">{selectedMsg.subject}</h3>
                <span className="text-xs text-ink-muted">{selectedMsg.date}</span>
              </div>
              <div className="text-sm font-medium text-ink-secondary mb-3">From: {selectedMsg.sender}</div>
              
              <div className="bg-plane/50 rounded-lg p-3 border border-hairline/50 flex items-center justify-between">
                <div>
                  <div className="text-xs text-ink-muted uppercase tracking-wider font-semibold mb-0.5">Regarding Patient</div>
                  <div className="text-sm font-medium text-[var(--series-1)]">{selectedMsg.patient}</div>
                  <div className="text-xs text-ink-secondary mt-0.5">{selectedMsg.patientInfo}</div>
                </div>
                <button 
                  onClick={() => navigate(`/records/${selectedMsg.patientId}`)}
                  className="text-xs font-medium bg-white px-3 py-1.5 rounded-md border border-hairline shadow-sm hover:bg-plane transition-colors text-[var(--series-1)]"
                >
                  View Clinical Profile
                </button>
              </div>
            </div>
            
            <div className="flex-1 overflow-y-auto">
              <p className="text-sm text-ink whitespace-pre-wrap leading-relaxed">
                {selectedMsg.body}
              </p>
            </div>
            
            <div className="mt-4 pt-4 border-t border-hairline">
              <div className="flex gap-2">
                <input 
                  type="text" 
                  placeholder="Type a reply to the ASHA worker..." 
                  className="flex-1 rounded-md border border-hairline bg-plane px-3 py-2 text-sm text-ink focus:border-sky-500 focus:outline-none focus:ring-1 focus:ring-sky-500"
                />
                <button className="rounded-md bg-[var(--series-1)] px-4 py-2 text-sm font-medium text-white hover:opacity-90">
                  Reply
                </button>
              </div>
            </div>
          </div>
        ) : (
          <div className="flex-1 flex flex-col p-8 items-center justify-center text-center bg-plane/10">
            <div className="text-4xl mb-4 opacity-50">✉️</div>
            <h3 className="text-lg font-medium text-ink mb-2">Select a message</h3>
            <p className="text-sm text-ink-secondary max-w-sm">
              Choose a message from the list to view the full conversation or reply to the ASHA worker.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
