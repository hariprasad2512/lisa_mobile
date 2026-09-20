import 'package:flutter/material.dart';
import '../theme.dart';

/// Simple yet beautiful speaking orb: gradient core + expanding rings
/// while [speaking], calm idle otherwise. Mirrors web voiceWave idea.
class LisaOrb extends StatefulWidget {
  final bool listening;
  final bool thinking;
  final bool speaking;
  const LisaOrb({super.key, this.listening = false, this.thinking = false, this.speaking = false});

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
    final active = widget.listening || widget.speaking || widget.thinking;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final pulse = active ? (0.5 + 0.5 * _c.value) : 0.15;
        return SizedBox(
          width: 148,
          height: 148,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                Container(
                  width: 120 + i * 10 + pulse * 14,
                  height: 120 + i * 10 + pulse * 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (dark ? LisaTheme.accentDark : LisaTheme.accentLight)
                        .withValues(alpha: 0.10 - i * 0.025),
                  ),
                ),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [LisaTheme.teal, LisaTheme.emerald, Color(0xFFAA3BFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (dark ? LisaTheme.accentDark : LisaTheme.accentLight)
                          .withValues(alpha: 0.45),
                      blurRadius: 28 + pulse * 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  widget.thinking
                      ? Icons.psychology
                      : widget.listening
                          ? Icons.mic
                          : Icons.graphic_eq,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WaveBars extends StatefulWidget {
  final bool animate;
  const WaveBars({super.key, this.animate = true});
  @override
  State<WaveBars> createState() => _WaveBarsState();
}

class _WaveBarsState extends State<WaveBars> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? LisaTheme.accentDark
        : LisaTheme.accentLight;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(7, (i) {
          final h = widget.animate ? 8 + ((i * 7 + _c.value * 22) % 22) : 8.0;
          return Container(
            width: 4,
            height: h,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          );
        }),
      ),
    );
  }
}
