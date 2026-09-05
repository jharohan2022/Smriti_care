import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../api/api_client.dart';
import 'speech_mode_provider.dart';

/// Persistent narration for the zero-literacy patient UI.
///
/// Strategy: try the Bhashini gateway first (natural regional-language voices,
/// cached server-side), and **always** fall back to on-device TTS so narration
/// works with no connectivity. Callers never await network success — a failed
/// Bhashini call silently degrades.
class TtsService {
  TtsService(this._api, this._flutterTts) {
    _flutterTts
      ..setSpeechRate(0.42) // slow, calm cadence for elderly listeners
      ..setPitch(1.0);
  }

  final ApiClient _api;
  final FlutterTts _flutterTts;
  final AudioPlayer _player = AudioPlayer();

  /// Speak [text] in [langCode] (BCP-47-ish: 'hi', 'ta', 'bn', 'en').
  /// If speech mode is disabled, this becomes a no‑op.
  Future<void> speak(String text, {String langCode = 'hi'}) async {
    final container = ProviderContainer();
    final enabled = container.read(speechModeProvider);
    if (!enabled) return;
    final words = text.split(' ');
    for (final word in words) {
      container.read(speakingWordProvider.notifier).state = word;
      if (await _speakViaBhashini(word, langCode)) continue;
      await _speakOnDevice(word, langCode);
      await Future.delayed(const Duration(milliseconds: 200));
    }
    container.read(speakingWordProvider.notifier).state = null;
  }

  Future<bool> _speakViaBhashini(String text, String langCode) async {
    try {
      final res = await _api.post<Map<String, dynamic>>(
        '/bhashini/tts',
        data: {'text': text, 'sourceLanguage': langCode},
      );
      final b64 = res.data?['audioContent'] as String?;
      if (b64 == null || b64.isEmpty) return false;
      await _player.play(BytesSource(base64Decode(b64)));
      return true;
    } on ApiFailure {
      return false; // offline / gateway down → fall back
    } catch (_) {
      return false;
    }
  }

  Future<void> _speakOnDevice(String text, String langCode) async {
    const map = {'hi': 'hi-IN', 'ta': 'ta-IN', 'bn': 'bn-IN', 'en': 'en-IN'};
    await _flutterTts.setLanguage(map[langCode] ?? 'en-IN');
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _player.stop();
    await _flutterTts.stop();
  }
}

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService(ref.watch(apiClientProvider), FlutterTts());
  ref.onDispose(service.stop);
  return service;
});
