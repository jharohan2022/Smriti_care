import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/tts_service.dart';

/// Persistent accessible bottom navigation bar for patient mode.
/// Huge tap targets, high contrast, bilingual titles, and audio feedback.
class PatientBottomNavScaffold extends ConsumerWidget {
  const PatientBottomNavScaffold({super.key, required this.child});
  final Widget child;

  static const List<({String route, IconData icon, String labelHi, String labelEn})> _tabs = [
    (route: '/home', icon: Icons.home_rounded, labelHi: 'होम', labelEn: 'Home'),
    (route: '/games', icon: Icons.extension_rounded, labelHi: 'खेल', labelEn: 'Games'),
    (route: '/routine', icon: Icons.wb_sunny_rounded, labelHi: 'दिनचर्या', labelEn: 'My Day'),
    (route: '/profile', icon: Icons.person_rounded, labelHi: 'प्रोफ़ाइल', labelEn: 'Profile'),
    (route: '/asha-connect', icon: Icons.support_agent_rounded, labelHi: 'मदद', labelEn: 'Helper'),
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/games') || location.startsWith('/game')) return 1;
    if (location.startsWith('/routine')) return 2;
    if (location.startsWith('/profile')) return 3;
    if (location.startsWith('/asha-connect')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          border: const Border(
            top: BorderSide(color: Color(0xFFFFD54F), width: 2),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isSelected = selectedIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      if (selectedIndex != index) {
                        ref.read(ttsServiceProvider).speak(
                              'Opening ${tab.labelEn}. ${tab.labelHi}',
                              langCode: 'hi',
                            );
                        context.go(tab.route);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00695C).withOpacity(0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tab.icon,
                            size: isSelected ? 30 : 26,
                            color: isSelected ? const Color(0xFF00695C) : Colors.grey.shade600,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tab.labelHi,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isSelected ? 13 : 11,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? const Color(0xFF00695C) : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
