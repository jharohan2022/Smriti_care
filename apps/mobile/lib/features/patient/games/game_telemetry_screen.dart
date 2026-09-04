import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/models/telemetry_event.dart';
import '../../../core/services/device_identity_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/sync/sync_manager.dart';
import 'widgets/game_completion_dialog.dart';

/// Highly accessible, cheerful reaction & attention game.
/// Captures reaction latency (ms) and spatial error (px) per trial
/// and records telemetry into the local sync outbox.
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
  int _earlyTaps = 0;
  Offset _target = Offset.zero;
  Timer? _appearTimer;
  Timer? _nextTrialTimer;
  Size _canvas = Size.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTrial());
  }

  @override
  void dispose() {
    _appearTimer?.cancel();
    _nextTrialTimer?.cancel();
    super.dispose();
  }

  void _startTrial() {
    if (_trial >= _trialsPerSession) {
      setState(() => _phase = _Phase.done);
      _showCompletion();
      return;
    }

    setState(() => _phase = _Phase.waiting);

    ref.read(ttsServiceProvider).speak(
          'Wait for the star to appear. Sitara aane ka intezar karein.',
          langCode: 'hi',
        );

    final delayMs = 900 + _rng.nextInt(1500);
    _appearTimer?.cancel();
    _appearTimer = Timer(Duration(milliseconds: delayMs), _showTarget);
  }

  void _showTarget() {
    if (!mounted) return;
    final maxX = (_canvas.width - _targetDiameter - 40).clamp(20.0, double.infinity);
    final maxY = (_canvas.height - _targetDiameter - 100).clamp(20.0, double.infinity);

    setState(() {
      _target = Offset(
        20.0 + _rng.nextDouble() * (maxX - 20.0).clamp(0, double.infinity),
        20.0 + _rng.nextDouble() * (maxY - 20.0).clamp(0, double.infinity),
      );
      _phase = _Phase.active;
    });

    _stopwatch
      ..reset()
      ..start();
  }

  void _onTapDown(TapDownDetails d) {
    switch (_phase) {
      case _Phase.waiting:
        _earlyTaps++;
        break;
      case _Phase.active:
        _stopwatch.stop();
        final center = _target + const Offset(_targetDiameter / 2, _targetDiameter / 2);
        final spatialError = (d.localPosition - center).distance;
        _recordTrial(reactionMs: _stopwatch.elapsedMilliseconds, spatialErrorPx: spatialError);
        _trial++;

        ref.read(ttsServiceProvider).speak('शाबाश! (Great job!)', langCode: 'hi');

        _nextTrialTimer?.cancel();
        _nextTrialTimer = Timer(const Duration(milliseconds: 700), _startTrial);
        setState(() => _phase = _Phase.waiting);
        break;
      case _Phase.getReady:
      case _Phase.done:
        break;
    }
  }

  void _recordTrial({required int reactionMs, required double spatialErrorPx}) {
    final patientId =
        ref.read(deviceIdentityProvider).valueOrNull?.patientId ?? 'patient-local';
    final event = TelemetryEvent(
      patientId: patientId,
      gameId: widget.gameId,
      reactionMs: reactionMs,
      spatialErrorPx: spatialErrorPx,
      patternErrors: _earlyTaps,
      capturedAt: DateTime.now(),
    );
    ref.read(syncManagerProvider.notifier).enqueue(event);
  }

  void _showCompletion() {
    final stars = _earlyTaps <= 1 ? 3 : (_earlyTaps <= 3 ? 2 : 1);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameCompletionDialog(
        title: 'शाबाश! (Excellent!)',
        subtitle: 'You tapped all $_trialsPerSession targets successfully!',
        stars: stars,
        onPlayAgain: () {
          setState(() {
            _trial = 0;
            _earlyTaps = 0;
            _phase = _Phase.getReady;
          });
          _startTrial();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 32, color: Color(0xFF00695C)),
          onPressed: () => context.go('/games'),
        ),
        title: const Text(
          'Speed & Reaction Tap',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF00695C)),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00695C).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_trial.clamp(0, _trialsPerSession)} / $_trialsPerSession',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00695C)),
            ),
          ),
        ],
      ),
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
                        decoration: BoxDecoration(
                          color: const Color(0xFFE65100),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE65100).withOpacity(0.4),
                              blurRadius: 24,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.star_rounded, size: 96, color: Colors.white),
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
    final (title, subtitle, icon) = switch (_phase) {
      _Phase.getReady => ('Get ready…', 'तैयार हो जाइए', Icons.timer_rounded),
      _Phase.waiting => ('Wait for the star ⭐', 'सितारे का इंतज़ार करें', Icons.hourglass_top_rounded),
      _Phase.active => ('TAP THE STAR!', 'सितारे को छुएं!', Icons.touch_app_rounded),
      _Phase.done => ('Great Job! 🎉', 'बहुत बढ़िया!', Icons.emoji_events_rounded),
    };

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFB74D), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: const Color(0xFFE65100)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFE65100),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
