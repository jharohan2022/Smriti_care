import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap.dart';
import 'core/auth/auth_state_provider.dart';
import 'core/config/flavor_config.dart';
import 'core/router/asha_router.dart';
import 'core/router/patient_router.dart';
import 'core/theme/app_theme.dart';

/// SmritiCare unified mobile entrypoint with dynamic role switching:
///   flutter run -d <device> -t lib/main_patient.dart
void main() => bootstrap(
      config: const FlavorConfig(
        flavor: AppFlavor.patient,
        apiBaseUrl: String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8080'),
        appTitle: 'Smarana',
      ),
      appBuilder: () => const SmritiCareApp(),
    );

class SmritiCareApp extends ConsumerWidget {
  const SmritiCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    final isAsha = authState.activeRole == AppFlavor.asha;
    final router = isAsha ? ref.watch(ashaRouterProvider) : ref.watch(patientRouterProvider);
    final theme = isAsha ? AppTheme.asha : AppTheme.patient;

    return MaterialApp.router(
      key: ValueKey('smriticare_app_${authState.activeRole.name}'),
      title: 'Smarana / ASHA Sathi',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: router,
    );
  }
}

// Backward compatibility alias for PatientApp
typedef PatientApp = SmritiCareApp;

