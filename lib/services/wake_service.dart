import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../config.dart';

/// Free on-device wake-word approximation.
/// Listens continuously for "hey lisa" using OS speech recognition.
/// Upgrade path: swap with flutter_porcupine + custom .ppn model for
/// true always-on, low-battery detection (needs free Picovoice AccessKey).
/// iOS note: background mic is blocked by the OS; wake works in foreground.
/// Android background needs a foreground service + persistent notification.
class WakeService {
  final SpeechToText _stt = SpeechToText();
  bool _running = false;
  bool get running => _running;

  Future<bool> init() async => _stt.initialize();

  Future<void> start(void Function() onWake) async {
    if (_running) return;
    final ok = await _stt.initialize();
    if (!ok) return;
    _running = true;
    _listen(onWake);
  }

  void _listen(void Function() onWake) {
    if (!_running) return;
    _stt.listen(
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
      ),
      onResult: (SpeechRecognitionResult r) {
        if (r.recognizedWords.toLowerCase().contains(AppConfig.wakePhrase)) {
          onWake();
        }
      },
    );
    // Restart loop when OS auto-stops (keeps it "always-on" in foreground).
    Future.delayed(const Duration(seconds: 25), () async {
      if (!_running) return;
      try {
        await _stt.stop();
      } catch (_) {}
      _listen(onWake);
    });
  }

  Future<void> stop() async {
    _running = false;
    try {
      await _stt.stop();
    } catch (_) {}
  }
}
