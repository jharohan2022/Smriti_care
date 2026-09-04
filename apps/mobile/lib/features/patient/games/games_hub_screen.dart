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

class GamesHubScreen extends ConsumerWidget {
  const GamesHubScreen({super.key});

  static const List<GameHubItem> _games = [
    GameHubItem(
      titleHi: 'परिवार की पहचान (Family Match)',
      titleEn: 'Family & Photo Match',
      description: 'Match familiar faces of your family and helpers',
      route: '/game/face-match',
      icon: Icons.family_restroom_rounded,
      color: Color(0xFFE91E63),
      badge: 'Faces & Photos',
    ),
    GameHubItem(
      titleHi: 'आवाज़ की पहचान (Sound Memory)',
      titleEn: 'Audio & Sound Recall',
      description: 'Listen to familiar bells, rain, birds & sounds',
      route: '/game/sound-recall',
      icon: Icons.graphic_eq_rounded,
      color: Color(0xFF0288D1),
      badge: 'Auditory',
    ),
    GameHubItem(
      titleHi: 'रंग और आकार (Pattern Sequence)',
      titleEn: 'Pattern & Color Memory',
      description: 'Follow and repeat the shining color patterns',
      route: '/game/pattern-sequence',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFF388E3C),
      badge: 'Sequences',
    ),
    GameHubItem(
      titleHi: 'रफ़्तार और ध्यान (Reflex Target)',
      titleEn: 'Speed & Precision Tap',
      description: 'Tap the glowing targets as soon as they appear',
      route: '/game/reaction-tap',
      icon: Icons.touch_app_rounded,
      color: Color(0xFFE65100),
      badge: 'Reflexes',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const narration =
        'Choose a memory game to play. Family Photo Match, Sound Memory, Pattern Sequence, or Reflex Target.';

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
          itemCount: _games.length,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (context, idx) {
            final game = _games[idx];

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
