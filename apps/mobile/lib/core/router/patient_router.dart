import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/asha/assessment/asha_baseline_screen.dart';
import '../../features/asha/assessment/asha_elder_intro_screen.dart';
import '../../features/asha/assessment/asha_gameplay_data_screen.dart';
import '../../features/asha/assessment/asha_memory_game_screen.dart';
import '../../features/asha/assessment/asha_results_screen.dart';
import '../../features/asha/assessment/asha_trend_analysis_screen.dart';
import '../../features/asha/auth/asha_login_screen.dart';
import '../../features/asha/dashboard/asha_dashboard_screen.dart';
import '../../features/asha/followup/asha_followup_screen.dart';
import '../../features/asha/onboarding/onboard_family_members_screen.dart';
import '../../features/asha/onboarding/onboard_step1_screen.dart';
import '../../features/asha/onboarding/onboard_step2_screen.dart';
import '../../features/asha/onboarding/onboard_step3_screen.dart';
import '../../features/asha/onboarding/onboard_success_screen.dart';
import '../../features/asha/onboarding/patient_onboard_welcome_screen.dart';
import '../../features/asha/patients/asha_patient_repository.dart';
import '../../features/patient/activities/daily_activities_screen.dart';
import '../../features/patient/asha/connect_asha_screen.dart';
import '../../features/patient/dashboard/easy_dashboard_screen.dart';
import '../../features/patient/end_screen/end_celebration_screen.dart';
import '../../features/patient/games/complete_pattern_game_screen.dart';
import '../../features/patient/games/daily_sequencing_game_screen.dart';
import '../../features/patient/games/day_season_game_screen.dart';
import '../../features/patient/games/face_match_game_screen.dart';
import '../../features/patient/games/find_target_game_screen.dart';
import '../../features/patient/games/games_hub_screen.dart';
import '../../features/patient/games/memory_cards_game_screen.dart';
import '../../features/patient/games/pattern_sequence_game_screen.dart';
import '../../features/patient/games/picture_word_match_game_screen.dart';
import '../../features/patient/games/remember_objects_game_screen.dart';
import '../../features/patient/games/shape_position_game_screen.dart';
import '../../features/patient/games/sound_recall_game_screen.dart';
import '../../features/patient/games/word_recall_game_screen.dart';
import '../../features/patient/inspiration/daily_inspiration_screen.dart';
import '../../features/patient/mood/mood_check_screen.dart';
import '../../features/patient/navigation/patient_bottom_nav_scaffold.dart';
import '../../features/patient/profile/patient_profile_screen.dart';
import '../../features/patient/welcome/device_setup_screen.dart';
import '../../features/patient/welcome/friendly_greeting_screen.dart';
import '../../features/patient/welcome/patient_welcome_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../services/patient_device_service.dart';

final patientRouterProvider = Provider<GoRouter>((ref) {
  final patientState = ref.watch(patientDeviceProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isBound = patientState.isDeviceBound;
      final location = state.uri.toString();
      final isSetupLocation = location == '/device-setup';
      final isSplash = location == '/splash';
      final isAshaRoute = location.startsWith('/asha');

      // Allow Splash and ASHA routes freely
      if (isSplash || isAshaRoute) return null;

      // First time installation: show device activation setup
      if (!isBound && !isSetupLocation) {
        return '/device-setup';
      }

      // After first activation: login option is gone permanently
      if (isBound && isSetupLocation) {
        return '/greeting';
      }

      return null;
    },
    routes: [
      // Splash / Loading Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // One-time Setup Screen (Only shown upon first install until activated)
      GoRoute(
        path: '/device-setup',
        builder: (context, state) => const DeviceSetupScreen(),
      ),

      // 1. Welcome Screen (Redirected to Greeting Screen)
      GoRoute(
        path: '/welcome',
        redirect: (context, state) => '/greeting',
        builder: (context, state) => const PatientWelcomeScreen(),
      ),

      // 2. Friendly Greeting (Voice First)
      GoRoute(
        path: '/greeting',
        builder: (context, state) => const FriendlyGreetingScreen(),
      ),

      // Shell Route for Persistent 5-Tab Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return PatientBottomNavScaffold(child: child);
        },
        routes: [
          // 3. Home Dashboard (Daily Companionship)
          GoRoute(
            path: '/home',
            builder: (context, state) => const EasyDashboardScreen(),
          ),

          // Games Hub (Khel)
          GoRoute(
            path: '/khel',
            builder: (context, state) => const GamesHubScreen(),
          ),

          // 5. Daily Inspiration (Suno)
          GoRoute(
            path: '/suno',
            builder: (context, state) => const DailyInspirationScreen(),
          ),

          // 6. Connect with ASHA (Saath)
          GoRoute(
            path: '/saath',
            builder: (context, state) => const ConnectAshaScreen(),
          ),

          // Aur / Profile / Settings (1-Device 1-Patient, No Logout, ASHA Admin Mode)
          GoRoute(
            path: '/aur',
            builder: (context, state) => const PatientProfileScreen(),
          ),
        ],
      ),

      // Flow & Game Routes
      GoRoute(
        path: '/activities',
        builder: (context, state) => const DailyActivitiesScreen(),
      ),
      GoRoute(
        path: '/mood-check',
        builder: (context, state) => const MoodCheckScreen(),
      ),
      GoRoute(
        path: '/end-screen',
        builder: (context, state) => const EndCelebrationScreen(),
      ),

      // Games
      GoRoute(
        path: '/game/memory-cards',
        builder: (context, state) => const MemoryCardsGameScreen(),
      ),
      GoRoute(
        path: '/game/word-recall',
        builder: (context, state) => const WordRecallGameScreen(),
      ),
      GoRoute(
        path: '/game/family-match',
        builder: (context, state) => const FaceMatchGameScreen(),
      ),
      GoRoute(
        path: '/game/face-match',
        builder: (context, state) => const FaceMatchGameScreen(),
      ),
      GoRoute(
        path: '/game/remember-objects',
        builder: (context, state) => const RememberObjectsGameScreen(),
      ),
      GoRoute(
        path: '/game/find-target',
        builder: (context, state) => const FindTargetGameScreen(),
      ),
      GoRoute(
        path: '/game/complete-pattern',
        builder: (context, state) => const CompletePatternGameScreen(),
      ),
      GoRoute(
        path: '/game/picture-word-match',
        builder: (context, state) => const PictureWordMatchGameScreen(),
      ),
      GoRoute(
        path: '/game/day-season',
        builder: (context, state) => const DaySeasonGameScreen(),
      ),
      GoRoute(
        path: '/game/shape-position',
        builder: (context, state) => const ShapePositionGameScreen(),
      ),
      GoRoute(
        path: '/game/daily-sequencing',
        builder: (context, state) => const DailySequencingGameScreen(),
      ),
      GoRoute(
        path: '/game/sound-recall',
        builder: (context, state) => const SoundRecallGameScreen(),
      ),
      GoRoute(
        path: '/game/pattern-sequence',
        builder: (context, state) => const PatternSequenceGameScreen(),
      ),

      // ASHA Sathi 14-Screen Workflow Routes
      GoRoute(
        path: '/asha/login',
        builder: (context, state) => const AshaLoginScreen(),
      ),
      GoRoute(
        path: '/asha/dashboard',
        builder: (context, state) => const AshaDashboardScreen(),
      ),
      GoRoute(
        path: '/asha/onboard',
        builder: (context, state) => const PatientOnboardWelcomeScreen(),
      ),
      GoRoute(
        path: '/asha/onboard/step1',
        builder: (context, state) => const OnboardStep1Screen(),
      ),
      GoRoute(
        path: '/asha/onboard/step2',
        builder: (context, state) => OnboardStep2Screen(
          prevData: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(
        path: '/asha/onboard/step3-family',
        builder: (context, state) => OnboardFamilyMembersScreen(
          prevData: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(
        path: '/asha/onboard/step3',
        builder: (context, state) => OnboardStep3Screen(
          prevData: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(
        path: '/asha/onboard/success',
        builder: (context, state) => OnboardSuccessScreen(
          patient: state.extra as AshaPatientRecord?,
        ),
      ),
      GoRoute(
        path: '/asha/assessment/intro',
        builder: (context, state) => const AshaElderIntroScreen(),
      ),
      GoRoute(
        path: '/asha/assessment/game',
        builder: (context, state) => const AshaMemoryGameScreen(),
      ),
      GoRoute(
        path: '/asha/assessment/summary',
        builder: (context, state) => const AshaGameplayDataScreen(),
      ),
      GoRoute(
        path: '/asha/assessment/baseline',
        builder: (context, state) => const AshaBaselineScreen(),
      ),
      GoRoute(
        path: '/asha/assessment/trend',
        builder: (context, state) => const AshaTrendAnalysisScreen(),
      ),
      GoRoute(
        path: '/asha/assessment/results',
        builder: (context, state) => const AshaResultsScreen(),
      ),
      GoRoute(
        path: '/asha/action/:id',
        builder: (context, state) => AshaFollowupScreen(
          patientId: state.pathParameters['id']!,
          patient: state.extra as AshaPatientRecord?,
        ),
      ),
    ],
  );
});
