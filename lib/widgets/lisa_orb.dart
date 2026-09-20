import 'package:flutter/material.dart';

/// Mic orb matching lisa-v2 website MicrophoneControls.
/// Animation controllers run ONLY while listening/thinking/speaking —
/// idle is a single static frame (no constant swinging).
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
    this.size = 48,
  });

  bool get active => listening || thinking || speaking;

  @override
  State<LisaOrb> createState() => _LisaOrbState();
}

class _LisaOrbState extends State<LisaOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(LisaOrb old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.active && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final s = widget.size;
    if (!widget.active) {
      // Idle: static gray circle, teal mic — zero animation.
      return Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
          border: Border.all(color: dark ? const Color(0xFF374151) : const Color(0xFFD1D5DB)),
        ),
        child: Icon(Icons.mic, color: const Color(0xFF2DD4BF), size: s * 0.42),
      );
    }
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        // Single slow ping (website animate-ping): scale + fade over 2s.
        final t = _c.value;
        final ringScale = 1.0 + t * 0.35;
        final ringOpacity = (1.0 - t).clamp(0.0, 1.0);
        final glowPulse = widget.thinking ? (0.5 + 0.5 * (t * 2 % 1)) : 1.0;
        return SizedBox(
          width: s + 56,
          height: s + 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.listening)
                Transform.scale(
                  scale: ringScale,
                  child: Container(
                    width: s + 16,
                    height: s + 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red.shade400.withValues(alpha: 0.35 * ringOpacity + 0.08),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              Container(
                width: s + 40,
                height: s + 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (widget.listening ? Colors.red.shade500 : const Color(0xFF2DD4BF))
                      .withValues(alpha: 0.14 * glowPulse + 0.06),
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
                      : const LinearGradient(
                          colors: [Color(0xFF14B8A6), Color(0xFF059669)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  border: widget.listening
                      ? Border.all(color: Colors.red.shade500.withValues(alpha: 0.2), width: 4)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: (widget.listening ? Colors.red.shade500 : const Color(0xFF2DD4BF))
                          .withValues(alpha: 0.30),
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
                          : Icons.stop,
                  color: Colors.white,
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

/// Website 7-bar red wave. Mounted ONLY while listening.
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
