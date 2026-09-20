import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/assistant_controller.dart';
import '../widgets/assistant_sheet.dart';
import '../widgets/lisa_orb.dart';
import 'settings_screen.dart';

/// Pixel-faithful port of https://lisa-v2.vercel.app mobile view:
/// Header / ChatWindow / MicrophoneControls. No FAB, no chips.
class HomeScreen extends StatefulWidget {
  final AssistantController controller;
  final VoidCallback onToggleTheme;
  const HomeScreen({super.key, required this.controller, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    // Wake-word opens the floating bottom-sheet overlay.
    widget.controller.onWakeUi = () async {
      if (!mounted) return;
      await showAssistantSheet(context, widget.controller);
    };
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
      // Mirror ChatWindow auto-scroll.
      Future.microtask(() {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    widget.controller.onWakeUi = null;
    _scroll.dispose();
    super.dispose();
  }

  void _openSheet() => showAssistantSheet(context, widget.controller);

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(context, c, dark),
            Expanded(child: _chat(context, c, dark)),
            _micFooter(context, c, dark),
          ],
        ),
      ),
    );
  }

  // ---- Header (Header.jsx) ----
  Widget _header(BuildContext context, AssistantController c, bool dark) {
    final user = Supabase.instance.client.auth.currentUser;
    final avatarUrl =
        (user?.userMetadata?['avatar_url'] ?? user?.userMetadata?['picture']) as String?;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: (dark ? const Color(0xFF09090B) : Colors.white).withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(color: dark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.graphic_eq, color: Color(0xFF6EE7B7), size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lisa',
                style: GoogleFonts.dancingScript(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  color: dark ? Colors.white : Colors.black,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.serverReady ? const Color(0xFF10B981) : Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    c.serverReady ? 'Ready' : 'Waking up server...',
                    style: TextStyle(
                      fontSize: 12,
                      color: c.serverReady
                          ? (dark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B))
                          : Colors.amber,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          _roundBtn(
            dark,
            onTap: widget.onToggleTheme,
            icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 16),
          ),
          const SizedBox(width: 8),
          _roundBtn(dark, onTap: () => c.clearMemory(), icon: const Icon(Icons.delete_outline, size: 16)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen(controller: c)),
            ),
            child: avatarUrl != null
                ? CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatarUrl))
                : Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: dark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                      ),
                      color: dark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                    ),
                    child: const Icon(Icons.person_outline, size: 18),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _roundBtn(bool dark, {required VoidCallback onTap, required Widget icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: dark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
          color: dark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
        ),
        child: Center(child: icon),
      ),
    );
  }

  // ---- Chat (ChatWindow.jsx) ----
  Widget _chat(BuildContext context, AssistantController c, bool dark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [const Color(0xFF09090B), const Color(0xFF111827)]
              : [const Color(0xFFF3F4F6), const Color(0xFFF9FAFB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: c.messages.length + (c.state == LisaState.thinking ? 1 : 0),
        itemBuilder: (_, i) {
          if (i >= c.messages.length) return _processingRow(dark);
          final m = c.messages[i];
          final isUser = m.role == 'user';
          return Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF059669)])
                    : null,
                color: isUser
                    ? null
                    : (dark
                        ? const Color(0xFF1F2937).withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.85)),
                border: Border.all(
                  color: isUser
                      ? const Color(0xFF14B8A6).withValues(alpha: 0.3)
                      : (dark
                          ? const Color(0xFF374151).withValues(alpha: 0.5)
                          : const Color(0xFFE5E7EB)),
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isUser ? 24 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 24),
                ),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16)],
              ),
              child: Text(
                m.content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isUser ? Colors.white : (dark ? const Color(0xFFF3F4F6) : const Color(0xFF1F2937)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _processingRow(bool dark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF1F2937).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.85),
          border: Border.all(
            color: dark ? const Color(0xFF374151).withValues(alpha: 0.5) : const Color(0xFFE5E7EB),
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D9488)),
            ),
            const SizedBox(width: 12),
            Text(
              'Processing logic...',
              style: TextStyle(
                fontSize: 13,
                color: dark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Mic footer (MicrophoneControls.jsx) ----
  Widget _micFooter(BuildContext context, AssistantController c, bool dark) {
    final listening = c.state == LisaState.listening;
    final thinking = c.state == LisaState.thinking;
    final speaking = c.state == LisaState.speaking;
    final busy = listening || thinking || speaking;

    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF09090B) : const Color(0xFFF9FAFB),
        border: Border(
          top: BorderSide(color: dark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E7EB)),
        ),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, -8))],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: listening ? 20 : 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (thinking) return;
              if (listening || speaking) {
                c.toggleTalk();
              } else {
                _openSheet();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LisaOrb(
                  listening: listening,
                  thinking: thinking,
                  speaking: speaking,
                  size: listening ? 64 : 48,
                ),
                if (listening) ...[
                  const SizedBox(height: 10),
                  const ListenBars(),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            thinking
                ? 'Thinking...'
                : listening
                    ? 'Listening...'
                    : speaking
                        ? 'Speaking...'
                        : 'Tap to speak',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: thinking
                  ? const Color(0xFF2DD4BF)
                  : listening
                      ? Colors.red.shade400
                      : speaking
                          ? const Color(0xFF2DD4BF)
                          : (dark ? const Color(0xFFD4D4D8) : const Color(0xFF374151)),
            ),
          ),
          if (busy)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                thinking
                    ? 'PROCESSING YOUR VOICE'
                    : listening
                        ? 'PRESS AGAIN TO STOP'
                        : 'TAP TO STOP',
                style: const TextStyle(fontSize: 11, letterSpacing: 0.6, color: Colors.grey),
              ),
            ),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'LISA V2',
              style: TextStyle(fontSize: 10, letterSpacing: 2.5, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
