import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/models/telemetry_event.dart';
import '../../../core/services/device_identity_service.dart';
import '../../../core/services/family_members_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/sync/sync_manager.dart';
import 'widgets/game_completion_dialog.dart';

class FaceMatchGameScreen extends ConsumerStatefulWidget {
  const FaceMatchGameScreen({super.key});

  @override
  ConsumerState<FaceMatchGameScreen> createState() => _FaceMatchGameScreenState();
}

class _FaceMatchGameScreenState extends ConsumerState<FaceMatchGameScreen> {
  int _currentRound = 0;
  int _correctCount = 0;
  final _stopwatch = Stopwatch();
  final _rng = math.Random();

  late List<FamilyMember> _roundTargets;
  late FamilyMember _currentTarget;
  late List<FamilyMember> _currentOptions;
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
    final allMembers = ref.read(familyMembersProvider);
    if (allMembers.isEmpty) return;

    _roundTargets = List.of(allMembers)..shuffle(_rng);
    _currentRound = 0;
    _correctCount = 0;
    _loadRound();
  }

  void _loadRound() {
    final allMembers = ref.read(familyMembersProvider);
    _selectedId = null;
    _isAnswered = false;
    _currentTarget = _roundTargets[_currentRound % _roundTargets.length];

    // Pick options including correct one
    final options = <FamilyMember>{_currentTarget};
    final others = List.of(allMembers)..removeWhere((m) => m.id == _currentTarget.id);
    others.shuffle(_rng);
    while (options.length < 3 && others.isNotEmpty) {
      options.add(others.removeLast());
    }

    _currentOptions = options.toList()..shuffle(_rng);

    _stopwatch
      ..reset()
      ..start();

    // Narrate instruction
    ref.read(ttsServiceProvider).speak(
          '${_currentTarget.name} को पहचानिए। ${_currentTarget.relation} कहाँ हैं?',
          langCode: 'hi',
        );
    setState(() {});
  }

  void _handleOptionSelect(FamilyMember selected) {
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
      ref.read(ttsServiceProvider).speak(
            'शाबाश! यह ${_currentTarget.name} हैं। ${_currentTarget.voiceClipText ?? ""}',
            langCode: 'hi',
          );
    } else {
      ref.read(ttsServiceProvider).speak(
            'यह ${_currentTarget.name} हैं। कोई बात नहीं, आगे बढ़ते हैं।',
            langCode: 'hi',
          );
    }

    // Move to next round
    _roundTimer?.cancel();
    _roundTimer = Timer(const Duration(milliseconds: 2200), () {
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
        subtitle: 'You matched your family members!\n($_correctCount/${_roundTargets.length} Correct)',
        stars: stars,
        onPlayAgain: _startNewGame,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandPurple = Color(0xFF6B4EE6);
    const textDark = Color(0xFF1E1B4B);

    final allMembers = ref.watch(familyMembersProvider);
    if (allMembers.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Family Match')),
        body: const Center(child: Text('No family members added yet.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 28, color: textDark),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Apno Ki Pehchan (Family Match)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textDark),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: brandPurple.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentRound + 1} / ${_roundTargets.length}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: brandPurple),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Prompt Question Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFDDD6FE), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: brandPurple.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: _currentTarget.avatarColor.withOpacity(0.15),
                      child: Icon(_currentTarget.icon, size: 40, color: _currentTarget.avatarColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pehchaniye (पहचानिए):',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                          Text(
                            _currentTarget.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textDark),
                          ),
                          Text(
                            _currentTarget.relation,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _currentTarget.avatarColor),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Voice Prompt',
                      icon: const Icon(Icons.volume_up_rounded, size: 30, color: brandPurple),
                      onPressed: () {
                        ref.read(ttsServiceProvider).speak(
                              '${_currentTarget.name} को पहचानिए। ${_currentTarget.relation}',
                              langCode: 'hi',
                            );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Neeche sahi tasveer par tap karein:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ),
              const SizedBox(height: 12),

              // Dynamic Options List
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _currentOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final option = _currentOptions[idx];
                    final isSelected = _selectedId == option.id;
                    final isCorrect = option.id == _currentTarget.id;

                    Color borderColor = const Color(0xFFE2E8F0);
                    Color bgColor = Colors.white;

                    if (_isAnswered) {
                      if (isCorrect) {
                        borderColor = const Color(0xFF10B981);
                        bgColor = const Color(0xFFECFDF5);
                      } else if (isSelected) {
                        borderColor = const Color(0xFFEF4444);
                        bgColor = const Color(0xFFFEF2F2);
                      }
                    }

                    return InkWell(
                      onTap: () => _handleOptionSelect(option),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: borderColor,
                            width: isSelected || (_isAnswered && isCorrect) ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: option.avatarColor.withOpacity(0.14),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(option.icon, size: 34, color: option.avatarColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textDark),
                                  ),
                                  Text(
                                    option.relation,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: option.avatarColor),
                                  ),
                                ],
                              ),
                            ),
                            if (_isAnswered)
                              Icon(
                                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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
