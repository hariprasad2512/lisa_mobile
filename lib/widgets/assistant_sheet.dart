import 'package:flutter/material.dart';
import '../services/assistant_controller.dart';
import 'lisa_orb.dart';

/// Floating bottom-sheet overlay. Opens on mic tap or "Hey Lisa" wake,
/// auto-starts listening, mirrors the website mic block styling.
Future<void> showAssistantSheet(BuildContext context, AssistantController c) {
  if (c.sheetOpen) return Future.value();
  c.sheetOpen = true;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AssistantSheet(c: c),
  ).whenComplete(() => c.sheetOpen = false);
}

class _AssistantSheet extends StatefulWidget {
  final AssistantController c;
  const _AssistantSheet({required this.c});
  @override
  State<_AssistantSheet> createState() => _AssistantSheetState();
}

class _AssistantSheetState extends State<_AssistantSheet> {
  @override
  void initState() {
    super.initState();
    widget.c.addListener(_refresh);
    // Auto-start listening like the website does on mic tap / wake.
    Future.microtask(() {
      if (widget.c.state == LisaState.idle) widget.c.toggleTalk();
    });
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.c.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final sheet = Theme.of(context).bottomSheetTheme.modalBackgroundColor ??
        Theme.of(context).scaffoldBackgroundColor;
    final listening = c.state == LisaState.listening;
    final thinking = c.state == LisaState.thinking;
    final speaking = c.state == LisaState.speaking;

    String title = 'Hi, how can I help?';
    String sub = 'SAY "HEY LISA" OR TAP THE MIC';
    if (listening) {
      title = 'Listening...';
      sub = 'PRESS AGAIN TO STOP';
    } else if (thinking) {
      title = 'Thinking...';
      sub = 'PROCESSING YOUR VOICE';
    } else if (speaking) {
      title = 'Speaking...';
      sub = 'TAP TO STOP';
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scroll) => Container(
        decoration: BoxDecoration(
          color: sheet,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: ListView(
          controller: scroll,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: GestureDetector(
                onTap: () {
                  if (listening || speaking) c.toggleTalk();
                },
                child: LisaOrb(
                  listening: listening,
                  thinking: thinking,
                  speaking: speaking,
                  size: 88,
                ),
              ),
            ),
            if (listening) ...[
              const SizedBox(height: 10),
              const Center(child: ListenBars()),
            ],
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: listening
                    ? Colors.red.shade400
                    : thinking
                        ? const Color(0xFF0D9488)
                        : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
            ),
            if (speaking)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  c.statusText,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 14),
            const Text(
              'LISA V2',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, letterSpacing: 2.5, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
