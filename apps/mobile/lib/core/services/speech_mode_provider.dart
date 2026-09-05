import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global provider that stores whether Speech Mode is active.
final speechModeProvider = StateProvider<bool>((ref) => false);

/// Provider exposing the word currently being spoken (for neon highlight).
final speakingWordProvider = StateProvider<String?>((ref) => null);
