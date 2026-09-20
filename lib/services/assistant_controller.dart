import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../models.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'location_service.dart';
import 'music_service.dart';
import 'store.dart';
import 'wake_service.dart';

enum LisaState { idle, listening, thinking, speaking }

class AssistantController extends ChangeNotifier {
  final LisaApi api;
  final AudioPlayer player = AudioPlayer();
  final AudioRecorder recorder = AudioRecorder();
  final WakeService wake = WakeService();

  List<ChatMessage> messages = [];
  LisaState state = LisaState.idle;
  String? userId;
  String voiceId = 'en-US-AvaNeural';
  bool serverReady = false;
  String statusText = 'Hi, how can I help?';

  /// Set by HomeScreen: wake-word opens the floating sheet overlay.
  /// Falls back to direct recording when no UI is attached yet.
  Future<void> Function()? onWakeUi;
  bool sheetOpen = false;

  AssistantController({LisaApi? api}) : api = api ?? LisaApi();

  Future<void> init() async {
    messages = await LocalStore.loadGuest();
    voiceId = await LocalStore.loadVoice();
    serverReady = await api.ping();
    notifyListeners();
    // Free foreground wake-word. Toggle from settings/home.
    try {
      await wake.start(() => onWake());
    } catch (_) {}
  }

  void onWake() {
    if (state != LisaState.idle || sheetOpen) return;
    final ui = onWakeUi;
    if (ui != null) {
      ui();
    } else {
      toggleTalk();
    }
  }

  void _set(LisaState s, [String? text]) {
    state = s;
    if (text != null) statusText = text;
    notifyListeners();
  }

  Future<void> _restartWake() async {
    // Mic is free again — resume foreground "Hey Lisa" listening.
    try {
      await wake.start(() => onWake());
    } catch (_) {}
  }

  Future<void> toggleTalk() async {
    if (state == LisaState.listening) {
      await _stopAndProcess();
    } else if (state == LisaState.idle) {
      await _startListening();
    } else if (state == LisaState.speaking) {
      await player.stop();
      _set(LisaState.idle, 'Hi, how can I help?');
      await _restartWake();
    }
  }

  Future<void> _startListening() async {
    try {
      await player.stop();
      // OS mic can't be shared: pause wake-word while recording.
      await wake.stop();
      final ok = await recorder.hasPermission();
      if (!ok) {
        _set(LisaState.idle, 'Microphone permission needed');
        return;
      }
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/lisa_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      _set(LisaState.listening, 'Listening...');
    } catch (e) {
      _set(LisaState.idle, 'Mic error: $e');
    }
  }

  Future<void> _stopAndProcess() async {
    String? path;
    try {
      path = await recorder.stop();
    } catch (_) {}
    if (path == null) {
      _set(LisaState.idle, 'Hi, how can I help?');
      await _restartWake();
      return;
    }
    _set(LisaState.thinking, 'Thinking...');
    try {
      final text = await api.transcribe(File(path));
      if (text.isEmpty) {
        _set(LisaState.idle, 'Did not catch that — tap mic to retry');
        await _restartWake();
        return;
      }
      await ask(text);
    } catch (e) {
      messages.add(ChatMessage(role: 'assistant', content: 'Connection error. Check backend URL in Settings.'));
      _persist();
      _set(LisaState.idle, 'Connection error');
      await _restartWake();
    } finally {
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  Future<void> ask(String text) async {
    _set(LisaState.thinking, 'Thinking...');
    final userMsg = ChatMessage(role: 'user', content: text);
    messages.add(userMsg);
    _persist();
    notifyListeners();
    try {
      double? lat, lng;
      if (LocationService.needsLocation(text)) {
        final pos = await LocationService.current();
        lat = pos?.latitude;
        lng = pos?.longitude;
      }
      final data = await api.chat(text: text, history: messages, lat: lat, lng: lng);

      if (data['action'] == 'play_music') {
        final query = '${data['query'] ?? text}';
        final speakText = '${data['speak'] ?? 'Playing $query'}';
        messages.add(ChatMessage(role: 'assistant', content: speakText));
        _persist();
        await _speak(speakText);
        await MusicService.play(query, data['url'] as String?);
        _set(LisaState.idle, 'Hi, how can I help?');
        await _restartWake();
        return;
      }

      final reply = '${data['response'] ?? data['message'] ?? '...'}';
      messages.add(ChatMessage(role: 'assistant', content: reply));
      _persist();
      await _speak(reply);
      _set(LisaState.idle, 'Hi, how can I help?');
      await _restartWake();
    } catch (e) {
      messages.add(ChatMessage(role: 'assistant', content: 'Connection error. Please try again.'));
      _persist();
      _set(LisaState.idle, 'Connection error');
      await _restartWake();
    }
  }

  Future<void> _speak(String text) async {
    _set(LisaState.speaking, text);
    try {
      final dir = await getTemporaryDirectory();
      final out = '${dir.path}/lisa_reply_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final file = await api.speak(text, voice: voiceId, savePath: out);
      await player.setFilePath(file.path);
      await player.play();
      try {
        await File(out).delete();
      } catch (_) {}
    } catch (_) {
      // Text still shown even if TTS fails (free backend waking up).
    }
  }

  Future<void> setVoice(String id) async {
    voiceId = id;
    await LocalStore.saveVoice(id);
    notifyListeners();
  }

  Future<void> clearMemory() async {
    messages = [ChatMessage(role: 'assistant', content: 'Hi I am Lisa! How can I assist you today?')];
    await LocalStore.clearGuest();
    if (userId != null) {
      try {
        await AuthService.db.from('messages').delete().eq('user_id', userId!);
      } catch (_) {}
    }
    notifyListeners();
  }

  void _persist() {
    if (userId == null) {
      LocalStore.saveGuest(messages);
    } else {
      final last = messages.last;
      AuthService.saveCloud(userId!, last);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    wake.stop();
    player.dispose();
    recorder.dispose();
    super.dispose();
  }
}
