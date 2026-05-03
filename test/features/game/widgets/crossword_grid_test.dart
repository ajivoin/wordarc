import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordarc/domain/models/grid_cell.dart';
import 'package:wordarc/features/game/widgets/crossword_grid.dart';

Map<String, GridCell> _buildCells(List<(int, int, String)> entries) {
  return {
    for (final e in entries) '${e.$1}-${e.$2}': GridCell(row: e.$1, col: e.$2, letter: e.$3),
  };
}

Widget _buildSubject(Map<String, GridCell> cells) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 300,
        height: 300,
        child: CrosswordGrid(cells: cells, rows: 4, cols: 4),
      ),
    ),
  );
}

void main() {
  // TAP across + PAT down, intersection at (1,1)='A', total 5 cells.
  final testCells = _buildCells([
    (1, 0, 'T'),
    (1, 1, 'A'),
    (1, 2, 'P'),
    (0, 1, 'P'),
    (2, 1, 'T'),
  ]);

  group('CrosswordGrid', () {
    testWidgets('renders all cell letters', (tester) async {
      await tester.pumpWidget(_buildSubject(testCells));
      await tester.pumpAndSettle();

      // Each GridTile shows one letter Text. We have 5 cells.
      final letterFinder = find.byWidgetPredicate(
        (w) =>
            w is Text &&
            w.data != null &&
            w.data!.length == 1 &&
            RegExp('[A-Z]').hasMatch(w.data!),
      );
      expect(letterFinder, findsNWidgets(5));
    });

    testWidgets('specific letters appear in the grid', (tester) async {
      await tester.pumpWidget(_buildSubject(testCells));
      await tester.pumpAndSettle();

      expect(find.text('T'), findsNWidgets(2)); // (1,0) and (2,1)
      expect(find.text('A'), findsOneWidget);   // (1,1)
      expect(find.text('P'), findsNWidgets(2)); // (1,2) and (0,1)
    });

    testWidgets('empty cells map renders without error', (tester) async {
      await tester.pumpWidget(_buildSubject({}));
      await tester.pumpAndSettle();

      final letterFinder = find.byWidgetPredicate(
        (w) =>
            w is Text &&
            w.data != null &&
            w.data!.length == 1 &&
            RegExp('[A-Z]').hasMatch(w.data!),
      );
      expect(letterFinder, findsNothing);
    });
  });
}
