import 'package:supabase_flutter/supabase_flutter.dart';
import '../models.dart';
import 'store.dart';

/// Mirrors web chatService.js: guest local -> cloud migration on login.
class AuthService {
  static SupabaseClient get db => Supabase.instance.client;

  static Future<void> saveCloud(String userId, ChatMessage m) async {
    try {
      await db.from('messages').insert({
        'user_id': userId,
        'role': m.role,
        'content': m.content,
      });
    } catch (_) {}
  }

  static Future<List<ChatMessage>> fetchCloud(String userId) async {
    try {
      final rows = await db
          .from('messages')
          .select('role, content, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: true);
      final seen = <String>{};
      final out = <ChatMessage>[];
      for (final r in (rows as List)) {
        final key = '${r['role']}:${r['content']}';
        if (seen.add(key)) {
          out.add(ChatMessage(role: '${r['role']}', content: '${r['content']}'));
        }
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  static Future<List<ChatMessage>> migrateGuest(String userId) async {
    final guest = await LocalStore.loadGuest();
    final cloud = await fetchCloud(userId);
    final cloudKeys = cloud.map((e) => '${e.role}:${e.content}').toSet();
    final toInsert = guest.where((e) => !cloudKeys.contains('${e.role}:${e.content}')).toList();
    try {
      if (toInsert.isNotEmpty) {
        await db.from('messages').insert(
              toInsert.map((e) => {'user_id': userId, 'role': e.role, 'content': e.content}).toList(),
            );
      }
    } catch (_) {}
    await LocalStore.clearGuest();
    final fresh = await fetchCloud(userId);
    return fresh.isEmpty ? guest : fresh;
  }
}
