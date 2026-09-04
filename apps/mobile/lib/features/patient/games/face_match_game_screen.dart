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

class FamilyMemberTarget {
  const FamilyMemberTarget({
    required this.id,
    required this.name,
    required this.relationHi,
    required this.relationEn,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String relationHi;
  final String relationEn;
  final IconData icon;
  final Color color;
}

class FaceMatchGameScreen extends ConsumerStatefulWidget {
  const FaceMatchGameScreen({super.key});

  @override
  ConsumerState<FaceMatchGameScreen> createState() => _FaceMatchGameScreenState();
}

class _FaceMatchGameScreenState extends ConsumerState<FaceMatchGameScreen> {
  static const List<FamilyMemberTarget> _allMembers = [
    FamilyMemberTarget(
      id: 'daughter',
      name: 'Priya (प्रिया)',
      relationHi: 'आपकी बेटी (Daughter)',
      relationEn: 'Your Daughter',
      icon: Icons.face_3_rounded,
      color: Color(0xFFE91E63),
    ),
    FamilyMemberTarget(
      id: 'son',
      name: 'Rahul (राहुल)',
      relationHi: 'आपका बेटा (Son)',
      relationEn: 'Your Son',
      icon: Icons.face_rounded,
      color: Color(0xFF1976D2),
    ),
    FamilyMemberTarget(
      id: 'grandson',
      name: 'Aarav (आरव)',
      relationHi: 'आपका पोता (Grandson)',
      relationEn: 'Your Grandson',
      icon: Icons.child_care_rounded,
      color: Color(0xFFF57C00),
    ),
    FamilyMemberTarget(
      id: 'asha',
      name: 'Sunita Didi (सुनीता दीदी)',
      relationHi: 'आपकी आशा सहायिका (ASHA Helper)',
      relationEn: 'Your ASHA Health Helper',
      icon: Icons.medical_services_rounded,
      color: Color(0xFF00897B),
    ),
  ];

  int _currentRound = 0;
  int _correctCount = 0;
  final _stopwatch = Stopwatch();
  final _rng = math.Random();

  late List<FamilyMemberTarget> _roundTargets;
  late FamilyMemberTarget _currentTarget;
  late List<FamilyMemberTarget> _currentOptions;
  String? _selectedId;
  bool _isAnswered = false;
  Timer? _roundTimer;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    _roundTargets = List.of(_allMembers)..shuffle(_rng);
    _currentRound = 0;
    _correctCount = 0;
    _loadRound();
  }

  void _loadRound() {
    _selectedId = null;
    _isAnswered = false;
    _currentTarget = _roundTargets[_currentRound % _roundTargets.length];

    // Pick options including correct one
    final options = <FamilyMemberTarget>{_currentTarget};
    final others = List.of(_allMembers)..removeWhere((m) => m.id == _currentTarget.id);
    others.shuffle(_rng);
    while (options.length < 2 && others.isNotEmpty) {
      options.add(others.removeLast());
    }

    _currentOptions = options.toList()..shuffle(_rng);

    _stopwatch
      ..reset()
      ..start();

    // Narrate instruction
    ref.read(ttsServiceProvider).speak(
          'Find ${_currentTarget.name}. ${_currentTarget.relationHi} kahan hain?',
          langCode: 'hi',
        );
    setState(() {});
  }

  void _handleOptionSelect(FamilyMemberTarget selected) {
    if (_isAnswered) return;
    _stopwatch.stop();
    final elapsedMs = _stopwatch.elapsedMilliseconds;
    final isCorrect = selected.id == _currentTarget.id;

    setState(() {
      _selectedId = selected.id;
      _isAnswered = true;
      if (isCorrect) _correctCount++;
    });

    // Record Telemetry
    _recordTelemetry(
      reactionMs: elapsedMs,
      isCorrect: isCorrect,
    );

    // Audio Feedback
    if (isCorrect) {
      ref.read(ttsServiceProvider).speak('शाबाश! यह ${_currentTarget.name} हैं।', langCode: 'hi');
    } else {
      ref.read(ttsServiceProvider).speak('यह ${_currentTarget.name} हैं। कोई बात नहीं, आगे बढ़ते हैं।', langCode: 'hi');
    }

    // Move to next round
    _roundTimer?.cancel();
    _roundTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      if (_currentRound + 1 < _roundTargets.length) {
        setState(() => _currentRound++);
        _loadRound();
      } else {
        _showCompletion();
      }
    });
  }

  void _recordTelemetry({required int reactionMs, required bool isCorrect}) {
    final patientId = ref.read(deviceIdentityProvider).valueOrNull?.patientId ?? 'patient-local';
    final event = TelemetryEvent(
      patientId: patientId,
      gameId: 'face-match',
      reactionMs: reactionMs,
      spatialErrorPx: isCorrect ? 0.0 : 1.0,
      patternErrors: isCorrect ? 0 : 1,
      capturedAt: DateTime.now(),
    );

    ref.read(syncManagerProvider.notifier).enqueue(event);
  }

  void _showCompletion() {
    final stars = _correctCount >= 3 ? 3 : (_correctCount >= 2 ? 2 : 1);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameCompletionDialog(
        title: 'बहुत बढ़िया! (Well Done!)',
        subtitle: 'You completed the Family Photo Match!\n($_correctCount/${_roundTargets.length} Correct)',
        stars: stars,
        onPlayAgain: _startNewGame,
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
          'Family Photo Match',
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
              '${_currentRound + 1} / ${_roundTargets.length}',
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
              // Prompt Question Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: _currentTarget.color.withOpacity(0.15),
                      child: Icon(_currentTarget.icon, size: 44, color: _currentTarget.color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Find (पहचानिए):',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey),
                          ),
                          Text(
                            _currentTarget.name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            _currentTarget.relationHi,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _currentTarget.color),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Repeat Voice Prompt',
                      icon: const Icon(Icons.volume_up_rounded, size: 36, color: Color(0xFF00695C)),
                      onPressed: () {
                        ref.read(ttsServiceProvider).speak(
                              'Please tap on ${_currentTarget.name}. ${_currentTarget.relationHi}',
                              langCode: 'hi',
                            );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Tap the matching photo card below:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
              ),
              const SizedBox(height: 16),

              // Options Grid
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _currentOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, idx) {
                    final option = _currentOptions[idx];
                    final isSelected = _selectedId == option.id;
                    final isCorrect = option.id == _currentTarget.id;

                    Color borderColor = Colors.grey.shade300;
                    Color bgColor = Colors.white;

                    if (_isAnswered) {
                      if (isCorrect) {
                        borderColor = const Color(0xFF2E7D32);
                        bgColor = const Color(0xFFE8F5E9);
                      } else if (isSelected) {
                        borderColor = const Color(0xFFC62828);
                        bgColor = const Color(0xFFFFEBEE);
                      }
                    }

                    return InkWell(
                      onTap: () => _handleOptionSelect(option),
                      borderRadius: BorderRadius.circular(24),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: borderColor,
                            width: isSelected || (_isAnswered && isCorrect) ? 3 : 1.5,
                          ),
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
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: option.color.withOpacity(0.14),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(option.icon, size: 40, color: option.color),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.name,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                  ),
                                  Text(
                                    option.relationEn,
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                            if (_isAnswered)
                              Icon(
                                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                color: isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                size: 36,
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
