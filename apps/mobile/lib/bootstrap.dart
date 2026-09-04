import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/flavor_config.dart';
import 'core/database/isar_service.dart';

/// Shared boot sequence for both flavors. Opens the offline database *before*
/// the first frame so every screen can read local state synchronously — the
/// patient must never see a loading spinner waiting on I/O.
Future<void> bootstrap({
  required FlavorConfig config,
  required Widget Function() appBuilder,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.set(config);

  // Open Isar once and inject it; if it fails we still launch (in-memory
  // degraded mode) rather than white-screen the patient.
  final isar = await IsarService.open();

  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: appBuilder(),
    ),
  );
}
