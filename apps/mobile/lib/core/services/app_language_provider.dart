import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global provider for the selected language of the app (ISO code).
/// Default is English ('en').
final appLanguageProvider = StateProvider<String>((ref) => 'en');
