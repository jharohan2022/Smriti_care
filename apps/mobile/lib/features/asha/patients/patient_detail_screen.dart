import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/models/patient_local.dart';
import '../widgets/status_dot.dart';
import 'patient_repository.dart';

/// Quick overview of one patient's daily compliance. Reads the local cache so
/// it opens instantly and works offline.
class PatientDetailScreen extends ConsumerWidget {
  const PatientDetailScreen({super.key, required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(patientByIdProvider(patientId));

    return Scaffold(
      appBar: AppBar(title: const Text('Patient')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (p) => p == null
            ? const Center(child: Text('Patient not found'))
            : _Detail(patient: p),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.patient});
  final PatientLocal patient;

  @override
  Widget build(BuildContext context) {
    final compliance = (patient.routineCompliance * 100).round();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            CircleAvatar(radius: 32, child: Text(patient.displayName.characters.first)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.displayName, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  StatusDot(status: patient.status, showLabel: true),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text("Today's routine", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: patient.routineCompliance,
          minHeight: 14,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 8),
        Text('$compliance% complete', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        if (patient.cognitiveDeclineAlert)
          const _Banner(
            color: Color(0xFF6A1B9A),
            icon: Icons.trending_down,
            text: 'Cognitive decline flagged by telemetry — review with doctor.',
          ),
        if (patient.missedRoutineToday)
          const _Banner(
            color: Color(0xFFC62828),
            icon: Icons.notifications_active,
            text: 'Missed routine today — consider a check-in.',
          ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Last routine activity'),
            subtitle: Text(patient.lastRoutineAt?.toString() ?? 'No recent activity recorded'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.update),
            title: const Text('Data freshness'),
            subtitle: Text('Cache updated ${patient.updatedAt}'),
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.color, required this.icon, required this.text});
  final Color color;
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
          ],
        ),
      );
}
