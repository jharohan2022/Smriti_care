import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smriticare_mobile/core/services/tts_service.dart';
import 'package:smriticare_mobile/features/auth/auth_screen.dart';
import 'package:smriticare_mobile/features/patient/games/games_hub_screen.dart';
import 'package:smriticare_mobile/features/patient/games/face_match_game_screen.dart';
import 'package:smriticare_mobile/features/patient/games/sound_recall_game_screen.dart';
import 'package:smriticare_mobile/features/patient/games/pattern_sequence_game_screen.dart';
import 'package:smriticare_mobile/features/patient/games/widgets/game_completion_dialog.dart';

class _NoOpTtsService implements TtsService {
  @override
  Future<void> speak(String text, {String langCode = 'hi'}) async {}

  @override
  Future<void> stop() async {}
}

void main() {
  group('Patient Cognitive Games & Registration Test Suite', () {
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

      // Check Patient tab is selected by default
      expect(find.text('👤 Patient'), findsOneWidget);
      expect(find.text('मरीज लॉगिन (Sign In)'), findsOneWidget);
      expect(find.text('START CARE SESSION'), findsOneWidget);

      // Tap Register New toggle
      await tester.tap(find.text('Register New'));
      await tester.pump();

      // Verify Patient Registration form fields are rendered
      expect(find.text('मरीज पंजीकरण (Registration)'), findsOneWidget);
      expect(find.textContaining('Age (उम्र)'), findsOneWidget);
      expect(find.textContaining('Gender (लिंग)'), findsOneWidget);
      expect(find.textContaining('Caregiver / Family Contact'), findsOneWidget);
      expect(find.textContaining('Emergency Phone Number'), findsOneWidget);
      expect(find.text('REGISTER & START CARE'), findsOneWidget);
    });

    testWidgets('GamesHubScreen displays all 4 accessible games', (tester) async {
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
              body: GamesHubScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify app bar title
      expect(find.text('Memory Games (दिमागी खेल)'), findsOneWidget);

      // Verify all 4 game items exist in catalog
      expect(find.textContaining('Family Match'), findsOneWidget);
      expect(find.textContaining('Sound Memory'), findsOneWidget);
      expect(find.textContaining('Pattern Sequence'), findsOneWidget);
      expect(find.textContaining('Reflex Target'), findsOneWidget);
    });

    testWidgets('FaceMatchGameScreen loads first round target and options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWithValue(_NoOpTtsService()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FaceMatchGameScreen(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify screen title and prompts
      expect(find.text('Family Photo Match'), findsOneWidget);
      expect(find.text('Find (पहचानिए):'), findsOneWidget);
      expect(find.textContaining('1 /'), findsOneWidget);
    });

    testWidgets('SoundRecallGameScreen loads waveform and sound choices', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWithValue(_NoOpTtsService()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SoundRecallGameScreen(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify Sound title & replay button
      expect(find.text('Sound Memory'), findsOneWidget);
      expect(find.textContaining('Play Sound Again'), findsOneWidget);
      expect(find.textContaining('1 /'), findsOneWidget);
    });

    testWidgets('PatternSequenceGameScreen renders 4 big interactive symbols', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsServiceProvider.overrideWithValue(_NoOpTtsService()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PatternSequenceGameScreen(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify memory sequence symbols
      expect(find.text('Pattern Sequence'), findsOneWidget);
      expect(find.text('सूरज (Sun)'), findsOneWidget);
      expect(find.text('पानी (Water)'), findsOneWidget);
      expect(find.text('पत्ती (Leaf)'), findsOneWidget);
      expect(find.text('सितारा (Star)'), findsOneWidget);
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
