// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:math' as math;

/// Fond animé Léxi : formes douces orange / violet qui flottent lentement
/// et petites étoiles qui scintillent. Léger (un seul painter).
/// intensite : 0.5 = très discret, 1 = normal, 1.4 = plus visible.
class LexiFond extends StatefulWidget {
  const LexiFond({
    super.key,
    this.width,
    this.height,
    this.intensite = 1.0,
    this.etoiles = true,
  });

  final double? width;
  final double? height;
  final double intensite;
  final bool etoiles;

  @override
  State<LexiFond> createState() => _LexiFondState();
}

class _LexiFondState extends State<LexiFond>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _FondPeintre(
              _c,
              sombre: sombre,
              intensite: widget.intensite,
              etoiles: widget.etoiles,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _FondPeintre extends CustomPainter {
  _FondPeintre(this.anim,
      {required this.sombre, required this.intensite, required this.etoiles})
      : super(repaint: anim);

  final Animation<double> anim;
  final bool sombre;
  final double intensite;
  final bool etoiles;

  static const _orange = Color(0xFFF97316);
  static const _violet = Color(0xFF7C3AED);
  static const _rose = Color(0xFFEC4899);
  static const _jaune = Color(0xFFFBBF24);

  // étoiles fixes (positions pseudo-aléatoires stables)
  static final List<List<double>> _pts = () {
    final r = math.Random(7);
    return List.generate(
        16, (_) => [r.nextDouble(), r.nextDouble(), r.nextDouble(), 1 + r.nextDouble() * 1.8]);
  }();

  void _bulle(Canvas canvas, Offset c, double rayon, Color coul, double alpha) {
    final p = Paint()
      ..shader = RadialGradient(colors: [
        coul.withOpacity(alpha),
        coul.withOpacity(alpha * 0.35),
        coul.withOpacity(0),
      ], stops: const [0, 0.45, 1])
          .createShader(Rect.fromCircle(center: c, radius: rayon));
    canvas.drawCircle(c, rayon, p);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final t = anim.value * 2 * math.pi;
    final w = size.width, h = size.height;
    final m = math.max(w, h);
    final a = (sombre ? 0.30 : 0.20) * intensite;

    _bulle(canvas, Offset(w * (0.15 + 0.10 * math.sin(t)), h * (0.12 + 0.06 * math.cos(t))),
        m * 0.45, _orange, a);
    _bulle(canvas, Offset(w * (0.90 + 0.08 * math.cos(t + 1)), h * (0.35 + 0.08 * math.sin(t + 1))),
        m * 0.42, _violet, a);
    _bulle(canvas, Offset(w * (0.25 + 0.12 * math.cos(t + 2.5)), h * (0.80 + 0.06 * math.sin(t + 2))),
        m * 0.40, _rose, a * 0.75);
    _bulle(canvas, Offset(w * (0.75 + 0.10 * math.sin(t + 4)), h * (0.95 + 0.04 * math.cos(t + 4))),
        m * 0.35, _orange, a * 0.7);

    if (!etoiles) return;
    final pe = Paint();
    for (final s in _pts) {
      // chaque étoile scintille à son rythme et monte très lentement
      final phase = s[2] * 2 * math.pi;
      final eclat = (math.sin(t * 3 + phase) + 1) / 2; // 0..1
      final y = ((s[1] - anim.value * 0.15) % 1.0) * h;
      final x = s[0] * w + 6 * math.sin(t + phase);
      final coul = s[2] > 0.5 ? _jaune : (sombre ? Colors.white : _violet);
      pe.color = coul.withOpacity((sombre ? 0.55 : 0.35) * eclat * intensite.clamp(0, 1.4));
      canvas.drawCircle(Offset(x, y), s[3], pe);
    }
  }

  @override
  bool shouldRepaint(covariant _FondPeintre old) =>
      old.sombre != sombre || old.intensite != intensite || old.etoiles != etoiles;
}
