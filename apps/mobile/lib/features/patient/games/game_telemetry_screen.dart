import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/models/telemetry_event.dart';
import '../../../core/services/device_identity_service.dart';
import '../../../core/sync/sync_manager.dart';
import '../../../core/theme/app_theme.dart';

/// Distraction-free container for a memory/attention game. Its clinical job is
/// to capture **reaction time** and **spatial error** per trial and write each
/// as an offline [TelemetryEvent] — the write always succeeds locally and the
/// [SyncManager] pushes it later. No app bar, no chrome, nothing to tap by
/// mistake; a single small "exit" affordance.
class GameTelemetryScreen extends ConsumerStatefulWidget {
  const GameTelemetryScreen({super.key, required this.gameId});
  final String gameId;

  @override
  ConsumerState<GameTelemetryScreen> createState() => _GameTelemetryScreenState();
}

enum _Phase { getReady, waiting, active, done }

class _GameTelemetryScreenState extends ConsumerState<GameTelemetryScreen> {
  static const _trialsPerSession = 5;
  static const _targetDiameter = 140.0;

  final _rng = math.Random();
  final _stopwatch = Stopwatch();

  _Phase _phase = _Phase.getReady;
  int _trial = 0;
  int _earlyTaps = 0; // taps before the target appears → attention lapses
  Offset _target = Offset.zero;
  Timer? _appearTimer;
  Size _canvas = Size.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTrial());
  }

  @override
  void dispose() {
    _appearTimer?.cancel();
    super.dispose();
  }

  void _startTrial() {
    if (_trial >= _trialsPerSession) {
      setState(() => _phase = _Phase.done);
      return;
    }
    setState(() => _phase = _Phase.waiting);
    // Randomised delay defeats anticipatory tapping → cleaner reaction signal.
    final delayMs = 800 + _rng.nextInt(1600);
    _appearTimer = Timer(Duration(milliseconds: delayMs), _showTarget);
  }

  void _showTarget() {
    final maxX = (_canvas.width - _targetDiameter).clamp(0, double.infinity);
    final maxY = (_canvas.height - _targetDiameter).clamp(0, double.infinity);
    setState(() {
      _target = Offset(_rng.nextDouble() * maxX, _rng.nextDouble() * maxY);
      _phase = _Phase.active;
    });
    _stopwatch
      ..reset()
      ..start();
  }

  void _onTapDown(TapDownDetails d) {
    switch (_phase) {
      case _Phase.waiting:
        _earlyTaps++; // tapped too soon
        break;
      case _Phase.active:
        _stopwatch.stop();
        final center = _target + const Offset(_targetDiameter / 2, _targetDiameter / 2);
        final spatialError = (d.localPosition - center).distance;
        _recordTrial(reactionMs: _stopwatch.elapsedMilliseconds, spatialErrorPx: spatialError);
        _trial++;
        _appearTimer = Timer(const Duration(milliseconds: 600), _startTrial);
        setState(() => _phase = _Phase.waiting);
        break;
      case _Phase.getReady:
      case _Phase.done:
        break;
    }
  }

  void _recordTrial({required int reactionMs, required double spatialErrorPx}) {
    final patientId =
        ref.read(deviceIdentityProvider).valueOrNull?.patientId ?? 'unprovisioned';
    final event = TelemetryEvent(
      patientId: patientId,
      gameId: widget.gameId,
      reactionMs: reactionMs,
      spatialErrorPx: spatialErrorPx,
      patternErrors: _earlyTaps,
      capturedAt: DateTime.now(),
    );
    // Fire-and-forget: writes to the local outbox, never blocks the UI.
    ref.read(syncManagerProvider.notifier).enqueue(event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            _canvas = Size(constraints.maxWidth, constraints.maxHeight);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: _onTapDown,
              child: Stack(
                children: [
                  _buildOverlay(),
                  if (_phase == _Phase.active)
                    Positioned(
                      left: _target.dx,
                      top: _target.dy,
                      child: Container(
                        width: _targetDiameter,
                        height: _targetDiameter,
                        decoration: const BoxDecoration(
                          color: A11y.patientPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star_rounded, size: 96, color: Colors.white),
                      ),
                    ),
                  // Minimal, out-of-the-way exit.
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      iconSize: 40,
                      color: Colors.white54,
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => context.go('/home'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    final (text, showProgress) = switch (_phase) {
      _Phase.getReady => ('Get ready…', false),
      _Phase.waiting => ('Wait for the star ⭐', false),
      _Phase.active => ('', false),
      _Phase.done => ('Well done! 🎉', true),
    };
    if (text.isEmpty) return const SizedBox.shrink();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700)),
          if (showProgress) ...[
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.go('/home'),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Home', style: TextStyle(fontSize: 28)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
