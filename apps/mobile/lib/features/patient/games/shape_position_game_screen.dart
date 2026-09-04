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

class SpatialShape {
  const SpatialShape({
    required this.id,
    required this.nameHi,
    required this.nameEn,
    required this.icon,
    required this.color,
  });

  final String id;
  final String nameHi;
  final String nameEn;
  final IconData icon;
  final Color color;
}

/// Visuospatial Ability Assessment:
/// Displays a target geometric shape / position outline and asks
/// the patient to select the exact matching visual figure.
class ShapePositionGameScreen extends ConsumerStatefulWidget {
  const ShapePositionGameScreen({super.key});

  @override
  ConsumerState<ShapePositionGameScreen> createState() => _ShapePositionGameScreenState();
}

class _ShapePositionGameScreenState extends ConsumerState<ShapePositionGameScreen> {
  static const List<SpatialShape> _shapes = [
    SpatialShape(id: 'triangle', nameHi: 'त्रिकोण (Triangle 🔺)', nameEn: 'Triangle', icon: Icons.change_history_rounded, color: Color(0xFFE53935)),
    SpatialShape(id: 'square', nameHi: 'चौकोर (Square 🟦)', nameEn: 'Square', icon: Icons.crop_square_rounded, color: Color(0xFF1E88E5)),
    SpatialShape(id: 'circle', nameHi: 'गोला (Circle 🔴)', nameEn: 'Circle', icon: Icons.circle_outlined, color: Color(0xFFFB8C00)),
    SpatialShape(id: 'diamond', nameHi: 'हीरा आकार (Diamond 🔷)', nameEn: 'Diamond', icon: Icons.diamond_outlined, color: Color(0xFF8E24AA)),
    SpatialShape(id: 'star', nameHi: 'सितारा (Star ⭐)', nameEn: 'Star', icon: Icons.star_border_rounded, color: Color(0xFF43A047)),
  ];

  final _rng = math.Random();
  final _stopwatch = Stopwatch();

  int _round = 0;
  static const int _totalRounds = 4;
  int _correctCount = 0;

  late SpatialShape _targetShape;
  late List<SpatialShape> _choices;
  SpatialShape? _selectedChoice;
  bool _isAnswered = false;
  Timer? _nextRoundTimer;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _nextRoundTimer?.cancel();
    super.dispose();
  }

  void _startRound() {
    _selectedChoice = null;
    _isAnswered = false;

    final pool = List.of(_shapes)..shuffle(_rng);
    _targetShape = pool.first;

    final others = pool.skip(1).take(2).toList();
    _choices = [_targetShape, ...others]..shuffle(_rng);

    _stopwatch
      ..reset()
      ..start();

    ref.read(ttsServiceProvider).speak(
          'Match the shape. ${_targetShape.nameHi} jaisa aakaar chuniye.',
          langCode: 'hi',
        );

    setState(() {});
  }

  void _onChoiceSelected(SpatialShape choice) {
    if (_isAnswered) return;

    final isCorrect = choice.id == _targetShape.id;
    _stopwatch.stop();
    final elapsedMs = _stopwatch.elapsedMilliseconds;

    setState(() {
      _selectedChoice = choice;
      _isAnswered = true;
      if (isCorrect) _correctCount++;
    });

    final patientId = ref.read(deviceIdentityProvider).valueOrNull?.patientId ?? 'patient-local';
    final event = TelemetryEvent(
      patientId: patientId,
      gameId: 'shape-position-visuospatial',
      reactionMs: elapsedMs,
      spatialErrorPx: isCorrect ? 0.0 : 1.0,
      patternErrors: isCorrect ? 0 : 1,
      capturedAt: DateTime.now(),
    );
    ref.read(syncManagerProvider.notifier).enqueue(event);

    if (isCorrect) {
      ref.read(ttsServiceProvider).speak('शाबाश! बिल्कुल सही आकार। (Exact match!)', langCode: 'hi');
    } else {
      ref.read(ttsServiceProvider).speak('आगे बढ़ते हैं।', langCode: 'hi');
    }

    _nextRoundTimer?.cancel();
    _nextRoundTimer = Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      if (_round + 1 < _totalRounds) {
        setState(() => _round++);
        _startRound();
      } else {
        _showCompletion();
      }
    });
  }

  void _showCompletion() {
    final stars = _correctCount >= 3 ? 3 : (_correctCount >= 2 ? 2 : 1);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameCompletionDialog(
        title: 'शाबाश! (Excellent!)',
        subtitle: 'You matched $_correctCount/$_totalRounds spatial shapes accurately!',
        stars: stars,
        onPlayAgain: () {
          setState(() {
            _round = 0;
            _correctCount = 0;
          });
          _startRound();
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
          'Shape & Position Match',
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
              '${_round + 1} / $_totalRounds',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00695C)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Target Shape Box
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: _targetShape.color, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: _targetShape.color.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(_targetShape.icon, size: 84, color: _targetShape.color),
                    const SizedBox(height: 10),
                    Text(
                      'Match this Shape (इस आकार को पहचानें):',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      _targetShape.nameHi,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _targetShape.color),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Select the identical shape (समान आकार चुनें):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 14),

              // Choices
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _choices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final shape = _choices[index];
                    final isSelected = _selectedChoice?.id == shape.id;
                    final isCorrect = shape.id == _targetShape.id;

                    Color cardBg = Colors.white;
                    Color cardBorder = shape.color.withOpacity(0.4);
                    if (_isAnswered) {
                      if (isCorrect) {
                        cardBg = const Color(0xFFE8F5E9);
                        cardBorder = const Color(0xFF2E7D32);
                      } else if (isSelected) {
                        cardBg = const Color(0xFFFFEBEE);
                        cardBorder = const Color(0xFFC62828);
                      }
                    }

                    return InkWell(
                      onTap: () => _onChoiceSelected(shape),
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: cardBorder, width: isSelected || (isCorrect && _isAnswered) ? 3 : 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(shape.icon, size: 44, color: shape.color),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                shape.nameHi,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (_isAnswered)
                              Icon(
                                isCorrect ? Icons.check_circle_rounded : (isSelected ? Icons.cancel_rounded : null),
                                color: isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                size: 30,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
