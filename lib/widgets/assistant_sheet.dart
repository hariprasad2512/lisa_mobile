import 'package:flutter/material.dart';
import '../services/assistant_controller.dart';
import '../widgets/lisa_orb.dart';

/// Google-Assistant-legacy style bottom-sheet overlay.
/// Opens on mic tap or "Hey Lisa" wake. Stays while app is alive.
Future<void> showAssistantSheet(BuildContext context, AssistantController c) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AssistantSheet(c: c),
  );
}

class _AssistantSheet extends StatefulWidget {
  final AssistantController c;
  const _AssistantSheet({required this.c});
  @override
  State<_AssistantSheet> createState() => _AssistantSheetState();
}

class _AssistantSheetState extends State<_AssistantSheet> {
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.c.addListener(_refresh);
    // Auto-start listening like Assistant does on wake.
    Future.microtask(() => widget.c.toggleTalk());
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.c.removeListener(_refresh);
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final sheet = Theme.of(context).bottomSheetTheme.modalBackgroundColor ??
        Theme.of(context).scaffoldBackgroundColor;
    String label = 'Hi, how can I help?';
    if (c.state == LisaState.listening) {
      label = 'Listening...';
    } else if (c.state == LisaState.thinking) {
      label = 'Thinking...';
    } else if (c.state == LisaState.speaking) {
      label = 'Speaking...';
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (_, scroll) => Container(
        decoration: BoxDecoration(
          color: sheet,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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
            const SizedBox(height: 14),
            Center(
              child: LisaOrb(
                listening: c.state == LisaState.listening,
                thinking: c.state == LisaState.thinking,
                speaking: c.state == LisaState.speaking,
              ),
            ),
            const SizedBox(height: 8),
            Center(child: WaveBars(animate: c.state != LisaState.idle)),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            if (c.state == LisaState.speaking)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(c.statusText,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _text,
                    decoration: const InputDecoration(
                      hintText: 'Type instead...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      isDense: true,
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isEmpty) return;
                      Navigator.pop(context);
                      c.ask(v.trim());
                      _text.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => c.toggleTalk(),
                  icon: Icon(
                    c.state == LisaState.listening
                        ? Icons.stop
                        : c.state == LisaState.speaking
                            ? Icons.stop_circle
                            : Icons.mic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Say "Hey Lisa" or tap the mic. Short spoken answers by design.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
