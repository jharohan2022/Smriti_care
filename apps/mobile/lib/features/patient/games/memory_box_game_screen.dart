import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/cognitive_screening_service.dart';
import '../../../core/services/tts_service.dart';
import 'widgets/game_completion_dialog.dart';

class MemoryBoxItem {
  final String id;
  final String titleHi;
  final String titleEn;
  final String imagePath;

  const MemoryBoxItem({
    required this.id,
    required this.titleHi,
    required this.titleEn,
    required this.imagePath,
  });
}

class MemoryBoxGameScreen extends ConsumerStatefulWidget {
  const MemoryBoxGameScreen({super.key});

  @override
  ConsumerState<MemoryBoxGameScreen> createState() => _MemoryBoxGameScreenState();
}

class _MemoryBoxGameScreenState extends ConsumerState<MemoryBoxGameScreen> {
  static const List<MemoryBoxItem> _allPool = [
    MemoryBoxItem(id: 'key', titleHi: 'चाबी (Key)', titleEn: 'Key', imagePath: 'assets/images/targets/key.jpg'),
    MemoryBoxItem(id: 'cup', titleHi: 'कप (Cup)', titleEn: 'Cup', imagePath: 'assets/images/targets/cup.jpg'),
    MemoryBoxItem(id: 'bell', titleHi: 'घंटी (Bell)', titleEn: 'Bell', imagePath: 'assets/images/targets/bell.jpg'),
    MemoryBoxItem(id: 'lamp', titleHi: 'दीया (Lamp)', titleEn: 'Lamp', imagePath: 'assets/images/targets/lamp.jpg'),
    MemoryBoxItem(id: 'flower', titleHi: 'फूल (Flower)', titleEn: 'Flower', imagePath: 'assets/images/targets/flower.jpg'),
    MemoryBoxItem(id: 'leaf', titleHi: 'पत्ता (Leaf)', titleEn: 'Leaf', imagePath: 'assets/images/targets/leaf.jpg'),
    MemoryBoxItem(id: 'sun', titleHi: 'सूरज (Sun)', titleEn: 'Sun', imagePath: 'assets/images/targets/sun.jpg'),
    MemoryBoxItem(id: 'heart', titleHi: 'दिल (Heart)', titleEn: 'Heart', imagePath: 'assets/images/targets/heart.jpg'),
  ];

  late List<MemoryBoxItem> _targetItems;
  late List<MemoryBoxItem> _optionItems;
  final Set<String> _selectedIds = {};

  bool _isBoxOpen = true;
  int _memorizeTimer = 6;
  Timer? _timer;
  int _score = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    final screening = ref.read(cognitiveScreeningProvider);
    final count = screening?.config.itemCount ?? 4; // 3 to 5 items based on dementia stage

    final pool = List.of(_allPool)..shuffle();
    _targetItems = pool.take(count).toList();

    final remaining = pool.skip(count).toList()..shuffle();
    _optionItems = List.of(_targetItems);
    _optionItems.addAll(remaining.take(6 - _targetItems.length));
    _optionItems.shuffle();

    _isBoxOpen = true;
    _memorizeTimer = 6;
    _selectedIds.clear();
    _isFinished = false;

    _startMemorizeCountdown();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(
            'मेमोरी बॉक्स ध्यान से देखिए। बॉक्स में रखी वस्तुओं को याद रखिए।',
            langCode: 'hi',
          );
    });
  }

  void _startMemorizeCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_memorizeTimer > 1) {
        setState(() {
          _memorizeTimer--;
        });
      } else {
        t.cancel();
        setState(() {
          _isBoxOpen = false;
        });
        ref.read(ttsServiceProvider).speak(
              'बॉक्स बंद हो गया है। अब बताइए बॉक्स के अंदर कौन सी चीजें थीं?',
              langCode: 'hi',
            );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleSelect(String id) {
    if (_isBoxOpen || _isFinished) return;
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        if (_selectedIds.length < _targetItems.length) {
          _selectedIds.add(id);
        }
      }
    });
  }

  void _checkAnswer() {
    int correctCount = 0;
    for (final target in _targetItems) {
      if (_selectedIds.contains(target.id)) {
        correctCount++;
      }
    }

    _score = (correctCount * 10 / _targetItems.length).round();
    setState(() {
      _isFinished = true;
    });

    ref.read(ttsServiceProvider).speak(
          'शाबाश! आपने ${_targetItems.length} में से $correctCount वस्तुएं सही पहचानीं।',
          langCode: 'hi',
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameCompletionDialog(
        title: 'Memory Box (विज़ुअल रिकॉल)',
        subtitle: 'आपने ${_targetItems.length} में से $correctCount वस्तुएं सही पहचानीं।',
        stars: correctCount == _targetItems.length ? 3 : (correctCount > 0 ? 2 : 1),
        onPlayAgain: () {
          _setupGame();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandPurple = Color(0xFF673AB7);
    const textDark = Color(0xFF1E1B4B);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 28, color: textDark),
          onPressed: () => context.go('/khel'),
        ),
        title: const Text(
          'Memory Box (विज़ुअल रिकॉल)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: brandPurple, size: 28),
            onPressed: () {
              ref.read(ttsServiceProvider).speak(
                    _isBoxOpen
                        ? 'बॉक्स में रखी वस्तुओं को याद रखिए।'
                        : 'बॉक्स के अंदर कौन-कौन सी चीजें थीं?',
                    langCode: 'hi',
                  );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header Card & Status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: brandPurple.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: brandPurple.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _isBoxOpen ? Icons.all_out_rounded : Icons.markunread_mailbox_rounded,
                      color: brandPurple,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isBoxOpen ? 'Phase 1: Memorize Items' : 'Phase 2: Recall Items',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textDark),
                          ),
                          Text(
                            _isBoxOpen
                                ? 'Remember all ${_targetItems.length} items in the box'
                                : 'Select ${_targetItems.length} items that were inside the box',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    if (_isBoxOpen)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_memorizeTimer}s',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // The Memory Box Visual Container
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: double.infinity,
                height: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isBoxOpen
                        ? [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)]
                        : [const Color(0xFF475569), const Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: _isBoxOpen
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '📦 WOODEN MEMORY BOX OPEN 📦',
                            style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: _targetItems.map((item) {
                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Image.asset(
                                  item.imagePath,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_rounded, color: Colors.amberAccent, size: 54),
                          SizedBox(height: 10),
                          Text(
                            '🔒 MEMORY BOX IS CLOSED 🔒',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Recall & select items below',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 20),

              // Selection Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isBoxOpen ? 'Items to memorize:' : 'Select items that were in the box (${_selectedIds.length}/${_targetItems.length}):',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textDark),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: _optionItems.length,
                        itemBuilder: (context, index) {
                          final item = _optionItems[index];
                          final isSelected = _selectedIds.contains(item.id);

                          return GestureDetector(
                            onTap: () => _toggleSelect(item.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected ? brandPurple : const Color(0xFFE2E8F0),
                                  width: isSelected ? 3 : 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected ? brandPurple.withOpacity(0.2) : Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.asset(
                                          item.imagePath,
                                          width: 52,
                                          height: 52,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: brandPurple,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.check, color: Colors.white, size: 14),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.titleHi.split(' ')[0],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? brandPurple : textDark,
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
                ),
              ),

              // Submit Button
              if (!_isBoxOpen)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedIds.length == _targetItems.length ? _checkAnswer : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                    ),
                    child: Text(
                      'Check Memory Box (${_selectedIds.length}/${_targetItems.length})',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
