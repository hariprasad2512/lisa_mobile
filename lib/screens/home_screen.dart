import 'package:flutter/material.dart';
import '../services/assistant_controller.dart';
import '../theme.dart';
import '../widgets/assistant_sheet.dart';
import 'settings_screen.dart';

/// Legacy Google-Assistant style home, lisa-v2 themed.
class HomeScreen extends StatefulWidget {
  final AssistantController controller;
  final VoidCallback onToggleTheme;
  const HomeScreen({super.key, required this.controller, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [LisaTheme.teal, LisaTheme.emerald],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.graphic_eq, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Lisa', style: TextStyle(fontSize: 28, fontStyle: FontStyle.italic)),
            const SizedBox(width: 8),
            _statusDot(c.serverReady),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => c.clearMemory(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen(controller: c)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _history(context, c)),
          _suggestions(context, c),
          _bottomBar(context, c),
        ],
      ),
    );
  }

  Widget _statusDot(bool ready) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ready ? Colors.green : Colors.amber,
          ),
        ),
        const SizedBox(width: 4),
        Text(ready ? 'Ready' : 'Waking...', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _history(BuildContext context, AssistantController c) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: c.messages.length,
      itemBuilder: (_, i) {
        final m = c.messages[i];
        final isUser = m.role == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              gradient: isUser
                  ? const LinearGradient(colors: [LisaTheme.teal, LisaTheme.emerald])
                  : null,
              color: isUser
                  ? null
                  : Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1F2937).withValues(alpha: 0.8)
                      : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              m.content,
              style: TextStyle(color: isUser ? Colors.white : null),
            ),
          ),
        );
      },
    );
  }

  Widget _suggestions(BuildContext context, AssistantController c) {
    const chips = ['Weather near me', 'Latest news', 'Play my song', 'Tell me a joke'];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ActionChip(
          label: Text(chips[i]),
          onPressed: () => c.ask(chips[i]),
        ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context, AssistantController c) {
    final busy = c.state != LisaState.idle;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                busy ? c.statusText : 'Say "Hey Lisa" or tap the mic',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            FloatingActionButton.large(
              onPressed: () => showAssistantSheet(context, c),
              child: Icon(busy ? Icons.more_horiz : Icons.mic),
            ),
          ],
        ),
      ),
    );
  }
}
