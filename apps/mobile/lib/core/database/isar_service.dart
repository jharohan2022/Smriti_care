import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/patient_local.dart';
import 'models/sync_envelope.dart';

/// Injected in `bootstrap.dart` via `overrideWithValue`. Reading it before the
/// override is a programming error, hence the throwing default.
final isarProvider = Provider<Isar>(
  (ref) => throw UnimplementedError('isarProvider must be overridden in bootstrap()'),
);

class IsarService {
  /// Opens the on-device store. Never throws to the caller — on failure we open
  /// an ephemeral instance so the app still launches (degraded, non-persistent).
  static Future<Isar> open() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [SyncEnvelopeSchema, PatientLocalSchema],
        directory: dir.path,
        inspector: false,
      );
    } catch (_) {
      // Degraded fallback: unique temp instance so provisioning still works.
      final dir = await getTemporaryDirectory();
      return Isar.open(
        [SyncEnvelopeSchema, PatientLocalSchema],
        directory: dir.path,
        name: 'ephemeral',
      );
    }
  }
}
