import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/connectivity_service.dart';
import '../../../core/sync/sync_manager.dart';
import '../../../core/sync/sync_state.dart';

/// Shows the offline outbox: how many telemetry events are queued, the current
/// sync phase, and a manual "Sync now" action. This is the ASHA's visibility
/// into "what's waiting for internet".
///
/// [compact] renders a slim status banner (for the top of the patient list);
/// the full form renders a detailed card (the /sync center).
class OfflineSyncManager extends ConsumerWidget {
  const OfflineSyncManager({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncManagerProvider);
    final online = ref.watch(isOnlineProvider);
    final v = _visuals(sync, online);

    if (compact) {
      return Material(
        color: v.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(v.icon, color: v.color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(v.line, style: TextStyle(color: v.color, fontWeight: FontWeight.w600))),
              if (sync.pending > 0)
                Text('${sync.pending} queued', style: TextStyle(color: v.color)),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(v.icon, color: v.color, size: 28),
                const SizedBox(width: 10),
                Text(v.title, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                _Pill(online: online),
              ],
            ),
            const SizedBox(height: 12),
            _StatRow(label: 'Events waiting to upload', value: '${sync.pending}'),
            _StatRow(
              label: 'Last successful sync',
              value: sync.lastSyncedAt == null ? '—' : _ago(sync.lastSyncedAt!),
            ),
            if (sync.lastError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Last error: ${sync.lastError}', style: const TextStyle(color: Color(0xFFC62828))),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (!online || sync.phase == SyncPhase.syncing)
                    ? null
                    : () => ref.read(syncManagerProvider.notifier).syncNow(),
                icon: sync.phase == SyncPhase.syncing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(_actionLabel(sync, online)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _actionLabel(SyncState s, bool online) {
    if (!online) return 'Waiting for internet…';
    if (s.phase == SyncPhase.syncing) return 'Syncing…';
    if (s.pending == 0) return 'All synced';
    return 'Sync now (${s.pending})';
  }

  ({IconData icon, Color color, String title, String line}) _visuals(SyncState s, bool online) {
    if (!online && s.pending > 0) {
      return (icon: Icons.cloud_off, color: const Color(0xFFF9A825), title: 'Offline — queued', line: 'Offline · will upload when online');
    }
    return switch (s.phase) {
      SyncPhase.syncing => (icon: Icons.sync, color: const Color(0xFF1565C0), title: 'Syncing…', line: 'Uploading…'),
      SyncPhase.error => (icon: Icons.error_outline, color: const Color(0xFFC62828), title: 'Sync error', line: 'Sync failed · will retry'),
      SyncPhase.offlineQueued => (icon: Icons.cloud_off, color: const Color(0xFFF9A825), title: 'Offline — queued', line: 'Offline · queued'),
      SyncPhase.idle => s.pending == 0
          ? (icon: Icons.cloud_done, color: const Color(0xFF2E7D32), title: 'All synced', line: 'All data uploaded')
          : (icon: Icons.cloud_queue, color: const Color(0xFF1565C0), title: 'Ready to sync', line: 'Ready to upload'),
    };
  }

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes} min ago';
    if (d.inDays < 1) return '${d.inHours} h ago';
    return '${d.inDays} d ago';
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.black54)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.online});
  final bool online;
  @override
  Widget build(BuildContext context) {
    final c = online ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(online ? 'Online' : 'Offline', style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}
