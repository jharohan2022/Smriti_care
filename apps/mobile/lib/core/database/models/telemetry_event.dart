import 'package:uuid/uuid.dart';

/// The clinical signal emitted by [GameTelemetryScreen], one per game trial.
/// Plain immutable model — persisted by wrapping it in a [SyncEnvelope] so the
/// offline outbox has a single storage shape. `eventId` is the idempotency key.
class TelemetryEvent {
  TelemetryEvent({
    required this.patientId,
    required this.gameId,
    required this.reactionMs,
    required this.spatialErrorPx,
    required this.patternErrors,
    required this.capturedAt,
    String? eventId,
  }) : eventId = eventId ?? const Uuid().v4();

  final String eventId;
  final String patientId;
  final String gameId;

  /// Reaction time in ms — the primary "reaction time drift" signal.
  final int reactionMs;

  /// Tap distance from the target centroid in logical px — spatial accuracy.
  final double spatialErrorPx;

  /// Wrong selections in a pattern-recognition trial.
  final int patternErrors;

  final DateTime capturedAt;

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'patientId': patientId,
        'gameId': gameId,
        'reactionMs': reactionMs,
        'spatialErrorPx': spatialErrorPx,
        'patternErrors': patternErrors,
        'capturedAt': capturedAt.toUtc().toIso8601String(),
      };
}
