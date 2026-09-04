import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/api/api_client.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/database/models/patient_local.dart';

/// Reads the ASHA's assigned patients straight from Isar and *watches* the
/// collection, so the list updates reactively and works fully offline. Sorted
/// so alerts (red) float to the top.
final assignedPatientsProvider = StreamProvider<List<PatientLocal>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.patientLocals
      .where()
      .sortByStatusDesc() // alert(2) → warning(1) → ok(0)
      .watch(fireImmediately: true);
});

final patientByIdProvider =
    StreamProvider.family<PatientLocal?, String>((ref, patientId) {
  final isar = ref.watch(isarProvider);
  return isar.patientLocals
      .filter()
      .patientIdEqualTo(patientId)
      .watch(fireImmediately: true)
      .map((rows) => rows.isEmpty ? null : rows.first);
});

class PatientRepository {
  PatientRepository(this._isar, this._api);
  final Isar _isar;
  final ApiClient _api;

  /// Pull the latest assignments/compliance from the backend and upsert locally.
  /// Throws [ApiFailure] on network problems — the caller decides how to surface it.
  Future<void> refreshFromServer() async {
    final res = await _api.get<Map<String, dynamic>>('/asha/patients');
    final rows = (res.data?['patients'] as List? ?? []).map((j) {
      final m = j as Map<String, dynamic>;
      return PatientLocal()
        ..patientId = m['patientId'] as String
        ..displayName = m['displayName'] as String
        ..photoPath = m['photoPath'] as String?
        ..status = PatientStatus.values[(m['status'] as int?) ?? 0]
        ..routineCompliance = (m['routineCompliance'] as num?)?.toDouble() ?? 0
        ..missedRoutineToday = m['missedRoutineToday'] as bool? ?? false
        ..cognitiveDeclineAlert = m['cognitiveDeclineAlert'] as bool? ?? false
        ..updatedAt = DateTime.now();
    }).toList();
    await _isar.writeTxn(() => _isar.patientLocals.putAll(rows));
  }

  /// Seed demo rows so the panel is usable before any backend contact.
  Future<void> seedIfEmpty() async {
    if (await _isar.patientLocals.count() > 0) return;
    final demo = [
      PatientLocal()
        ..patientId = 'p-1001'
        ..displayName = 'Kamala Devi'
        ..status = PatientStatus.alert
        ..routineCompliance = 0.2
        ..missedRoutineToday = true
        ..cognitiveDeclineAlert = true
        ..updatedAt = DateTime.now(),
      PatientLocal()
        ..patientId = 'p-1002'
        ..displayName = 'Ram Prasad'
        ..status = PatientStatus.warning
        ..routineCompliance = 0.6
        ..updatedAt = DateTime.now(),
      PatientLocal()
        ..patientId = 'p-1003'
        ..displayName = 'Sushila Bai'
        ..status = PatientStatus.ok
        ..routineCompliance = 0.95
        ..updatedAt = DateTime.now(),
    ];
    await _isar.writeTxn(() => _isar.patientLocals.putAll(demo));
  }
}

final patientRepositoryProvider = Provider(
  (ref) => PatientRepository(ref.watch(isarProvider), ref.watch(apiClientProvider)),
);
