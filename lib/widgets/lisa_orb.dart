import 'package:flutter/material.dart';

/// Mic orb matching lisa-v2 website MicrophoneControls:
/// idle = gray circle, listening = red gradient + ping rings + glow,
/// thinking = teal glow + spinner, speaking = teal gradient.
class LisaOrb extends StatefulWidget {
  final bool listening;
  final bool thinking;
  final bool speaking;
  final double size;
  const LisaOrb({
    super.key,
    this.listening = false,
    this.thinking = false,
    this.speaking = false,
    this.size = 96,
  });

  @override
  State<LisaOrb> createState() => _LisaOrbState();
}

class _LisaOrbState extends State<LisaOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final active = widget.listening || widget.speaking || widget.thinking;
    final s = widget.size;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final pulse = active ? (0.5 + 0.5 * _c.value) : 0.0;
        return SizedBox(
          width: s + 52,
          height: s + 52,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.listening) ...[
                Container(
                  width: s + 8 + pulse * 10,
                  height: s + 8 + pulse * 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red.shade400.withValues(alpha: 0.30)),
                  ),
                ),
                Container(
                  width: s + 24 + pulse * 14,
                  height: s + 24 + pulse * 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red.shade400.withValues(alpha: 0.20)),
                  ),
                ),
                Container(
                  width: s + 36,
                  height: s + 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade500.withValues(alpha: 0.20),
                  ),
                ),
              ],
              if (widget.thinking || widget.speaking)
                Container(
                  width: s + 36,
                  height: s + 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2DD4BF).withValues(alpha: 0.20),
                  ),
                ),
              Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.listening
                      ? const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFE11D48)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : widget.thinking || widget.speaking
                          ? const LinearGradient(
                              colors: [Color(0xFF14B8A6), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                  color: (!widget.listening && !widget.thinking && !widget.speaking)
                      ? (dark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB))
                      : null,
                  border: (!widget.listening && !widget.thinking && !widget.speaking)
                      ? Border.all(
                          color: dark ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
                        )
                      : widget.listening
                          ? Border.all(color: Colors.red.shade500.withValues(alpha: 0.2), width: 4)
                          : null,
                  boxShadow: [
                    BoxShadow(
                      color: widget.listening
                          ? Colors.red.shade500.withValues(alpha: 0.30)
                          : const Color(0xFF2DD4BF).withValues(alpha: active ? 0.25 : 0.0),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  widget.thinking
                      ? Icons.hourglass_empty
                      : widget.listening
                          ? Icons.mic_off
                          : widget.speaking
                              ? Icons.stop
                              : Icons.mic,
                  color: (widget.listening || widget.thinking || widget.speaking)
                      ? Colors.white
                      : const Color(0xFF2DD4BF),
                  size: s * 0.42,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Website 7-bar red wave, shown ONLY while listening in the footer.
class ListenBars extends StatefulWidget {
  const ListenBars({super.key});
  @override
  State<ListenBars> createState() => _ListenBarsState();
}

class _ListenBarsState extends State<ListenBars> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(7, (i) {
          final h = 8 + ((i * 7 + _c.value * 22) % 22);
          return Container(
            width: 4,
            height: h,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.red.shade400.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}
