import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  SpeechService({FlutterTts? engine}) : _engine = engine ?? FlutterTts();

  final FlutterTts _engine;

  Future<void> speak(String text, String languageCode) async {
    await _engine.stop();
    await _engine.setLanguage(languageCode == 'ar' ? 'ar-SA' : 'en-US');
    await _engine.setSpeechRate(languageCode == 'ar' ? 0.38 : 0.46);
    await _engine.setPitch(1.0);
    await _engine.speak(text);
  }

  Future<void> stop() => _engine.stop();
}
