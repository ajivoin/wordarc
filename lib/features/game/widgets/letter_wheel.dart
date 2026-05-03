import 'package:flutter/material.dart';
import 'package:wordarc/features/game/widgets/wheel_painter.dart';

class LetterWheel extends StatelessWidget {
  const LetterWheel({required this.letters, super.key});

  final String letters;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: WheelPainter(
          letters: letters,
          diskColor: colorScheme.primaryContainer,
          letterCircleColor: colorScheme.primary,
          letterColor: colorScheme.onPrimary,
        ),
      ),
    );
  }
}
