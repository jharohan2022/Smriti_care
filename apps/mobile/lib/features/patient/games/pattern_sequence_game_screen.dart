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

class PatternSymbol {
  const PatternSymbol({
    required this.id,
    required this.nameHi,
    required this.nameEn,
    required this.icon,
    required this.color,
  });

  final int id;
  final String nameHi;
  final String nameEn;
  final IconData icon;
  final Color color;
}

class PatternSequenceGameScreen extends ConsumerStatefulWidget {
  const PatternSequenceGameScreen({super.key});

  @override
  ConsumerState<PatternSequenceGameScreen> createState() => _PatternSequenceGameScreenState();
}

enum _GameState { explaining, demonstrating, playerTurn, roundSuccess, completed }

class _PatternSequenceGameScreenState extends ConsumerState<PatternSequenceGameScreen> {
  static const List<PatternSymbol> _symbols = [
    PatternSymbol(
      id: 0,
      nameHi: 'सूरज (Sun)',
      nameEn: 'Sun',
      icon: Icons.wb_sunny_rounded,
      color: Color(0xFFFFA000),
    ),
    PatternSymbol(
      id: 1,
      nameHi: 'पानी (Water)',
      nameEn: 'Water',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF1976D2),
    ),
    PatternSymbol(
      id: 2,
      nameHi: 'पत्ती (Leaf)',
      nameEn: 'Leaf',
      icon: Icons.eco_rounded,
      color: Color(0xFF388E3C),
    ),
    PatternSymbol(
      id: 3,
      nameHi: 'सितारा (Star)',
      nameEn: 'Star',
      icon: Icons.star_rounded,
      color: Color(0xFFE91E63),
    ),
  ];

  final _rng = math.Random();
  final _stopwatch = Stopwatch();

  _GameState _state = _GameState.explaining;
  int _sequenceLength = 2; // Starts at length 2, goes to 3 then 4
  static const int _maxSequenceLength = 4;

  List<int> _currentSequence = [];
  List<int> _playerInput = [];
  int? _highlightedSymbolId;
  int _mistakes = 0;
  Timer? _roundTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startNewGame());
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    _sequenceLength = 2;
    _mistakes = 0;
    _startRound();
  }

  void _startRound() {
    setState(() {
      _state = _GameState.demonstrating;
      _playerInput = [];
      _currentSequence = List.generate(_sequenceLength, (_) => _rng.nextInt(_symbols.length));
    });

    ref.read(ttsServiceProvider).speak(
          'Watch the lights carefully. Dhyan se dekhiye aur yaad rakhiye.',
          langCode: 'hi',
        );

    _roundTimer?.cancel();
    _roundTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) _playDemonstrationSequence();
    });
  }

  Future<void> _playDemonstrationSequence() async {
    for (int i = 0; i < _currentSequence.length; i++) {
      if (!mounted) return;
      final symbolId = _currentSequence[i];
      setState(() => _highlightedSymbolId = symbolId);
      await Future.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      setState(() => _highlightedSymbolId = null);
      await Future.delayed(const Duration(milliseconds: 280));
    }

    if (!mounted) return;
    setState(() {
      _state = _GameState.playerTurn;
    });

    _stopwatch
      ..reset()
      ..start();

    ref.read(ttsServiceProvider).speak(
          'Now your turn! Ab aap wahi button dabaiye.',
          langCode: 'hi',
        );
  }

  void _handleSymbolTap(int symbolId) {
    if (_state != _GameState.playerTurn) return;

    // Flash tapped symbol
    setState(() {
      _highlightedSymbolId = symbolId;
      _playerInput.add(symbolId);
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _highlightedSymbolId = null);
    });

    final currentIndex = _playerInput.length - 1;
    final isCorrectSoFar = _playerInput[currentIndex] == _currentSequence[currentIndex];

    if (!isCorrectSoFar) {
      _mistakes++;
      ref.read(ttsServiceProvider).speak(
            'Koi baat nahi, phir se dekhte hain.',
            langCode: 'hi',
          );

      _recordTelemetry(
        isRoundSuccess: false,
        reactionMs: _stopwatch.elapsedMilliseconds,
      );

      // Re-play sequence
      Future.delayed(const Duration(milliseconds: 1200), _startRound);
      return;
    }

    // Check if player completed sequence
    if (_playerInput.length == _currentSequence.length) {
      _stopwatch.stop();
      _recordTelemetry(
        isRoundSuccess: true,
        reactionMs: _stopwatch.elapsedMilliseconds,
      );

      setState(() => _state = _GameState.roundSuccess);
      ref.read(ttsServiceProvider).speak(
            'Shabaash! Bahut accha.',
            langCode: 'hi',
          );

      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        if (_sequenceLength < _maxSequenceLength) {
          setState(() => _sequenceLength++);
          _startRound();
        } else {
          _showCompletion();
        }
      });
    }
  }

  void _recordTelemetry({required bool isRoundSuccess, required int reactionMs}) {
    final patientId = ref.read(deviceIdentityProvider).valueOrNull?.patientId ?? 'patient-local';
    final event = TelemetryEvent(
      patientId: patientId,
      gameId: 'pattern-sequence',
      reactionMs: reactionMs,
      spatialErrorPx: isRoundSuccess ? 0.0 : 1.0,
      patternErrors: isRoundSuccess ? _mistakes : _mistakes + 1,
      capturedAt: DateTime.now(),
    );

    ref.read(syncManagerProvider.notifier).enqueue(event);
  }

  void _showCompletion() {
    final stars = _mistakes == 0 ? 3 : (_mistakes <= 2 ? 2 : 1);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameCompletionDialog(
        title: 'अद्भुत! (Fantastic!)',
        subtitle: 'You completed all Pattern Sequences!\nMemory Level: $_maxSequenceLength Steps',
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
          'Pattern Sequence',
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
              'Level ${_sequenceLength - 1} / 3',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00695C)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instruction Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                    Icon(
                      _state == _GameState.demonstrating
                          ? Icons.visibility_rounded
                          : Icons.touch_app_rounded,
                      size: 36,
                      color: _state == _GameState.demonstrating ? const Color(0xFFE65100) : const Color(0xFF00695C),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _state == _GameState.demonstrating
                            ? 'Watch the pattern (ध्यान से देखें)...'
                            : 'Repeat the pattern (अब आप दोहराएं)',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _state == _GameState.demonstrating
                              ? const Color(0xFFE65100)
                              : const Color(0xFF00695C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 2x2 Grid of Giant Interactive Tiles
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _symbols.map((sym) {
                      final isLit = _highlightedSymbolId == sym.id;
                      return GestureDetector(
                        onTap: () => _handleSymbolTap(sym.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isLit ? sym.color : sym.color.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: isLit ? Colors.white : sym.color,
                              width: isLit ? 5 : 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: sym.color.withOpacity(isLit ? 0.6 : 0.2),
                                blurRadius: isLit ? 24 : 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                sym.icon,
                                size: 56,
                                color: isLit ? Colors.white : sym.color,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                sym.nameHi,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isLit ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
