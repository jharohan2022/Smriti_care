import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/giant_button.dart';
import '../widgets/tts_narrator.dart';

/// First screen. One giant "Start" and a "Listen" prompt — nothing else.
/// No login, no text entry (zero-auth, device-bound identity).
class PatientWelcomeScreen extends ConsumerWidget {
  const PatientWelcomeScreen({super.key});

  static const _greeting = 'Welcome. Tap the big green button to start.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TtsNarrator(
      text: _greeting,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text('Namaste 🙏', style: TextStyle(fontSize: 56, fontWeight: FontWeight.w800)),
                const Spacer(),
                GiantButton(
                  label: 'Start',
                  icon: Icons.play_circle_fill_rounded,
                  onPressed: () => context.go('/home'),
                ),
                const Spacer(),
                const ListenButton(text: _greeting),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
