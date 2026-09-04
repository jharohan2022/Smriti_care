import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_state_provider.dart';
import '../../../core/config/flavor_config.dart';
import '../../../core/database/models/patient_local.dart';
import '../sync/offline_sync_manager.dart';
import '../widgets/status_dot.dart';
import 'patient_repository.dart';


/// The ASHA's triage home: assigned patients, alerts first, color-coded.
/// Works entirely from the local cache; a pull-to-refresh reconciles with the
/// backend and fails soft (keeps showing cached data if offline).
class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  @override
  void initState() {
    super.initState();
    // Populate demo data on first run, then try a live refresh (soft-fails).
    Future.microtask(() async {
      await ref.read(patientRepositoryProvider).seedIfEmpty();
      await _refresh(silent: true);
    });
  }

  Future<void> _refresh({bool silent = false}) async {
    try {
      await ref.read(patientRepositoryProvider).refreshFromServer();
    } on ApiFailure catch (f) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Showing saved data — ${f.message.toLowerCase()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(assignedPatientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        actions: [
          IconButton(
            tooltip: 'Sync center',
            icon: const Icon(Icons.sync),
            onPressed: () => context.go('/sync'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: 'Account & Mode',
            onSelected: (val) {
              if (val == 'switch') {
                ref.read(authStateProvider.notifier).switchRole(AppFlavor.patient);
              } else if (val == 'logout') {
                ref.read(authStateProvider.notifier).logout();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'switch',
                child: Row(
                  children: [
                    Icon(Icons.person_rounded, color: Color(0xFF00695C)),
                    SizedBox(width: 8),
                    Text('Switch to Patient Mode'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sign Out / Change Role'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: OfflineSyncManager(compact: true),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: patients.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorList(message: '$e', onRetry: _refresh),
                data: (list) => list.isEmpty
                    ? const _EmptyList()
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) => _PatientTile(patient: list[i]),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientTile extends StatelessWidget {
  const _PatientTile({required this.patient});
  final PatientLocal patient;

  @override
  Widget build(BuildContext context) {
    final compliance = (patient.routineCompliance * 100).round();
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 26,
        child: Text(patient.displayName.characters.first),
      ),
      title: Text(patient.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('Routine today: $compliance%'),
          if (patient.missedRoutineToday || patient.cognitiveDeclineAlert)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 6,
                children: [
                  if (patient.missedRoutineToday)
                    const _Chip(label: 'Missed routine', color: Color(0xFFC62828)),
                  if (patient.cognitiveDeclineAlert)
                    const _Chip(label: 'Cognitive decline', color: Color(0xFF6A1B9A)),
                ],
              ),
            ),
        ],
      ),
      trailing: StatusDot(status: patient.status, showLabel: true),
      onTap: () => context.go('/patients/${patient.patientId}'),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      );
}

class _EmptyList extends StatelessWidget {
  const _EmptyList();
  @override
  Widget build(BuildContext context) => ListView(
        children: const [
          SizedBox(height: 120),
          Icon(Icons.groups_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Center(child: Text('No patients assigned yet')),
        ],
      );
}

class _ErrorList extends StatelessWidget {
  const _ErrorList({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => ListView(
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 12),
          Center(child: Text(message, textAlign: TextAlign.center)),
          const SizedBox(height: 16),
          Center(child: FilledButton(onPressed: () => onRetry(), child: const Text('Retry'))),
        ],
      );
}
