import 'dart:math';

import 'package:flutter/material.dart';

class GridTile extends StatefulWidget {
  const GridTile({
    required this.letter,
    required this.cellSize,
    super.key,
  });

  final String letter;
  final double cellSize;

  @override
  State<GridTile> createState() => _GridTileState();
}

class _GridTileState extends State<GridTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _angle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _angle = Tween<double>(begin: pi / 2, end: 0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _angle,
      builder: (context, _) {
        final showFront = _angle.value <= pi / 2;
        return Transform(
          transform: Matrix4.rotationY(_angle.value),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              width: widget.cellSize - 4,
              height: widget.cellSize - 4,
              decoration: BoxDecoration(
                color: showFront
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: showFront
                  ? Center(
                      child: Text(
                        widget.letter,
                        style: TextStyle(
                          fontSize: widget.cellSize * 0.45,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}
