import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config.dart';
import '../models.dart';

class LisaApi {
  final String base;
  LisaApi({String? base}) : base = (base ?? AppConfig.backendUrl).replaceAll(RegExp(r'/$'), '');

  Future<bool> ping() async {
    try {
      final r = await http.get(Uri.parse('$base/')).timeout(const Duration(seconds: 10));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<String> transcribe(File audio, {String mime = 'audio/m4a'}) async {
    final req = http.MultipartRequest('POST', Uri.parse('$base/transcribe'));
    req.files.add(await http.MultipartFile.fromPath(
      'file',
      audio.path,
      contentType: MediaType.parse(mime),
      filename: 'voice.m4a',
    ));
    final res = await req.send().timeout(const Duration(seconds: 60));
    final body = await http.Response.fromStream(res);
    if (res.statusCode != 200) throw Exception('transcribe ${res.statusCode}: ${body.body}');
    final data = jsonDecode(body.body) as Map<String, dynamic>;
    return '${data['text'] ?? data['transcription'] ?? ''}'.trim();
  }

  /// Returns either {'response': text} or {'action':'play_music',...}
  Future<Map<String, dynamic>> chat({
    required String text,
    required List<ChatMessage> history,
    double? lat,
    double? lng,
  }) async {
    final payload = {
      'text': text,
      'history': history.map((e) => e.toJson()).toList(),
      if (lat != null && lng != null)
        'location': {'latitude': lat, 'longitude': lng},
    };
    final r = await http
        .post(Uri.parse('$base/chat'),
            headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload))
        .timeout(const Duration(seconds: 60));
    if (r.statusCode != 200) throw Exception('chat ${r.statusCode}: ${r.body}');
    return Map<String, dynamic>.from(jsonDecode(r.body));
  }

  Future<File> speak(String text, {required String voice, required String savePath}) async {
    final r = await http
        .post(Uri.parse('$base/speak'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text, 'voice': voice}))
        .timeout(const Duration(seconds: 60));
    // Old backend ignores voice and returns mp3 anyway — still playable.
    if (r.statusCode != 200) throw Exception('speak ${r.statusCode}: ${r.body}');
    final f = File(savePath);
    await f.writeAsBytes(r.bodyBytes);
    return f;
  }

  Future<List<String>> voices() async {
    try {
      final r = await http.get(Uri.parse('$base/voices')).timeout(const Duration(seconds: 10));
      if (r.statusCode != 200) return LisaVoice.all.map((e) => e.id).toList();
      final data = jsonDecode(r.body) as Map<String, dynamic>;
      final list = (data['voices'] as List?) ?? [];
      return list.map((e) => '${e['id'] ?? e}').toList();
    } catch (_) {
      return LisaVoice.all.map((e) => e.id).toList();
    }
  }
}
