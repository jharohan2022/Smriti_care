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
import '../../features/asha/onboarding/onboard_step1_screen.dart';
import '../../features/asha/onboarding/onboard_step2_screen.dart';
import '../../features/asha/onboarding/onboard_step3_screen.dart';
import '../../features/asha/onboarding/onboard_success_screen.dart';
import '../../features/asha/onboarding/patient_onboard_welcome_screen.dart';
import '../../features/asha/patients/asha_patient_repository.dart';
import '../services/asha_auth_service.dart';

final ashaRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(ashaAuthProvider);

  return GoRouter(
    initialLocation: authState.isLoggedIn ? '/asha/dashboard' : '/asha/login',
    routes: [
      // 1. ASHA Login & Registration
      GoRoute(
        path: '/asha/login',
        builder: (context, state) => const AshaLoginScreen(),
      ),

      // 13. ASHA Dashboard (Mere Buzurg)
      GoRoute(
        path: '/asha/dashboard',
        builder: (context, state) => const AshaDashboardScreen(),
      ),

      // 2. Patient Onboarding Launch
      GoRoute(
        path: '/asha/onboard',
        builder: (context, state) => const PatientOnboardWelcomeScreen(),
      ),

      // 3. Basic Details (Step 1 of 3: Buzurg ki Jankari)
      GoRoute(
        path: '/asha/onboard/step1',
        builder: (context, state) => const OnboardStep1Screen(),
      ),

      // 4. Village & Language (Step 2 of 3: Gaon ka Chayan)
      GoRoute(
        path: '/asha/onboard/step2',
        builder: (context, state) => OnboardStep2Screen(
          prevData: state.extra as Map<String, dynamic>?,
        ),
      ),

      // 5. Confirm Language (Step 3 of 3: Bhasha ki Pushti)
      GoRoute(
        path: '/asha/onboard/step3',
        builder: (context, state) => OnboardStep3Screen(
          prevData: state.extra as Map<String, dynamic>?,
        ),
      ),

      // 6. Patient Profile Created
      GoRoute(
        path: '/asha/onboard/success',
        builder: (context, state) => OnboardSuccessScreen(
          patient: state.extra as AshaPatientRecord?,
        ),
      ),

      // 7. Elder Uses App
      GoRoute(
        path: '/asha/assessment/intro',
        builder: (context, state) => const AshaElderIntroScreen(),
      ),

      // 8. Cognitive Memory Game
      GoRoute(
        path: '/asha/assessment/game',
        builder: (context, state) => const AshaMemoryGameScreen(),
      ),

      // 9. Gameplay Data Collect
      GoRoute(
        path: '/asha/assessment/summary',
        builder: (context, state) => const AshaGameplayDataScreen(),
      ),

      // 10. Personal Baseline
      GoRoute(
        path: '/asha/assessment/baseline',
        builder: (context, state) => const AshaBaselineScreen(),
      ),

      // 11. ML Trend Analysis
      GoRoute(
        path: '/asha/assessment/trend',
        builder: (context, state) => const AshaTrendAnalysisScreen(),
      ),

      // 12. Results (Analysis Result)
      GoRoute(
        path: '/asha/assessment/results',
        builder: (context, state) => const AshaResultsScreen(),
      ),

      // 14. Follow-up / Referral (ASHA Action)
      GoRoute(
        path: '/asha/action/:id',
        builder: (context, state) => AshaFollowupScreen(
          patientId: state.pathParameters['id']!,
          patient: state.extra as AshaPatientRecord?,
        ),
      ),

      // Backward-compatibility alias for /patients
      GoRoute(
        path: '/patients',
        builder: (context, state) => const AshaDashboardScreen(),
      ),
    ],
  );
});
