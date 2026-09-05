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

class SoundItem {
  const SoundItem({
    required this.id,
    required this.nameHi,
    required this.nameEn,
    required this.soundCue,
    required this.icon,
    required this.color,
    required this.imagePath,
  });

  final String id;
  final String nameHi;
  final String nameEn;
  final String soundCue;
  final IconData icon;
  final Color color;
  final String imagePath;
}

class SoundRecallGameScreen extends ConsumerStatefulWidget {
  const SoundRecallGameScreen({super.key});

  @override
  ConsumerState<SoundRecallGameScreen> createState() => _SoundRecallGameScreenState();
}

class _SoundRecallGameScreenState extends ConsumerState<SoundRecallGameScreen>
    with SingleTickerProviderStateMixin {
  static const List<SoundItem> _allSounds = [
    SoundItem(
      id: 'temple_bell',
      nameHi: 'मंदिर की घंटी (Temple Bell)',
      nameEn: 'Temple Bell',
      soundCue: 'Ting Ting... Dong! (मंदिर की पवित्र घंटी)',
      icon: Icons.notifications_active_rounded,
      color: Color(0xFFF57F17),
      imagePath: 'assets/images/targets/bell.jpg',
    ),
    SoundItem(
      id: 'rain',
      nameHi: 'बारिश और बादल (Rain & Thunder)',
      nameEn: 'Rain Falling',
      soundCue: 'Tip Tip Barsa Paani... Rim Jhim (बारिश की आवाज़)',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF0288D1),
      imagePath: 'assets/images/targets/leaf.jpg',
    ),
    SoundItem(
      id: 'birds',
      nameHi: 'सुबह की चिड़िया (Morning Birds)',
      nameEn: 'Chirping Birds',
      soundCue: 'Chee Chee... Chuhakna (सुबह चिड़ियों का चहकना)',
      icon: Icons.flutter_dash_rounded,
      color: Color(0xFF43A047),
      imagePath: 'assets/images/targets/sun.jpg',
    ),
    SoundItem(
      id: 'clock',
      nameHi: 'दीवार घड़ी (Clock Ticking)',
      nameEn: 'Wall Clock',
      soundCue: 'Tik Tik Tik Tik (घड़ी की सुई की आवाज़)',
      icon: Icons.access_time_filled_rounded,
      color: Color(0xFF5E35B1),
      imagePath: 'assets/images/targets/eye.jpg',
    ),
    SoundItem(
      id: 'flute',
      nameHi: 'बांसुरी की धुन (Flute Melody)',
      nameEn: 'Sweet Flute',
      soundCue: 'Madhur Baansuri ki Dhun (सुरीली बांसुरी)',
      icon: Icons.music_note_rounded,
      color: Color(0xFFD81B60),
      imagePath: 'assets/images/targets/heart.jpg',
    ),
    SoundItem(
      id: 'tractor',
      nameHi: 'खेत का ट्रैक्टर (Farm Tractor)',
      nameEn: 'Farm Tractor',
      soundCue: 'Dug Dug Dug... Khet ka Tractor (ट्रैक्टर इंजन)',
      icon: Icons.agriculture_rounded,
      color: Color(0xFFE65100),
      imagePath: 'assets/images/targets/key.jpg',
    ),
  ];

  int _currentRound = 0;
  int _correctCount = 0;
  int _repeatCount = 0;
  final _stopwatch = Stopwatch();
  final _rng = math.Random();

  late List<SoundItem> _roundSounds;
  late SoundItem _currentSound;
  late List<SoundItem> _currentOptions;
  String? _selectedId;
  bool _isAnswered = false;
  bool _isPlayingSound = false;
  Timer? _roundTimer;
  Timer? _soundPromptTimer;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _startNewGame();
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    _soundPromptTimer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  void _startNewGame() {
    _roundSounds = List.of(_allSounds)..shuffle(_rng);
    _currentRound = 0;
    _correctCount = 0;
    _loadRound();
  }

  void _loadRound() {
    _selectedId = null;
    _isAnswered = false;
    _repeatCount = 0;
    _currentSound = _roundSounds[_currentRound % _roundSounds.length];

    final options = <SoundItem>{_currentSound};
    final others = List.of(_allSounds)..removeWhere((s) => s.id == _currentSound.id);
    others.shuffle(_rng);
    options.addAll(others.take(2));

    _currentOptions = options.toList()..shuffle(_rng);

    _stopwatch
      ..reset()
      ..start();

    _playSoundPrompt();
    setState(() {});
  }

  void _playSoundPrompt() {
    setState(() => _isPlayingSound = true);
    ref.read(ttsServiceProvider).speak(
          'Listen carefully. Yeh aawaaz kis cheez ki hai? ${_currentSound.soundCue}',
          langCode: 'hi',
        );

    _soundPromptTimer?.cancel();
    _soundPromptTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isPlayingSound = false);
    });
  }

  void _handleOptionSelect(SoundItem selected) {
    if (_isAnswered) return;
    _stopwatch.stop();
    final elapsedMs = _stopwatch.elapsedMilliseconds;
    final isCorrect = selected.id == _currentSound.id;

    setState(() {
      _selectedId = selected.id;
      _isAnswered = true;
      if (isCorrect) _correctCount++;
    });

    _recordTelemetry(
      reactionMs: elapsedMs,
      isCorrect: isCorrect,
    );

    if (isCorrect) {
      ref.read(ttsServiceProvider).speak('शाबाश! बिल्कुल सही पहचान।', langCode: 'hi');
    } else {
      ref.read(ttsServiceProvider).speak('यह आवाज़ ${_currentSound.nameHi} की है।', langCode: 'hi');
    }

    _roundTimer?.cancel();
    _roundTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      if (_currentRound + 1 < _roundSounds.length.clamp(0, 4)) {
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
      gameId: 'sound-recall',
      reactionMs: reactionMs,
      spatialErrorPx: isCorrect ? 0.0 : 1.0,
      patternErrors: _repeatCount,
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
        title: 'शाबाश! (Excellent!)',
        subtitle: 'You completed Sound Memory!\n($_correctCount/4 Correct Identification)',
        stars: stars,
        onPlayAgain: _startNewGame,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const totalRounds = 4;

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
          'Awaz Pehchaniye (Sound Memory)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF00695C)),
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
              '${_currentRound + 1} / $totalRounds',
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
              // Sound Player Card with animated waves & real sound button
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF81D4FA), width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(7, (i) {
                        return AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            final factor = math.sin((_waveController.value * math.pi) + (i * 0.5)).abs();
                            final height = _isPlayingSound ? 20 + (factor * 35) : 12.0;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: height,
                              decoration: BoxDecoration(
                                color: _isPlayingSound ? const Color(0xFF0288D1) : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'आवाज़ सुनिए (Listen to Real Sound):',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        _repeatCount++;
                        _playSoundPrompt();
                      },
                      icon: const Icon(Icons.volume_up_rounded, size: 30),
                      label: const Text(
                        'Play Real Sound Again (आवाज़ पुनः सुनें)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0288D1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'What made this sound? (यह किसकी आवाज़ है?)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
              ),
              const SizedBox(height: 14),

              // Photographic Options List
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _currentOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, idx) {
                    final option = _currentOptions[idx];
                    final isSelected = _selectedId == option.id;
                    final isCorrect = option.id == _currentSound.id;

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
                      borderRadius: BorderRadius.circular(22),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(22),
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                option.imagePath,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.nameHi,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    option.nameEn,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            if (_isAnswered)
                              Icon(
                                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                color: isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                size: 34,
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
