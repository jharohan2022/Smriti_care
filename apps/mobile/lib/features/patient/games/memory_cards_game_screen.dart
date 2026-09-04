import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/tts_service.dart';

class MemoryTileItem {
  final String label;
  final String labelHi;
  final String emoji;
  final Color bgColor;
  final Color borderColor;

  const MemoryTileItem({
    required this.label,
    required this.labelHi,
    required this.emoji,
    required this.bgColor,
    required this.borderColor,
  });
}

class MemoryCardsGameScreen extends ConsumerStatefulWidget {
  const MemoryCardsGameScreen({super.key});

  @override
  ConsumerState<MemoryCardsGameScreen> createState() => _MemoryCardsGameScreenState();
}

class _MemoryCardsGameScreenState extends ConsumerState<MemoryCardsGameScreen> {
  final List<MemoryTileItem> _items = const [
    MemoryTileItem(
      label: 'Mango',
      labelHi: 'आम (Mango)',
      emoji: '🥭',
      bgColor: Color(0xFFFEF3C7),
      borderColor: Color(0xFFFCD34D),
    ),
    MemoryTileItem(
      label: 'Flower',
      labelHi: 'फूल (Flower)',
      emoji: '🌸',
      bgColor: Color(0xFFFCE7F3),
      borderColor: Color(0xFFF472B6),
    ),
    MemoryTileItem(
      label: 'Bird',
      labelHi: 'चिड़िया (Bird)',
      emoji: '🐦',
      bgColor: Color(0xFFE0F2FE),
      borderColor: Color(0xFF38BDF8),
    ),
    MemoryTileItem(
      label: 'Tree',
      labelHi: 'पेड़ (Tree)',
      emoji: '🌳',
      bgColor: Color(0xFFDCFCE7),
      borderColor: Color(0xFF4ADE80),
    ),
    MemoryTileItem(
      label: 'Cup',
      labelHi: 'कप (Cup)',
      emoji: '☕',
      bgColor: Color(0xFFF1F5F9),
      borderColor: Color(0xFF94A3B8),
    ),
    MemoryTileItem(
      label: 'Cat',
      labelHi: 'बिल्ली (Cat)',
      emoji: '🐱',
      bgColor: Color(0xFFFFEDD5),
      borderColor: Color(0xFFFB923C),
    ),
  ];

  final Set<int> _selectedIndices = {};
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(
            'चलो याद करें! इन तस्वीरों को ध्यान से देखिए और याद रखिए।',
          );
    });
  }

  void _toggleTile(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
      _isSuccess = _selectedIndices.length >= 3;
    });

    if (_isSuccess) {
      ref.read(ttsServiceProvider).speak('बहुत अच्छा! आपने सही याद किया!');
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandPurple = Color(0xFF6B4EE6);
    const textDark = Color(0xFF1E1B4B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textDark, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chalo Yaad Karein!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
            Text(
              'In tasveeron ko yaad rakhiye',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // 2x3 Grid of Memory Items
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.15,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final isSelected = _selectedIndices.contains(index);

                    return GestureDetector(
                      onTap: () => _toggleTile(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: item.bgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? brandPurple : item.borderColor,
                            width: isSelected ? 3.0 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: item.borderColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.labelHi,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Feedback Speech Bubble from Elder Avatar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Text('👴', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bahut accha!',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4C1D95),
                            ),
                          ),
                          Text(
                            'Aapne sahi yaad kiya!',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6D28D9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isSuccess)
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action Button: "Next Round ➔"
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/game/word-recall');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPurple,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next Round',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 22),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
