import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smriticare_mobile/core/services/tts_service.dart';
import 'package:smriticare_mobile/features/asha/assessment/asha_baseline_screen.dart';
import 'package:smriticare_mobile/features/asha/assessment/asha_elder_intro_screen.dart';
import 'package:smriticare_mobile/features/asha/assessment/asha_gameplay_data_screen.dart';
import 'package:smriticare_mobile/features/asha/assessment/asha_memory_game_screen.dart';
import 'package:smriticare_mobile/features/asha/assessment/asha_results_screen.dart';
import 'package:smriticare_mobile/features/asha/assessment/asha_trend_analysis_screen.dart';
import 'package:smriticare_mobile/features/asha/auth/asha_login_screen.dart';
import 'package:smriticare_mobile/features/asha/dashboard/asha_dashboard_screen.dart';
import 'package:smriticare_mobile/features/asha/followup/asha_followup_screen.dart';
import 'package:smriticare_mobile/features/asha/onboarding/onboard_step1_screen.dart';
import 'package:smriticare_mobile/features/asha/onboarding/onboard_step2_screen.dart';
import 'package:smriticare_mobile/features/asha/onboarding/onboard_step3_screen.dart';
import 'package:smriticare_mobile/features/asha/onboarding/onboard_success_screen.dart';
import 'package:smriticare_mobile/features/asha/onboarding/patient_onboard_welcome_screen.dart';

class FakeTtsService implements TtsService {
  final List<String> spoken = [];

  @override
  Future<void> speak(String text, {String langCode = 'hi'}) async {
    spoken.add(text);
  }

  @override
  Future<void> stop() async {}
}

Widget createAshaTestWidget(Widget child) {
  return ProviderScope(
    overrides: [
      ttsServiceProvider.overrideWithValue(FakeTtsService()),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Smarana ASHA Sathi 14-Screen Workflow Suite', () {
    testWidgets('Screen 1: AshaLoginScreen renders Login and Register tabs', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAshaTestWidget(const AshaLoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Smarana'), findsOneWidget);
      expect(find.text('ASHA Sathi'), findsOneWidget);
      expect(find.text('Login (लॉग इन)'), findsOneWidget);
      expect(find.text('Register (पंजीकरण)'), findsOneWidget);
    });

    testWidgets('Screen 2: PatientOnboardWelcomeScreen renders launch options', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAshaTestWidget(const PatientOnboardWelcomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Naya Buzurg Jodein'), findsOneWidget);
      expect(find.text('+ Naya Patient Jodein'), findsOneWidget);
      expect(find.text('QR se Jodein (optional)'), findsOneWidget);
    });

    testWidgets('Screen 3: OnboardStep1Screen renders basic info form', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAshaTestWidget(const OnboardStep1Screen()));
      await tester.pumpAndSettle();

      expect(find.text('Buzurg ki Jankari'), findsOneWidget);
      expect(find.text('Aage Badhien'), findsOneWidget);
    });

    testWidgets('Screen 4: OnboardStep2Screen renders village selection', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAshaTestWidget(const OnboardStep2Screen()));
      await tester.pumpAndSettle();

      expect(find.text('Gaon ka Chayan'), findsOneWidget);
      expect(find.textContaining('Sujhav: Hindi'), findsOneWidget);
    });

    testWidgets('Screen 5: OnboardStep3Screen renders language confirmation', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAshaTestWidget(const OnboardStep3Screen()));
      await tester.pumpAndSettle();

      expect(find.text('Bhasha ki Pushti'), findsOneWidget);
      expect(find.text('Haan, Sahi Hai'), findsOneWidget);
    });

    testWidgets('Screen 6: OnboardSuccessScreen renders created summary', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAshaTestWidget(const OnboardSuccessScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Safalta se Ban Gaya!'), findsOneWidget);
      expect(find.text('Patient Profile Dekhein'), findsOneWidget);
      expect(find.text('Home Par Jayein'), findsOneWidget);
    });

    testWidgets('Screen 7: AshaElderIntroScreen renders greeting', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAshaTestWidget(const AshaElderIntroScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Buzurg ke Liye App'), findsOneWidget);
      expect(find.text('Game Shuru Karein'), findsOneWidget);
    });

    testWidgets('Screen 8: AshaMemoryGameScreen renders memory grid', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAshaTestWidget(const AshaMemoryGameScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Chalo Yaad Karein!'), findsOneWidget);
      expect(find.text('Agla Round'), findsOneWidget);
    });

    testWidgets('Screen 9: AshaGameplayDataScreen renders telemetry metrics', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAshaTestWidget(const AshaGameplayDataScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Khel Pura Hua!'), findsOneWidget);
      expect(find.text('8 / 10'), findsOneWidget);
      expect(find.text('Shabashi!'), findsOneWidget);
    });

    testWidgets('Screen 10: AshaBaselineScreen renders baseline chart', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAshaTestWidget(const AshaBaselineScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Vyaktigat Aadhar Taiyar'), findsOneWidget);
      expect(find.text('Performance Analysis'), findsOneWidget);
    });

    testWidgets('Screen 11: AshaTrendAnalysisScreen renders trend curve', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAshaTestWidget(const AshaTrendAnalysisScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Performance Analysis'), findsOneWidget);
      expect(find.text('MONITOR'), findsOneWidget);
    });

    testWidgets('Screen 12: AshaResultsScreen renders clinical triage', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAshaTestWidget(const AshaResultsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Analysis Result'), findsOneWidget);
      expect(find.text('STABLE'), findsOneWidget);
      expect(find.text('MONITOR'), findsOneWidget);
      expect(find.text('NEEDS ATTENTION'), findsOneWidget);
    });

    testWidgets('Screen 13: AshaDashboardScreen renders Home, Patients, Visits, Alerts, More tabs', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAshaTestWidget(const AshaDashboardScreen()));
      await tester.pumpAndSettle();

      // Home View checks
      expect(find.text('ASHA Sathi Home'), findsOneWidget);
      expect(find.textContaining('Namaste Sunita Didi!'), findsOneWidget);
      expect(find.text('Kul Buzurg'), findsOneWidget);
      expect(find.text('Aaj ki Visits'), findsOneWidget);

      // Tap on Patients Tab (Index 1)
      await tester.tap(find.text('Patients'));
      await tester.pumpAndSettle();
      expect(find.text('Mere Buzurg'), findsOneWidget);
      expect(find.textContaining('Ramesh Das'), findsOneWidget);
      expect(find.textContaining('Lakshmi Tai'), findsOneWidget);

      // Tap on Visits Tab (Index 2)
      await tester.tap(find.text('Visits'));
      await tester.pumpAndSettle();
      expect(find.text('Ghar Bhraman (Visits)'), findsOneWidget);
      expect(find.text('Aaj (3)'), findsOneWidget);

      // Tap on Alerts Tab (Index 3)
      await tester.tap(find.text('Alerts'));
      await tester.pumpAndSettle();
      expect(find.text('Zaroori Alerts'), findsOneWidget);
      expect(find.text('Critical (2)'), findsOneWidget);

      // Tap on More Tab (Index 4)
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('Settings & Tools'), findsOneWidget);
      expect(find.text('Sunita Sharma'), findsOneWidget);
    });

    testWidgets('Screen 14: AshaFollowupScreen renders 4 ASHA actions', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createAshaTestWidget(const AshaFollowupScreen(patientId: 'PAT-101')));
      await tester.pumpAndSettle();

      expect(find.text('ASHA Action'), findsOneWidget);
      expect(find.text('Home Visit Karein'), findsOneWidget);
      expect(find.text('Follow-up Schedule'), findsOneWidget);
      expect(find.text('Medical Referral'), findsOneWidget);
      expect(find.text('Notes Add Karein'), findsOneWidget);
    });
  });
}
