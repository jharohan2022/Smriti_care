import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/asha/patients/patient_detail_screen.dart';
import '../../features/asha/patients/patient_list_screen.dart';
import '../../features/asha/sync/offline_sync_manager.dart';

/// ASHA navigation. A working, denser tool — list → detail, plus a dedicated
/// sync center. `errorBuilder` gives a recoverable error state with retry.
final ashaRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/patients',
    errorBuilder: (context, state) => _AshaErrorScreen(
      message: state.error?.toString() ?? 'Unknown error',
      onRetry: () => context.go('/patients'),
    ),
    routes: [
      GoRoute(path: '/patients', builder: (_, __) => const PatientListScreen()),
      GoRoute(
        path: '/patients/:id',
        builder: (_, state) =>
            PatientDetailScreen(patientId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/sync',
        builder: (_, __) => Scaffold(
          appBar: AppBar(title: const Text('Sync Center')),
          body: const Padding(
            padding: EdgeInsets.all(16),
            child: OfflineSyncManager(),
          ),
        ),
      ),
    ],
  );
});

class _AshaErrorScreen extends StatelessWidget {
  const _AshaErrorScreen({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Something went wrong')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(message, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
