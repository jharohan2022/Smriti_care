import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/tts_service.dart';

/// Persistent accessible bottom navigation bar matching the 5-tab Smarana design:
/// Home, Khel (खेल), Suno (सुनो), Saath (साथ), Aur (और)
class PatientBottomNavScaffold extends ConsumerWidget {
  const PatientBottomNavScaffold({super.key, required this.child});
  final Widget child;

  static const List<({String route, IconData icon, String labelHi, String labelEn})> _tabs = [
    (route: '/home', icon: Icons.home_rounded, labelHi: 'होम', labelEn: 'Home'),
    (route: '/khel', icon: Icons.extension_rounded, labelHi: 'खेल', labelEn: 'Khel'),
    (route: '/suno', icon: Icons.volume_up_rounded, labelHi: 'सुनो', labelEn: 'Suno'),
    (route: '/saath', icon: Icons.people_alt_rounded, labelHi: 'साथ', labelEn: 'Saath'),
    (route: '/aur', icon: Icons.menu_rounded, labelHi: 'और', labelEn: 'Aur'),
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/khel') || location.startsWith('/game') || location.startsWith('/games')) return 1;
    if (location.startsWith('/suno')) return 2;
    if (location.startsWith('/saath') || location.startsWith('/asha-connect')) return 3;
    if (location.startsWith('/aur') || location.startsWith('/profile') || location.startsWith('/routine')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _calculateSelectedIndex(context);
    const brandPurple = Color(0xFF6B4EE6);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
          border: const Border(
            top: BorderSide(color: Color(0xFFEDE9FE), width: 1.5),
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
                              '${tab.labelHi}',
                              langCode: 'hi',
                            );
                        context.go(tab.route);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEDE9FE) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tab.icon,
                            size: isSelected ? 28 : 24,
                            color: isSelected ? brandPurple : const Color(0xFF64748B),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tab.labelEn,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isSelected ? 12 : 11,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? brandPurple : const Color(0xFF64748B),
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
