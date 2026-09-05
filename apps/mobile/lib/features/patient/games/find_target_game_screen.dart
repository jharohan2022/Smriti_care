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
    required this.shortLabel,
    required this.imagePath,
  });

  final String id;
  final String nameHi;
  final String nameEn;
  final String shortLabel;
  final String imagePath;
}

/// Attention & Visual Search assessment with realistic real-world images:
/// Designates one specific target (e.g. दीया (Lamp)) and places it
/// amidst 8 random visual distractors in a 3x3 photo grid.
class FindTargetGameScreen extends ConsumerStatefulWidget {
  const FindTargetGameScreen({super.key});

  @override
  ConsumerState<FindTargetGameScreen> createState() => _FindTargetGameScreenState();
}

class _FindTargetGameScreenState extends ConsumerState<FindTargetGameScreen> {
  static const List<VisualTargetItem> _catalog = [
    VisualTargetItem(
      id: 'eye',
      nameHi: 'आँख (Eye)',
      nameEn: 'Eye',
      shortLabel: 'Eye',
      imagePath: 'assets/images/targets/eye.jpg',
    ),
    VisualTargetItem(
      id: 'cup',
      nameHi: 'चाय का कप (Cup)',
      nameEn: 'Cup',
      shortLabel: 'Cup',
      imagePath: 'assets/images/targets/cup.jpg',
    ),
    VisualTargetItem(
      id: 'bell',
      nameHi: 'घंटी (Bell)',
      nameEn: 'Bell',
      shortLabel: 'Bell',
      imagePath: 'assets/images/targets/bell.jpg',
    ),
    VisualTargetItem(
      id: 'leaf',
      nameHi: 'पत्ता (Leaf)',
      nameEn: 'Leaf',
      shortLabel: 'Leaf',
      imagePath: 'assets/images/targets/leaf.jpg',
    ),
    VisualTargetItem(
      id: 'key',
      nameHi: 'चाबी (Key)',
      nameEn: 'Key',
      shortLabel: 'Key',
      imagePath: 'assets/images/targets/key.jpg',
    ),
    VisualTargetItem(
      id: 'lamp',
      nameHi: 'दीया (Lamp)',
      nameEn: 'Lamp',
      shortLabel: 'Lamp',
      imagePath: 'assets/images/targets/lamp.jpg',
    ),
    VisualTargetItem(
      id: 'heart',
      nameHi: 'दिल (Heart)',
      nameEn: 'Heart',
      shortLabel: 'Heart',
      imagePath: 'assets/images/targets/heart.jpg',
    ),
    VisualTargetItem(
      id: 'flower',
      nameHi: 'फूल (Flower)',
      nameEn: 'Flower',
      shortLabel: 'Flower',
      imagePath: 'assets/images/targets/flower.jpg',
    ),
    VisualTargetItem(
      id: 'sun',
      nameHi: 'सूरज (Sun)',
      nameEn: 'Sun',
      shortLabel: 'Sun',
      imagePath: 'assets/images/targets/sun.jpg',
    ),
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

    // Pick target randomly
    final pool = List.of(_catalog)..shuffle(_rng);
    _currentTarget = pool.first;

    // Distractors (take all 8 remaining so all 9 items fill the 3x3 grid)
    final distractors = pool.skip(1).take(8).toList();
    _gridItems = [
      _currentTarget,
      ...distractors,
    ]..shuffle(_rng);

    _stopwatch
      ..reset()
      ..start();

    _speakPrompt();
    setState(() {});
  }

  void _speakPrompt() {
    ref.read(ttsServiceProvider).speak(
          'Find the ${_currentTarget.nameEn}. ${_currentTarget.nameHi} ko dhoondiye.',
          langCode: 'hi',
        );
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
      patternErrors: _distractorErrors,
      capturedAt: DateTime.now(),
    );
    ref.read(syncManagerProvider.notifier).enqueue(event);

    if (isCorrect) {
      ref.read(ttsServiceProvider).speak('शाबाश! सही चुना! (Well done!)', langCode: 'hi');
    } else {
      ref.read(ttsServiceProvider).speak('यह ${_currentTarget.nameHi} नहीं है। आगे बढ़ते हैं।', langCode: 'hi');
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
      backgroundColor: const Color(0xFFFBF8F1), // Warm organic cream
      body: SafeArea(
        child: Stack(
          children: [
            // Soft decorative leaves at bottom corners
            Positioned(
              left: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.15,
                child: Icon(Icons.eco_rounded, size: 140, color: const Color(0xFF2E7D32)),
              ),
            ),
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.15,
                child: Transform.flip(
                  flipX: true,
                  child: Icon(Icons.eco_rounded, size: 140, color: const Color(0xFF2E7D32)),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header row: Back with 'वापस' label, Smarana Logo & tagline, Progress pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back button + 'वापस' label
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/games'),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE2EFE7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Color(0xFF1B4D3E),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'वापस',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B4D3E),
                            ),
                          ),
                        ],
                      ),

                      // Center Smarana brand
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 26),
                              SizedBox(width: 6),
                              Text(
                                'Smarana',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1B4D3E),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Brighter Minds, Happier Tomorrows',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A6B5D),
                            ),
                          ),
                        ],
                      ),

                      // Right: Progress indicator pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1EFEA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_round + 1}/$_totalRounds',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1B4D3E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Mini segmented progress bar
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(_totalRounds, (index) {
                                final isDone = index <= _round;
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                  width: 10,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isDone ? const Color(0xFF2E7D32) : const Color(0xFFD4CEC3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Title & Subtitle
                  const Center(
                    child: Text(
                      'Find the Target',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF154734),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Center(
                    child: Text(
                      'पहले सुनें, फिर सही चित्र चुनें।',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF225745),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Target Prompt Card (Mint sage banner with speaker and Hindi/English name)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4EC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD0E8D9), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        // Dark forest green circle with speaker icon
                        GestureDetector(
                          onTap: _speakPrompt,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1B4D3E),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Find this Target (इसे खोजें):',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4B6358),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _currentTarget.nameHi,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF11382A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3x3 Grid of Realistic Real-World Photographic Cards
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: _gridItems.length,
                      itemBuilder: (context, index) {
                        final item = _gridItems[index];
                        final isTapped = _tappedIndex == index;
                        final isCorrect = item.id == _currentTarget.id;

                        Color cardBg = Colors.white;
                        Color borderColor = const Color(0xFFE5E7EB);
                        double borderWidth = 1.0;

                        if (_isAnswered) {
                          if (isCorrect) {
                            cardBg = const Color(0xFFEDF7ED);
                            borderColor = const Color(0xFF2E7D32);
                            borderWidth = 3.0;
                          } else if (isTapped) {
                            cardBg = const Color(0xFFFFEBEE);
                            borderColor = const Color(0xFFC62828);
                            borderWidth = 3.0;
                          }
                        }

                        return GestureDetector(
                          onTap: () => _onItemTap(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: borderColor, width: borderWidth),
                              boxShadow: [
                                BoxShadow(
                                  color: isCorrect && _isAnswered
                                      ? const Color(0xFF2E7D32).withOpacity(0.25)
                                      : Colors.black.withOpacity(0.04),
                                  blurRadius: isCorrect && _isAnswered ? 12 : 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Real-world photographic image
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.asset(
                                      item.imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: Icon(Icons.image_rounded, size: 36, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Text label below the photo
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Text(
                                    item.shortLabel,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isCorrect && _isAnswered
                                          ? const Color(0xFF1B5E20)
                                          : const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Bottom encouraging banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4EC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD0E8D9), width: 1.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3), width: 1.5),
                          ),
                          child: const Icon(
                            Icons.psychology_outlined,
                            color: Color(0xFF1B4D3E),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Take your time. You can do it!',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF154734),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'धीरे करें, आप कर सकते हैं!',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF265947),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
