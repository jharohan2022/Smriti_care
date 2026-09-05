import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/speech_mode_provider.dart';

/// A widget that displays [text] and highlights the currently spoken word
/// using a neon glow effect. It listens to [speakingWordProvider] to know which
/// word is being spoken by the TTS service.
class NeonHighlightText extends ConsumerWidget {
  const NeonHighlightText({
    super.key,
    required this.text,
    this.textStyle,
    this.highlightColor = const Color(0xFF00FFFF), // cyan neon
  });

  final String text;
  final TextStyle? textStyle;
  final Color highlightColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWord = ref.watch(speakingWordProvider);
    final words = text.split(' ');
    return RichText(
      text: TextSpan(
        children: words.map((word) {
          final isActive = word == currentWord;
          final style = (textStyle ?? const TextStyle()).copyWith(
            color: isActive ? highlightColor : null,
          );
          final List<BoxShadow> decorations = isActive
              ? [
                  BoxShadow(
                    color: highlightColor.withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: highlightColor.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ]
              : [];
          return WidgetSpan(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                boxShadow: decorations,
              ),
              child: Text(word, style: style),
            ),
          );
        }).toList(),
        style: DefaultTextStyle.of(context).style,
      ),
    );
  }
}
