import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smriticare_mobile/core/services/tts_service.dart';
import 'package:smriticare_mobile/features/patient/activities/daily_activities_screen.dart';
import 'package:smriticare_mobile/features/patient/asha/connect_asha_screen.dart';
import 'package:smriticare_mobile/features/patient/dashboard/easy_dashboard_screen.dart';
import 'package:smriticare_mobile/features/patient/end_screen/end_celebration_screen.dart';
import 'package:smriticare_mobile/features/patient/games/face_match_game_screen.dart';
import 'package:smriticare_mobile/features/patient/games/memory_cards_game_screen.dart';
import 'package:smriticare_mobile/features/patient/games/word_recall_game_screen.dart';
import 'package:smriticare_mobile/features/patient/inspiration/daily_inspiration_screen.dart';
import 'package:smriticare_mobile/features/patient/mood/mood_check_screen.dart';
import 'package:smriticare_mobile/features/patient/profile/patient_profile_screen.dart';
import 'package:smriticare_mobile/features/patient/welcome/device_setup_screen.dart';
import 'package:smriticare_mobile/features/patient/welcome/friendly_greeting_screen.dart';
import 'package:smriticare_mobile/features/patient/welcome/patient_welcome_screen.dart';

class FakeTtsService implements TtsService {
  final List<String> spoken = [];

  @override
  Future<void> speak(String text, {String langCode = 'hi'}) async {
    spoken.add(text);
  }

  @override
  Future<void> stop() async {}
}

Widget createTestWidget(Widget child) {
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

  group('Smarana 10-Screen Suite & 1-Device 1-Patient Architecture', () {
    testWidgets('Initial Install: DeviceSetupScreen renders one-time patient activation setup', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const DeviceSetupScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Smarana Setup'), findsOneWidget);
      expect(find.textContaining('One-Time Device'), findsOneWidget);
      expect(find.text('Activate & Lock Device'), findsOneWidget);
    });
    testWidgets('Screen 1: PatientWelcomeScreen renders Smarana brand & CTA', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const PatientWelcomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Smarana'), findsOneWidget);
      expect(find.text('Har Yaad, Hamare Saath'), findsOneWidget);
      expect(find.text('Chaliye Shuru Karein'), findsOneWidget);
      expect(find.textContaining('Koi login nahi'), findsOneWidget);
    });

    testWidgets('Screen 2: FriendlyGreetingScreen renders Sun graphic & Voice Mic', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const FriendlyGreetingScreen()));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Namaste!'), findsOneWidget);
      expect(find.textContaining('Main Smarana hoon'), findsOneWidget);
      expect(find.text('Bas boliye...'), findsOneWidget);
      expect(find.text('Main khud chununga'), findsOneWidget);
    });

    testWidgets('Screen 3: EasyDashboardScreen renders Daily Companionship & Action Cards', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const EasyDashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Aaj ka Smarana Saath'), findsOneWidget);
      expect(find.text('Yaadasht Khel'), findsOneWidget);
      expect(find.text('Thoda Gyaan Thodi Baatein'), findsOneWidget);
      expect(find.text('Man Ko Khush Rakhein'), findsOneWidget);
      expect(find.text('Apno se Jude Raho'), findsOneWidget);
    });

    testWidgets('Screen 4: MemoryCardsGameScreen renders grid and feedback', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const MemoryCardsGameScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Chalo Yaad Karein!'), findsOneWidget);
      expect(find.textContaining('Mango'), findsOneWidget);
      expect(find.text('Next Round'), findsOneWidget);
    });

    testWidgets('Screen 5: DailyInspirationScreen renders quote & audio player', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const DailyInspirationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Daily Inspiration'), findsOneWidget);
      expect(find.textContaining('Yaadein sirf beete kal ki nahi'), findsOneWidget);
      expect(find.text('Aaj ka Vichar'), findsOneWidget);
      expect(find.text('Suno'), findsOneWidget);
    });

    testWidgets('Screen 6: ConnectAshaScreen renders ASHA Didi call & video actions', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const ConnectAshaScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Kabhi Baat Karni Ho?'), findsOneWidget);
      expect(find.text('Baat Karein (Phone / Voice)'), findsOneWidget);
      expect(find.text('Video Baat'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
    });

    testWidgets('Screen 7: WordRecallGameScreen renders object & options', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const WordRecallGameScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Shabd Yaad Karein'), findsOneWidget);
      expect(find.text('Kamal'), findsOneWidget);
      expect(find.text('Gulab'), findsOneWidget);
      expect(find.text('Aage Badhien'), findsOneWidget);
    });

    testWidgets('Screen 8: DailyActivitiesScreen renders activity list', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const DailyActivitiesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Aaj Kya Karein?'), findsOneWidget);
      expect(find.text('Thodi Walk Karein'), findsOneWidget);
      expect(find.text('Kahani Sunein'), findsOneWidget);
    });

    testWidgets('Screen 9: MoodCheckScreen renders 5 mood emojis', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const MoodCheckScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Aaj aap kaisa mehsoos'), findsOneWidget);
      expect(find.text('Achha'), findsOneWidget);
      expect(find.text('Aage Badhien'), findsOneWidget);
    });

    testWidgets('Screen 10: EndCelebrationScreen renders celebration & Theek Hai CTA', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const EndCelebrationScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Aaj ka din'), findsOneWidget);
      expect(find.text('Theek Hai'), findsOneWidget);
    });

    testWidgets('Profile / Aur: Enforces 1-Device 1-Patient & ASHA Admin Mode', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const PatientProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('One Device • One Patient'), findsOneWidget);
      expect(find.text('Mera Parivar (मेरा परिवार)'), findsOneWidget);
      expect(find.textContaining('ASHA Worker Mode'), findsOneWidget);
      // Ensure NO public patient logout button exists
      expect(find.text('Switch Patient / Sign Out (लॉग आउट)'), findsNothing);
    });

    testWidgets('Dynamic Family Match Game: loads from family provider', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const FaceMatchGameScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Family Match'), findsOneWidget);
    });
  });
}
