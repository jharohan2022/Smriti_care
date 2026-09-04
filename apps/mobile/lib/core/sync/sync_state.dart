import 'package:flutter/foundation.dart';

/// Observable sync status rendered by the ASHA [OfflineSyncManager] widget.
enum SyncPhase {
  idle, // outbox empty, everything pushed
  syncing, // actively draining the outbox
  offlineQueued, // events waiting; no connectivity
  error, // last attempt failed; will retry with backoff
}

@immutable
class SyncState {
  const SyncState({
    required this.phase,
    required this.pending,
    this.lastError,
    this.lastSyncedAt,
  });

  final SyncPhase phase;
  final int pending; // rows in the outbox not yet ACKed
  final String? lastError;
  final DateTime? lastSyncedAt;

  const SyncState.initial()
      : phase = SyncPhase.idle,
        pending = 0,
        lastError = null,
        lastSyncedAt = null;

  SyncState copyWith({
    SyncPhase? phase,
    int? pending,
    String? lastError,
    DateTime? lastSyncedAt,
    bool clearError = false,
  }) {
    return SyncState(
      phase: phase ?? this.phase,
      pending: pending ?? this.pending,
      lastError: clearError ? null : (lastError ?? this.lastError),
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
