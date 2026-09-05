import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/tts_service.dart';

class GameHubItem {
  const GameHubItem({
    required this.titleHi,
    required this.titleEn,
    required this.description,
    required this.route,
    required this.icon,
    required this.color,
    required this.badge,
  });

  final String titleHi;
  final String titleEn;
  final String description;
  final String route;
  final IconData icon;
  final Color color;
  final String badge;
}

/// Games Hub displaying cognitive exercises.
/// The order of games is dynamically randomized on every visit to keep sessions fresh.
class GamesHubScreen extends ConsumerStatefulWidget {
  const GamesHubScreen({super.key});

  @override
  ConsumerState<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends ConsumerState<GamesHubScreen> {
  static const List<GameHubItem> _catalog = [
    GameHubItem(
      titleHi: 'मेमोरी बॉक्स (Memory Box)',
      titleEn: 'Memory Box (Visual Recall)',
      description: 'याद रखें बक्से में रखी 3-5 वस्तुओं को (Short-term & working memory)',
      route: '/game/memory-box',
      icon: Icons.all_inbox_rounded,
      color: Color(0xFF8E24AA),
      badge: 'Visual Recall (दृष्टि स्मृति)',
    ),
    GameHubItem(
      titleHi: 'मेरी दुनिया (Meri Duniya)',
      titleEn: 'Meri Duniya (Spatial Orientation)',
      description: 'अपने गाँव के रास्तों और लैंडमार्क को पहचानें (Route & Spatial Recall)',
      route: '/game/meri-duniya',
      icon: Icons.map_rounded,
      color: Color(0xFF00897B),
      badge: 'Spatial Memory (दिशा स्मृति)',
    ),
    GameHubItem(
      titleHi: 'मेमोरी ट्री (Memory Tree)',
      titleEn: 'Memory Tree (Relationship Recall)',
      description: 'अपने असली परिवार के सदस्यों और तस्वीरों को पहचानें (Facial & Family Recall)',
      route: '/game/memory-tree',
      icon: Icons.park_rounded,
      color: Color(0xFFE91E63),
      badge: 'Autobiographical (पारिवारिक स्मृति)',
    ),
    GameHubItem(
      titleHi: 'मेरा बाजार (Mera Bazaar)',
      titleEn: 'Mera Bazaar (Executive Function)',
      description: 'बजट के साथ खरीदारी की चुनौती (IADL & Budget Calculation)',
      route: '/game/mera-bazaar',
      icon: Icons.shopping_basket_rounded,
      color: Color(0xFFF57C00),
      badge: 'Executive Function (दैनिक कार्य क्षमता)',
    ),
  ];

  late List<GameHubItem> _displayedGames;

  @override
  void initState() {
    super.initState();
    // Shuffle games catalog every single time the user opens the hub
    _displayedGames = List.of(_catalog)..shuffle(math.Random());
  }

  @override
  Widget build(BuildContext context) {
    const narration =
        'Choose a memory game: Memory Box visual recall, Meri Duniya spatial orientation, Memory Tree family recall, or Mera Bazaar executive budget shopping.';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 32, color: Color(0xFF00695C)),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Memory Games (दिमागी खेल)',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF00695C)),
        ),
        actions: [
          IconButton(
            tooltip: 'Voice Help',
            icon: const Icon(Icons.volume_up_rounded, size: 34, color: Color(0xFF00695C)),
            onPressed: () => ref.read(ttsServiceProvider).speak(narration, langCode: 'hi'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          physics: const BouncingScrollPhysics(),
          itemCount: _displayedGames.length,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (context, idx) {
            final game = _displayedGames[idx];

            return InkWell(
              onTap: () {
                ref.read(ttsServiceProvider).speak(
                      'Starting ${game.titleEn}. ${game.titleHi}',
                      langCode: 'hi',
                    );
                context.go(game.route);
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: game.color.withOpacity(0.35), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: game.color.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: game.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(game.icon, size: 44, color: game.color),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: game.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              game.badge,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: game.color),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            game.titleHi,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            game.description,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.play_circle_filled_rounded, size: 44, color: game.color),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
