import 'dart:math';

import 'package:flutter/rendering.dart';

class WheelPainter extends CustomPainter {
  WheelPainter({
    required this.letters,
    required this.diskColor,
    required this.letterCircleColor,
    required this.letterColor,
  });

  final String letters;
  final Color diskColor;
  final Color letterCircleColor;
  final Color letterColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final shortestSide = min(size.width, size.height);
    final diskRadius = shortestSide * 0.36;
    final orbitRadius = shortestSide * 0.24;
    final letterCircleRadius = shortestSide * 0.10;
    final fontSize = shortestSide * 0.11;

    canvas.drawCircle(center, diskRadius, Paint()..color = diskColor);

    if (letters.isEmpty) return;

    final n = letters.length;
    for (var i = 0; i < n; i++) {
      final angle = -pi / 2 + (2 * pi / n) * i;
      final pos = Offset(
        center.dx + cos(angle) * orbitRadius,
        center.dy + sin(angle) * orbitRadius,
      );

      canvas.drawCircle(
        pos,
        letterCircleRadius,
        Paint()..color = letterCircleColor,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: letters[i],
          style: TextStyle(
            fontSize: fontSize,
            color: letterColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(WheelPainter other) => other.letters != letters;
}
