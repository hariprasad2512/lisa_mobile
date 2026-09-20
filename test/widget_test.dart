import 'package:flutter_test/flutter_test.dart';
import 'package:lisa_mobile/models.dart';

void main() {
  test('ChatMessage encode/decode round-trips', () {
    final items = [
      ChatMessage(role: 'assistant', content: 'Hi I am Lisa!'),
      ChatMessage(role: 'user', content: 'Hello'),
    ];
    final raw = ChatMessage.encodeList(items);
    final back = ChatMessage.decodeList(raw);
    expect(back.length, 2);
    expect(back.first.content, 'Hi I am Lisa!');
  });

  test('Female voice allow-list is curated', () {
    expect(LisaVoice.all.length, 6);
    expect(LisaVoice.all.map((e) => e.id), contains('en-US-AvaNeural'));
    expect(LisaVoice.all.map((e) => e.id), contains('en-IN-NeerjaNeural'));
  });
}
