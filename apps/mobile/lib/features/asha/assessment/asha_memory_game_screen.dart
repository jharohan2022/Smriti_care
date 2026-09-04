import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/tts_service.dart';

class AshaMemoryGameScreen extends ConsumerStatefulWidget {
  const AshaMemoryGameScreen({super.key});

  @override
  ConsumerState<AshaMemoryGameScreen> createState() => _AshaMemoryGameScreenState();
}

class _AshaMemoryGameScreenState extends ConsumerState<AshaMemoryGameScreen> {
  final Set<int> _selected = {};

  final List<({String label, String emoji, Color bg, Color border})> _items = const [
    (label: 'Aam (आम)', emoji: '🥭', bg: Color(0xFFFEF3C7), border: Color(0xFFFCD34D)),
    (label: 'Phool (फूल)', emoji: '🌸', bg: Color(0xFFFCE7F3), border: Color(0xFFF472B6)),
    (label: 'Chidiya (चिड़िया)', emoji: '🐦', bg: Color(0xFFE0F2FE), border: Color(0xFF38BDF8)),
    (label: 'Ped (पेड़)', emoji: '🌳', bg: Color(0xFFDCFCE7), border: Color(0xFF4ADE80)),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(
            'चलो याद करें! इन तस्वीरों को ध्यान से देखिए।',
          );
    });
  }

  void _toggle(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const emeraldBrand = Color(0xFF059669);
    const textDark = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textDark, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Chalo Yaad Karein!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: emeraldBrand, size: 28),
            onPressed: () {
              ref.read(ttsServiceProvider).speak(
                    'इन तस्वीरों को ध्यान से देखिए और याद रखिए।',
                  );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'In tasveeron ko dhyan se dekhiye',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 20),

              // 2x2 Visual Tiles Grid
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final isSelected = _selected.contains(index);

                    return GestureDetector(
                      onTap: () => _toggle(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: item.bg,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected ? emeraldBrand : item.border,
                            width: isSelected ? 3.5 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: item.border.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item.emoji, style: const TextStyle(fontSize: 52)),
                            const SizedBox(height: 8),
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
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

              const SizedBox(height: 16),

              // Action Button: "Agla Round ➔"
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/asha/assessment/summary');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emeraldBrand,
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
                        'Agla Round',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 22),
                    ],
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
