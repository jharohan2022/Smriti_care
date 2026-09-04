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

class VisualTargetItem {
  const VisualTargetItem({
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

/// Attention & Visual Search assessment:
/// Designates one specific target (e.g. Tea Cup ☕) and places it
/// amidst 8 random visual distractors in a grid.
class FindTargetGameScreen extends ConsumerStatefulWidget {
  const FindTargetGameScreen({super.key});

  @override
  ConsumerState<FindTargetGameScreen> createState() => _FindTargetGameScreenState();
}

class _FindTargetGameScreenState extends ConsumerState<FindTargetGameScreen> {
  static const List<VisualTargetItem> _catalog = [
    VisualTargetItem(id: 'tea', nameHi: 'चाय का कप (Tea Cup)', nameEn: 'Tea Cup', icon: Icons.coffee_rounded, color: Color(0xFF6D4C41)),
    VisualTargetItem(id: 'flower', nameHi: 'फूल (Flower)', nameEn: 'Flower', icon: Icons.local_florist_rounded, color: Color(0xFFE91E63)),
    VisualTargetItem(id: 'key', nameHi: 'चाबी (Key)', nameEn: 'Key', icon: Icons.vpn_key_rounded, color: Color(0xFFFFA000)),
    VisualTargetItem(id: 'bell', nameHi: 'घंटी (Bell)', nameEn: 'Bell', icon: Icons.notifications_active_rounded, color: Color(0xFF00897B)),
    VisualTargetItem(id: 'leaf', nameHi: 'पत्ता (Leaf)', nameEn: 'Leaf', icon: Icons.eco_rounded, color: Color(0xFF43A047)),
    VisualTargetItem(id: 'sun', nameHi: 'सूरज (Sun)', nameEn: 'Sun', icon: Icons.wb_sunny_rounded, color: Color(0xFFFB8C00)),
    VisualTargetItem(id: 'glasses', nameHi: 'चश्मा (Glasses)', nameEn: 'Glasses', icon: Icons.visibility_rounded, color: Color(0xFF1E88E5)),
    VisualTargetItem(id: 'lamp', nameHi: 'दीया (Lamp)', nameEn: 'Lamp', icon: Icons.lightbulb_rounded, color: Color(0xFF8E24AA)),
    VisualTargetItem(id: 'heart', nameHi: 'दिल (Heart)', nameEn: 'Heart', icon: Icons.favorite_rounded, color: Color(0xFFE53935)),
  ];

  final _rng = math.Random();
  final _stopwatch = Stopwatch();

  int _round = 0;
  static const int _totalRounds = 4;
  int _correctCount = 0;
  int _distractorErrors = 0;
  Timer? _nextRoundTimer;

  late VisualTargetItem _currentTarget;
  late List<VisualTargetItem> _gridItems;
  int? _tappedIndex;
  bool _isAnswered = false;

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
    _tappedIndex = null;
    _isAnswered = false;

    final pool = List.of(_catalog)..shuffle(_rng);
    _currentTarget = pool.first;

    final distractors = pool.skip(1).take(8).toList();
    _gridItems = [
      _currentTarget,
      ...distractors,
    ]..shuffle(_rng);

    _stopwatch
      ..reset()
      ..start();

    ref.read(ttsServiceProvider).speak(
          'Find the ${_currentTarget.nameEn}. ${_currentTarget.nameHi} ko dhoondiye.',
          langCode: 'hi',
        );

    setState(() {});
  }

  void _onItemTap(int index) {
    if (_isAnswered) return;

    final selected = _gridItems[index];
    final isCorrect = selected.id == _currentTarget.id;

    _stopwatch.stop();
    final elapsedMs = _stopwatch.elapsedMilliseconds;

    setState(() {
      _tappedIndex = index;
      _isAnswered = true;
      if (isCorrect) {
        _correctCount++;
      } else {
        _distractorErrors++;
      }
    });

    final patientId = ref.read(deviceIdentityProvider).valueOrNull?.patientId ?? 'patient-local';
    final event = TelemetryEvent(
      patientId: patientId,
      gameId: 'find-target',
      reactionMs: elapsedMs,
      spatialErrorPx: isCorrect ? 0.0 : 1.0,
      patternErrors: isCorrect ? 0 : 1,
      capturedAt: DateTime.now(),
    );
    ref.read(syncManagerProvider.notifier).enqueue(event);

    if (isCorrect) {
      ref.read(ttsServiceProvider).speak('शाबाश! मिल गया! (Found it!)', langCode: 'hi');
    } else {
      ref.read(ttsServiceProvider).speak('यह ${_currentTarget.nameHi} नहीं है। आगे बढ़ते हैं।', langCode: 'hi');
    }

    _nextRoundTimer?.cancel();
    _nextRoundTimer = Timer(const Duration(milliseconds: 1600), () {
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
        title: 'अद्भुत ध्यान! (Great Focus!)',
        subtitle: 'You found $_correctCount/$_totalRounds target items correctly!',
        stars: stars,
        onPlayAgain: () {
          setState(() {
            _round = 0;
            _correctCount = 0;
            _distractorErrors = 0;
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
          'Find the Target',
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
              // Target Instruction Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: _currentTarget.color.withOpacity(0.15),
                      child: Icon(_currentTarget.icon, size: 40, color: _currentTarget.color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Find this Target (इसे खोजें):',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                          ),
                          Text(
                            _currentTarget.nameHi,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, size: 32, color: Color(0xFF00695C)),
                      onPressed: () {
                        ref.read(ttsServiceProvider).speak(
                              'Find the ${_currentTarget.nameEn}. ${_currentTarget.nameHi} kahan hai?',
                              langCode: 'hi',
                            );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 3x3 Grid of Visual Items
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _gridItems.length,
                  itemBuilder: (context, index) {
                    final item = _gridItems[index];
                    final isTapped = _tappedIndex == index;
                    final isCorrect = item.id == _currentTarget.id;

                    Color cardBg = Colors.white;
                    Color cardBorder = Colors.grey.shade300;
                    if (_isAnswered) {
                      if (isCorrect) {
                        cardBg = const Color(0xFFE8F5E9);
                        cardBorder = const Color(0xFF2E7D32);
                      } else if (isTapped) {
                        cardBg = const Color(0xFFFFEBEE);
                        cardBorder = const Color(0xFFC62828);
                      }
                    }

                    return InkWell(
                      onTap: () => _onItemTap(index),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cardBorder, width: isTapped || (isCorrect && _isAnswered) ? 3 : 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(item.icon, size: 48, color: item.color),
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
