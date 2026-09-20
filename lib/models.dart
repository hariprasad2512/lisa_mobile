import 'dart:convert';

class ChatMessage {
  final String role; // user | assistant
  final String content;
  ChatMessage({required this.role, required this.content});

  Map<String, String> toJson() => {'role': role, 'content': content};

  static ChatMessage fromJson(Map<String, dynamic> j) =>
      ChatMessage(role: '${j['role']}', content: '${j['content']}');

  static String encodeList(List<ChatMessage> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<ChatMessage> decodeList(String raw) {
    try {
      final data = jsonDecode(raw) as List;
      return data
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

// Curated female-only voices (Edge-TTS). Backend_mobile serves same list.
class LisaVoice {
  final String id;
  final String label;
  final String locale;
  const LisaVoice(this.id, this.label, this.locale);

  static const all = [
    LisaVoice('en-US-AvaNeural', 'Ava — warm assistant', 'en-US'),
    LisaVoice('en-US-AriaNeural', 'Aria — natural news', 'en-US'),
    LisaVoice('en-US-JennyNeural', 'Jenny — friendly', 'en-US'),
    LisaVoice('en-US-MichelleNeural', 'Michelle — pleasant', 'en-US'),
    LisaVoice('en-US-AnaNeural', 'Ana — cute chat', 'en-US'),
    LisaVoice('en-IN-NeerjaNeural', 'Neerja — Indian English', 'en-IN'),
  ];
}
