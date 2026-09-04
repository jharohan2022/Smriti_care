import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../api/api_client.dart';
import '../database/isar_service.dart';
import '../database/models/sync_envelope.dart';
import '../database/models/telemetry_event.dart';
import '../services/connectivity_service.dart';
import 'sync_state.dart';

/// Owns the offline outbox. Writes are enqueued locally and always succeed;
/// draining to the backend happens opportunistically and idempotently.
class SyncManager extends StateNotifier<SyncState> {
  SyncManager(this._ref) : super(const SyncState.initial()) {
    _init();
  }

  final Ref _ref;
  static const _maxBackoff = Duration(minutes: 30);

  Isar get _isar => _ref.read(isarProvider);
  ApiClient get _api => _ref.read(apiClientProvider);

  void _init() {
    unawaited(_refreshPending());
    // Auto-drain the moment connectivity returns.
    _ref.listen<AsyncValue<bool>>(connectivityProvider, (_, next) {
      next.whenData((online) {
        if (online) unawaited(syncNow());
      });
    });
  }

  /// Durably enqueue a telemetry event, then attempt a push (fire-and-forget so
  /// the game UI is never blocked on the network).
  Future<void> enqueue(TelemetryEvent event) async {
    final env = SyncEnvelope()
      ..eventId = event.eventId
      ..kind = SyncKind.telemetry
      ..payloadJson = jsonEncode(event.toJson())
      ..createdAt = DateTime.now();

    await _isar.writeTxn(() => _isar.syncEnvelopes.put(env));
    await _refreshPending();
    unawaited(syncNow());
  }

  Future<void> _refreshPending() async {
    final count =
        await _isar.syncEnvelopes.filter().syncedEqualTo(false).count();
    state = state.copyWith(
      pending: count,
      phase: count == 0 && state.phase != SyncPhase.error
          ? SyncPhase.idle
          : state.phase,
    );
  }

  /// Drain the outbox in idempotent batches. Safe to call repeatedly.
  Future<void> syncNow({int batchSize = 50}) async {
    if (state.phase == SyncPhase.syncing) return;
    if (!_ref.read(isOnlineProvider)) {
      final pending = state.pending;
      state = state.copyWith(
        phase: pending > 0 ? SyncPhase.offlineQueued : SyncPhase.idle,
      );
      return;
    }

    state = state.copyWith(phase: SyncPhase.syncing, clearError: true);
    try {
      while (true) {
        final due = await _nextDueBatch(batchSize);
        if (due.isEmpty) break;
        await _pushBatch(due);
        await _refreshPending();
      }
      state = state.copyWith(
        phase: SyncPhase.idle,
        lastSyncedAt: DateTime.now(),
        clearError: true,
      );
    } on ApiFailure catch (f) {
      state = state.copyWith(phase: SyncPhase.error, lastError: f.message);
    } finally {
      await _refreshPending();
    }
  }

  Future<List<SyncEnvelope>> _nextDueBatch(int batchSize) async {
    final now = DateTime.now();
    final unsynced =
        await _isar.syncEnvelopes.filter().syncedEqualTo(false).findAll();
    return unsynced
        .where((e) => e.nextAttemptAt == null || e.nextAttemptAt!.isBefore(now))
        .take(batchSize)
        .toList();
  }

  Future<void> _pushBatch(List<SyncEnvelope> due) async {
    final body = {
      'events': due.map((e) => jsonDecode(e.payloadJson)).toList(),
    };
    try {
      // Endpoint dedupes on eventId → retrying a half-failed batch is safe.
      await _api.post('/telemetry/batch', data: body);
      await _isar.writeTxn(() async {
        for (final e in due) {
          e.synced = true;
          e.lastError = null;
        }
        await _isar.syncEnvelopes.putAll(due);
      });
    } on ApiFailure catch (f) {
      await _isar.writeTxn(() async {
        for (final e in due) {
          e.attempts += 1;
          e.lastError = f.message;
          e.nextAttemptAt = DateTime.now().add(_backoff(e.attempts));
        }
        await _isar.syncEnvelopes.putAll(due);
      });
      rethrow; // stop the drain loop; surface the error to state
    }
  }

  /// Exponential backoff with jitter, capped at [_maxBackoff].
  Duration _backoff(int attempts) {
    final seconds = math.min(
      _maxBackoff.inSeconds,
      (2 << attempts.clamp(0, 12)),
    );
    final jitter = math.Random().nextInt(1000); // ms
    return Duration(seconds: seconds, milliseconds: jitter);
  }
}

final syncManagerProvider =
    StateNotifierProvider<SyncManager, SyncState>((ref) => SyncManager(ref));
