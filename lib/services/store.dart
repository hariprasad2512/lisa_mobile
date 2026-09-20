import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models.dart';

class LocalStore {
  static Future<List<ChatMessage>> loadGuest() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(AppConfig.guestKey);
    if (raw == null || raw.isEmpty) {
      return [ChatMessage(role: 'assistant', content: 'Hi I am Lisa! How can I assist you today?')];
    }
    final items = ChatMessage.decodeList(raw);
    return items.isEmpty
        ? [ChatMessage(role: 'assistant', content: 'Hi I am Lisa! How can I assist you today?')]
        : items;
  }

  static Future<void> saveGuest(List<ChatMessage> items) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(AppConfig.guestKey, ChatMessage.encodeList(items));
  }

  static Future<void> clearGuest() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(AppConfig.guestKey);
  }

  static Future<String> loadVoice() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(AppConfig.voiceKey) ?? AppConfig.defaultVoice;
  }

  static Future<void> saveVoice(String id) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(AppConfig.voiceKey, id);
  }
}
