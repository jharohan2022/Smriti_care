import 'package:flutter/foundation.dart';

/// Which role this build serves. The Patient and ASHA panels ship from one
/// codebase; the entrypoint (`main_patient.dart` / `main_asha.dart`) sets the
/// flavor, and the rest of the app branches on it (router, theme, feature gates).
enum AppFlavor { patient, asha }

@immutable
class FlavorConfig {
  const FlavorConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appTitle,
  });

  final AppFlavor flavor;
  final String apiBaseUrl;
  final String appTitle;

  bool get isPatient => flavor == AppFlavor.patient;
  bool get isAsha => flavor == AppFlavor.asha;

  /// Set once at boot and updated whenever role is switched.
  static FlavorConfig? _instance;
  static FlavorConfig get instance =>
      _instance ??
      const FlavorConfig(
        flavor: AppFlavor.patient,
        apiBaseUrl: 'http://10.0.2.2:8080',
        appTitle: 'SmritiCare',
      );

  static void set(FlavorConfig config) => _instance = config;
}

