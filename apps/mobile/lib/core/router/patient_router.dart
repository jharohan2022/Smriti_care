import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/patient/dashboard/easy_dashboard_screen.dart';
import '../../features/patient/games/complete_pattern_game_screen.dart';
import '../../features/patient/games/daily_sequencing_game_screen.dart';
import '../../features/patient/games/day_season_game_screen.dart';
import '../../features/patient/games/face_match_game_screen.dart';
import '../../features/patient/games/find_target_game_screen.dart';
import '../../features/patient/games/game_telemetry_screen.dart';
import '../../features/patient/games/games_hub_screen.dart';
import '../../features/patient/games/pattern_sequence_game_screen.dart';
import '../../features/patient/games/picture_word_match_game_screen.dart';
import '../../features/patient/games/remember_objects_game_screen.dart';
import '../../features/patient/games/shape_position_game_screen.dart';
import '../../features/patient/games/sound_recall_game_screen.dart';
import '../../features/patient/navigation/patient_bottom_nav_scaffold.dart';
import '../../features/patient/profile/patient_profile_screen.dart';
import '../../features/patient/welcome/patient_welcome_screen.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

/// Patient navigation. Flat and shallow by design with persistent bottom navigation bar
/// for 1-tap movement across Home, Games, Routine, Profile, and Helper.
final patientRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const _PatientErrorScreen(),
    routes: [
      GoRoute(path: '/', builder: (_, __) => const PatientWelcomeScreen()),
      
      // Main Persistent Shell with Bottom Navigation Bar
      ShellRoute(
        builder: (context, state, child) => PatientBottomNavScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const EasyDashboardScreen()),
          GoRoute(path: '/games', builder: (_, __) => const GamesHubScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const PatientProfileScreen()),
          GoRoute(
            path: '/routine',
            builder: (_, __) => const _PlaceholderScreen(
              title: 'My Day (दिनचर्या)',
              icon: Icons.wb_sunny_rounded,
              narration: 'Here is your daily routine and schedule for today.',
            ),
          ),
          GoRoute(
            path: '/asha-connect',
            builder: (_, __) => const _PlaceholderScreen(
              title: 'Call Helper (मदद)',
              icon: Icons.support_agent_rounded,
              narration: 'Connecting you to your health helper and ASHA worker.',
            ),
          ),
        ],
      ),

      // Individual Cognitive & Memory Game Screens
      GoRoute(path: '/game/remember-objects', builder: (_, __) => const RememberObjectsGameScreen()),
      GoRoute(path: '/game/find-target', builder: (_, __) => const FindTargetGameScreen()),
      GoRoute(path: '/game/complete-pattern', builder: (_, __) => const CompletePatternGameScreen()),
      GoRoute(path: '/game/picture-word-match', builder: (_, __) => const PictureWordMatchGameScreen()),
      GoRoute(path: '/game/day-season', builder: (_, __) => const DaySeasonGameScreen()),
      GoRoute(path: '/game/shape-position', builder: (_, __) => const ShapePositionGameScreen()),
      GoRoute(path: '/game/daily-sequencing', builder: (_, __) => const DailySequencingGameScreen()),
      GoRoute(path: '/game/face-match', builder: (_, __) => const FaceMatchGameScreen()),
      GoRoute(path: '/game/sound-recall', builder: (_, __) => const SoundRecallGameScreen()),
      GoRoute(path: '/game/pattern-sequence', builder: (_, __) => const PatternSequenceGameScreen()),
      GoRoute(
        path: '/game/reaction-tap',
        builder: (_, __) => const GameTelemetryScreen(gameId: 'reaction-tap'),
      ),
      GoRoute(
        path: '/game/:gameId',
        builder: (_, state) =>
            GameTelemetryScreen(gameId: state.pathParameters['gameId'] ?? 'memory-match'),
      ),
    ],
  );
});

/// Zero-literacy error boundary: big calm icon, auto-narration, one giant way back.
class _PatientErrorScreen extends ConsumerWidget {
  const _PatientErrorScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak('Something went wrong. Let us go back home.');
    });
    return Scaffold(
      backgroundColor: A11y.patientSurface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_rounded, size: 120, color: A11y.patientPrimary),
              const SizedBox(height: 24),
              const Text('Let us go back', style: TextStyle(fontSize: A11y.patientHeadline)),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.home_rounded, size: 48),
                label: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends ConsumerWidget {
  const _PlaceholderScreen({required this.title, required this.icon, required this.narration});
  final String title;
  final IconData icon;
  final String narration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(narration);
    });
    return Scaffold(
      backgroundColor: A11y.patientSurface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 140, color: A11y.patientPrimary),
              const SizedBox(height: 24),
              Text(title, style: const TextStyle(fontSize: A11y.patientHeadline)),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.home_rounded, size: 48),
                label: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
