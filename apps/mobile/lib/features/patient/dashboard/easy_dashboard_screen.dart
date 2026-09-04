import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_state_provider.dart';
import '../../../core/config/flavor_config.dart';
import '../widgets/photo_card.dart';
import '../widgets/tts_narrator.dart';


/// The patient's home. Three large photographic cards — Games, Routine, and
/// ASHA Connect — and a persistent "Listen" button. This is the primary
/// dashboard for the Patient role.
class EasyDashboardScreen extends ConsumerWidget {
  const EasyDashboardScreen({super.key});

  static const _narration =
      'This is your home. Choose Games to play, My Day for your routine, '
      'or Call Helper to reach your health helper.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TtsNarrator(
      text: _narration,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE1BEE7), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset('assets/images/app_logo.png', fit: BoxFit.contain),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Home', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.1)),
                            Text(
                              'Smarana (स्मरणा)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.account_circle_rounded, size: 40, color: Color(0xFF00695C)),
                          tooltip: 'Account & Mode',
                          onSelected: (val) {
                            if (val == 'switch') {
                              ref.read(authStateProvider.notifier).switchRole(AppFlavor.asha);
                            } else if (val == 'logout') {
                              ref.read(authStateProvider.notifier).logout();
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'switch',
                              child: Row(
                                children: [
                                  Icon(Icons.medical_services_rounded, color: Color(0xFF1565C0)),
                                  SizedBox(width: 8),
                                  Text('Switch to ASHA Mode'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout_rounded, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Sign Out / Change Role'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        const ListenButton(text: _narration, size: 64),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView(
                    children: [
                      PhotoCard(
                        label: 'Games',
                        imageAsset: 'assets/images/games.jpg',
                        fallbackIcon: Icons.extension_rounded,
                        onTap: () => context.go('/games'),
                      ),
                      const SizedBox(height: 20),
                      PhotoCard(
                        label: 'My Day',
                        imageAsset: 'assets/images/routine.jpg',
                        fallbackIcon: Icons.wb_sunny_rounded,
                        accent: const Color(0xFFEF6C00),
                        onTap: () => context.go('/routine'),
                      ),
                      const SizedBox(height: 20),
                      PhotoCard(
                        label: 'Call Helper',
                        imageAsset: 'assets/images/asha.jpg',
                        fallbackIcon: Icons.support_agent_rounded,
                        accent: const Color(0xFF2E7D32),
                        onTap: () => context.go('/asha-connect'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
