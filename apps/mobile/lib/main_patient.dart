import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap.dart';
import 'core/auth/auth_state_provider.dart';
import 'core/config/flavor_config.dart';
import 'core/router/asha_router.dart';
import 'core/router/patient_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_screen.dart';

/// SmritiCare unified mobile entrypoint with dynamic role switching:
///   flutter run -d <device> -t lib/main_patient.dart
void main() => bootstrap(
      config: const FlavorConfig(
        flavor: AppFlavor.patient,
        apiBaseUrl: String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8080'),
        appTitle: 'SmritiCare',
      ),
      appBuilder: () => const SmritiCareApp(),
    );

class SmritiCareApp extends ConsumerWidget {
  const SmritiCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // If not authenticated, present the Role Selection / Auth Screen
    if (!authState.isAuthenticated) {
      return MaterialApp(
        title: 'SmritiCare — Sign In',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.patient,
        home: const AuthScreen(),
      );
    }

    // Dynamic switching between Patient and ASHA interfaces
    if (authState.activeRole == AppFlavor.asha) {
      final ashaRouter = ref.watch(ashaRouterProvider);
      return MaterialApp.router(
        key: const ValueKey('asha_flavor_app'),
        title: 'SmritiCare — ASHA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.asha,
        routerConfig: ashaRouter,
      );
    }

    final patientRouter = ref.watch(patientRouterProvider);
    return MaterialApp.router(
      key: const ValueKey('patient_flavor_app'),
      title: 'SmritiCare — Patient',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.patient,
      routerConfig: patientRouter,
    );
  }
}

// Backward compatibility alias for PatientApp
typedef PatientApp = SmritiCareApp;

