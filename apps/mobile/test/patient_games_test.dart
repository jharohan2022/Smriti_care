import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smriticare_mobile/core/services/tts_service.dart';
import 'package:smriticare_mobile/features/auth/auth_screen.dart';
import 'package:smriticare_mobile/features/patient/games/complete_pattern_game_screen.dart';
import 'package:smriticare_mobile/features/patient/games/daily_sequencing_game_screen.dart';
import 'package:smriticare_mobile/features/patient/games/day_season_game_screen.dart';
import 'package:smriticare_mobile/features/patient/games/face_match_game_screen.dart';
import 'package:smriticare_mobile/features/patient/games/find_target_game_screen.dart';
import 'package:smriticare_mobile/features/patient/games/games_hub_screen.dart';
import 'package:smriticare_mobile/features/patient/games/pattern_sequence_game_screen.dart';
import 'package:smriticare_mobile/features/patient/games/picture_word_match_game_screen.dart';
import 'package:smriticare_mobile/features/patient/games/remember_objects_game_screen.dart';
import 'package:smriticare_mobile/features/patient/games/shape_position_game_screen.dart';
import 'package:smriticare_mobile/features/patient/games/sound_recall_game_screen.dart';
import 'package:smriticare_mobile/features/patient/games/widgets/game_completion_dialog.dart';
import 'package:smriticare_mobile/features/patient/profile/patient_profile_screen.dart';
import 'package:smriticare_mobile/features/patient/welcome/patient_welcome_screen.dart';

class _NoOpTtsService implements TtsService {
  @override
  Future<void> speak(String text, {String langCode = 'hi'}) async {}

  @override
  Future<void> stop() async {}
}

void main() {
  group('Patient Cognitive Games & Profile Test Suite', () {
    testWidgets('PatientWelcomeScreen renders Smarana branding, quote, hero and CTA button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWithValue(_NoOpTtsService()),
          ],
          child: const MaterialApp(
            home: PatientWelcomeScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Smarana'), findsOneWidget);
      expect(find.textContaining('Har Yaad, Hamare Saath'), findsOneWidget);
      expect(find.textContaining('Zindagi ke har lamhe ko saath mein'), findsOneWidget);
      expect(find.textContaining('Chaliye Shuru Karein'), findsOneWidget);
      expect(find.textContaining('Koi login nahi'), findsOneWidget);
      expect(find.textContaining('Offline Bhi Kaam Kare'), findsOneWidget);
    });
    testWidgets('AuthScreen supports patient registration and sign in toggle', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWithValue(_NoOpTtsService()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AuthScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('👤 Patient'), findsOneWidget);
      expect(find.text('मरीज लॉगिन (Sign In)'), findsOneWidget);
      expect(find.text('START CARE SESSION'), findsOneWidget);

      await tester.tap(find.text('Register New'));
      await tester.pump();

      expect(find.text('मरीज पंजीकरण (Registration)'), findsOneWidget);
      expect(find.textContaining('Age (उम्र)'), findsOneWidget);
      expect(find.textContaining('Caregiver / Family Contact'), findsOneWidget);
      expect(find.text('REGISTER & START CARE'), findsOneWidget);
    });

    testWidgets('PatientProfileScreen renders avatar, caregiver and actions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWithValue(_NoOpTtsService()),
          ],
          child: const MaterialApp(
            home: PatientProfileScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('My Profile (मेरी प्रोफ़ाइल)'), findsOneWidget);
      expect(find.textContaining('Caregiver'), findsWidgets);
      expect(find.textContaining('Call Caregiver Now'), findsOneWidget);
      expect(find.textContaining('Switch Patient / Sign Out'), findsOneWidget);
    });

    testWidgets('GamesHubScreen displays domain games catalog', (tester) async {
      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWithValue(_NoOpTtsService()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: GamesHubScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Memory Games (दिमागी खेल)'), findsOneWidget);
      expect(find.textContaining('Remember Objects'), findsOneWidget);
      expect(find.textContaining('Find the Target'), findsOneWidget);
      expect(find.textContaining('Complete Pattern'), findsOneWidget);
      expect(find.textContaining('Picture → Word'), findsOneWidget);
      expect(find.textContaining('Day & Season'), findsOneWidget);
      expect(find.textContaining('Shape & Position'), findsOneWidget);
      expect(find.textContaining('Arrange Activities'), findsOneWidget);
    });

    testWidgets('RememberObjectsGameScreen memorization phase renders correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWithValue(_NoOpTtsService()),
          ],
          child: const MaterialApp(
            home: RememberObjectsGameScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Remember Objects'), findsOneWidget);
      expect(find.textContaining('Memorize these 3 items'), findsOneWidget);
    });

    testWidgets('FindTargetGameScreen renders target and selection grid', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWithValue(_NoOpTtsService()),
          ],
          child: const MaterialApp(
            home: FindTargetGameScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Find the Target'), findsOneWidget);
      expect(find.textContaining('Find this Target'), findsOneWidget);
    });

    testWidgets('CompletePatternGameScreen renders pattern sequence & choices', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWithValue(_NoOpTtsService()),
          ],
          child: const MaterialApp(
            home: CompletePatternGameScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Complete the Pattern'), findsOneWidget);
      expect(find.textContaining('What comes in the question mark'), findsOneWidget);
    });

    testWidgets('PictureWordMatchGameScreen renders prompt and word options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWithValue(_NoOpTtsService()),
          ],
          child: const MaterialApp(
            home: PictureWordMatchGameScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Picture → Word Match'), findsOneWidget);
      expect(find.textContaining('What is this picture called?'), findsOneWidget);
    });

    testWidgets('DaySeasonGameScreen renders orientation question', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWithValue(_NoOpTtsService()),
          ],
          child: const MaterialApp(
            home: DaySeasonGameScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Day & Season Game'), findsOneWidget);
      expect(find.textContaining('1 /'), findsOneWidget);
    });

    testWidgets('ShapePositionGameScreen renders target shape and match options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWithValue(_NoOpTtsService()),
          ],
          child: const MaterialApp(
            home: ShapePositionGameScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Shape & Position Match'), findsOneWidget);
      expect(find.textContaining('Match this Shape'), findsOneWidget);
    });

    testWidgets('DailySequencingGameScreen renders reorderable activity steps', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWithValue(_NoOpTtsService()),
          ],
          child: const MaterialApp(
            home: DailySequencingGameScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Arrange Activities'), findsOneWidget);
      expect(find.textContaining('Tap in order: Step'), findsOneWidget);
    });

    testWidgets('GameCompletionDialog renders 3 stars and action buttons', (tester) async {
      bool playAgainCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameCompletionDialog(
              title: 'शाबाश! (Bravo!)',
              subtitle: 'You completed the memory test!',
              stars: 3,
              onPlayAgain: () => playAgainCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('शाबाश! (Bravo!)'), findsOneWidget);
      expect(find.text('You completed the memory test!'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      expect(find.textContaining('Play Again'), findsOneWidget);
      expect(find.textContaining('Back to Home'), findsOneWidget);

      await tester.tap(find.textContaining('Play Again'));
      expect(playAgainCalled, isTrue);
    });
  });
}
