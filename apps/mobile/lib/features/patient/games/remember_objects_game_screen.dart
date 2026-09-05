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

class RecallObject {
  const RecallObject({
    required this.id,
    required this.nameHi,
    required this.nameEn,
    required this.imagePath,
    required this.color,
  });

  final String id;
  final String nameHi;
  final String nameEn;
  final String imagePath;
  final Color color;
}

/// Short-term memory assessment: Show 3 familiar objects for 4 seconds,
/// hide them, then ask patient to identify which objects were shown.
class RememberObjectsGameScreen extends ConsumerStatefulWidget {
  const RememberObjectsGameScreen({super.key});

  @override
  ConsumerState<RememberObjectsGameScreen> createState() => _RememberObjectsGameScreenState();
}

enum _Phase { showing, choosing, completed }

class _RememberObjectsGameScreenState extends ConsumerState<RememberObjectsGameScreen> {
  static const List<RecallObject> _pool = [
    RecallObject(id: 'diya', nameHi: 'दीया (Lamp)', nameEn: 'Oil Lamp', imagePath: 'assets/images/targets/lamp.jpg', color: Color(0xFFE65100)),
    RecallObject(id: 'eye', nameHi: 'आँख (Eye)', nameEn: 'Eye', imagePath: 'assets/images/targets/eye.jpg', color: Color(0xFF0288D1)),
    RecallObject(id: 'keys', nameHi: 'चाबी (Key)', nameEn: 'Key', imagePath: 'assets/images/targets/key.jpg', color: Color(0xFF5D4037)),
    RecallObject(id: 'cup', nameHi: 'चाय का कप (Cup)', nameEn: 'Tea Cup', imagePath: 'assets/images/targets/cup.jpg', color: Color(0xFF6D4C41)),
    RecallObject(id: 'bell', nameHi: 'घंटी (Bell)', nameEn: 'Bell', imagePath: 'assets/images/targets/bell.jpg', color: Color(0xFF00897B)),
    RecallObject(id: 'leaf', nameHi: 'पत्ता (Leaf)', nameEn: 'Leaf', imagePath: 'assets/images/targets/leaf.jpg', color: Color(0xFF2E7D32)),
    RecallObject(id: 'flower', nameHi: 'फूल (Flower)', nameEn: 'Flower', imagePath: 'assets/images/targets/flower.jpg', color: Color(0xFFE91E63)),
    RecallObject(id: 'sun', nameHi: 'सूरज (Sun)', nameEn: 'Sun', imagePath: 'assets/images/targets/sun.jpg', color: Color(0xFFFB8C00)),
    RecallObject(id: 'heart', nameHi: 'दिल (Heart)', nameEn: 'Heart', imagePath: 'assets/images/targets/heart.jpg', color: Color(0xFFC62828)),
  ];

  final _rng = math.Random();
  final _stopwatch = Stopwatch();

  int _round = 0;
  static const int _totalRounds = 3;
  int _countdown = 4;
  Timer? _countdownTimer;
  Timer? _nextRoundTimer;

  late List<RecallObject> _targetObjects;
  late List<RecallObject> _choices;
  final Set<String> _selectedIds = {};
  _Phase _phase = _Phase.showing;
  int _totalCorrectSelections = 0;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _nextRoundTimer?.cancel();
    super.dispose();
  }

  void _startRound() {
    _countdownTimer?.cancel();
    _selectedIds.clear();

    final shuffled = List.of(_pool)..shuffle(_rng);
    _targetObjects = shuffled.take(3).toList();
    _choices = shuffled.take(6).toList()..shuffle(_rng);

    setState(() {
      _phase = _Phase.showing;
      _countdown = 4;
    });

    final targetNames = _targetObjects.map((o) => o.nameHi).join(', ');
    ref.read(ttsServiceProvider).speak(
          'Remember these 3 objects. Inhe dhyan se dekhiye: $targetNames',
          langCode: 'hi',
        );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        setState(() => _phase = _Phase.choosing);
        _stopwatch
          ..reset()
          ..start();

        ref.read(ttsServiceProvider).speak(
              'Which 3 objects did you see? Ab wo 3 cheezein chuniye jo aapne dekhi thi.',
              langCode: 'hi',
            );
      }
    });
  }

  void _onObjectTapped(RecallObject obj) {
    if (_phase != _Phase.choosing) return;
    if (_selectedIds.contains(obj.id)) return;

    setState(() {
      _selectedIds.add(obj.id);
    });

    final isCorrect = _targetObjects.any((t) => t.id == obj.id);
    if (isCorrect) {
      _totalCorrectSelections++;
      ref.read(ttsServiceProvider).speak('सही! (Correct!)', langCode: 'hi');
    } else {
      ref.read(ttsServiceProvider).speak('कोई बात नहीं (Keep going)', langCode: 'hi');
    }

    if (_selectedIds.length >= 3) {
      _finishRound();
    }
  }

  void _finishRound() {
    _stopwatch.stop();
    final elapsedMs = _stopwatch.elapsedMilliseconds;
    final correctInThisRound = _selectedIds.where((id) => _targetObjects.any((t) => t.id == id)).length;
    final mistakes = 3 - correctInThisRound;

    final patientId = ref.read(deviceIdentityProvider).valueOrNull?.patientId ?? 'patient-local';
    final event = TelemetryEvent(
      patientId: patientId,
      gameId: 'remember-objects',
      reactionMs: elapsedMs,
      spatialErrorPx: mistakes.toDouble(),
      patternErrors: mistakes,
      capturedAt: DateTime.now(),
    );
    ref.read(syncManagerProvider.notifier).enqueue(event);

    _nextRoundTimer?.cancel();
    _nextRoundTimer = Timer(const Duration(milliseconds: 1800), () {
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
    final stars = _totalCorrectSelections >= 7 ? 3 : (_totalCorrectSelections >= 5 ? 2 : 1);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameCompletionDialog(
        title: 'शाबाश! (Excellent!)',
        subtitle: 'You remembered $_totalCorrectSelections/9 objects correctly!',
        stars: stars,
        onPlayAgain: () {
          setState(() {
            _round = 0;
            _totalCorrectSelections = 0;
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
          'Remember Objects',
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
              // Header Instruction
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00695C).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _phase == _Phase.showing ? '⏳ $_countdown' : '🔍',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _phase == _Phase.showing
                                ? 'Memorize these 3 items (याद रखें):'
                                : 'Select the 3 items you saw (चुने):',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            _phase == _Phase.showing
                                ? 'Hiding in $_countdown seconds...'
                                : 'Selected: ${_selectedIds.length} / 3',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _phase == _Phase.showing ? const Color(0xFFE65100) : const Color(0xFF00695C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (_phase == _Phase.showing) ...[
                // Show the 3 Targets clearly
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _targetObjects.map((obj) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: obj.color, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: obj.color.withOpacity(0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  obj.imagePath,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Text(
                                obj.nameHi,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ] else ...[
                // Grid of 6 choices
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: _choices.length,
                    itemBuilder: (context, index) {
                      final obj = _choices[index];
                      final isSelected = _selectedIds.contains(obj.id);
                      final isTarget = _targetObjects.any((t) => t.id == obj.id);

                      Color cardBorder = Colors.grey.shade300;
                      Color cardBg = Colors.white;
                      if (isSelected) {
                        cardBg = isTarget ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
                        cardBorder = isTarget ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
                      }

                      return InkWell(
                        onTap: () => _onObjectTapped(obj),
                        borderRadius: BorderRadius.circular(22),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: cardBorder, width: isSelected ? 3 : 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  child: Image.asset(
                                    obj.imagePath,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        obj.nameHi,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        isTarget ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                        color: isTarget ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                        size: 20,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
