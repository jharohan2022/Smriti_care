import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_theme.dart';

/// Wraps a screen and narrates [text] once when it first appears. This is the
/// "persistent TTS" contract — every patient screen mounts one of these.
class TtsNarrator extends ConsumerStatefulWidget {
  const TtsNarrator({
    super.key,
    required this.text,
    required this.child,
    this.autoPlay = true,
  });

  final String text;
  final Widget child;
  final bool autoPlay;

  @override
  ConsumerState<TtsNarrator> createState() => _TtsNarratorState();
}

class _TtsNarratorState extends ConsumerState<TtsNarrator> {
  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(ttsServiceProvider).speak(widget.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// A big round "Listen" button that (re)plays [text]. Always available so the
/// patient can re-hear instructions on demand.
class ListenButton extends ConsumerWidget {
  const ListenButton({super.key, required this.text, this.size = 120});
  final String text;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      label: 'Listen',
      child: Material(
        color: A11y.patientPrimary,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => ref.read(ttsServiceProvider).speak(text),
          child: SizedBox(
            width: size,
            height: size,
            child: const Icon(Icons.volume_up_rounded, size: 56, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
