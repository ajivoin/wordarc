import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:wordarc/domain/models/grid_cell.dart';
import 'package:wordarc/features/game/widgets/grid_tile.dart';

class CrosswordGrid extends StatelessWidget {
  const CrosswordGrid({
    required this.cells,
    required this.rows,
    required this.cols,
    super.key,
  });

  final Map<String, GridCell> cells;
  final int rows;
  final int cols;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = min(
          constraints.maxWidth / cols,
          constraints.maxHeight / rows,
        );
        final cellList = cells.values.toList();
        final ids = cellList.map((c) => '${c.row}-${c.col}').toList();

        return SizedBox(
          width: cellSize * cols,
          height: cellSize * rows,
          child: CustomMultiChildLayout(
            delegate: _GridDelegate(
              cellSize: cellSize,
              rows: rows,
              cols: cols,
              ids: ids,
            ),
            children: cellList.map((cell) {
              return LayoutId(
                id: '${cell.row}-${cell.col}',
                child: GridTile(
                  letter: cell.letter,
                  cellSize: cellSize,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _GridDelegate extends MultiChildLayoutDelegate {
  _GridDelegate({
    required this.cellSize,
    required this.rows,
    required this.cols,
    required this.ids,
  });

  final double cellSize;
  final int rows;
  final int cols;
  final List<String> ids;

  @override
  Size getSize(BoxConstraints constraints) =>
      Size(cols * cellSize, rows * cellSize);

  @override
  void performLayout(Size size) {
    for (final id in ids) {
      final parts = id.split('-');
      final row = int.parse(parts[0]);
      final col = int.parse(parts[1]);
      layoutChild(id, BoxConstraints.tight(Size(cellSize, cellSize)));
      positionChild(id, Offset(col * cellSize, row * cellSize));
    }
  }

  @override
  bool shouldRelayout(_GridDelegate other) =>
      other.cellSize != cellSize || other.ids.length != ids.length;
}
