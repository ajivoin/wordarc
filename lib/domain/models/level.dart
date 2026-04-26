import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wordarc/domain/models/grid_cell.dart';
import 'package:wordarc/domain/models/word_placement.dart';

part 'level.freezed.dart';
part 'level.g.dart';

@freezed
class Level with _$Level {
  const Level._();

  const factory Level({
    required String id,
    required String packId,
    required int index,
    required String title,
    required String letters,
    required int rows,
    required int cols,
    required List<WordPlacement> placements,
    required int rewardCoins,
  }) = _Level;

  factory Level.fromJson(Map<String, dynamic> json) => _$LevelFromJson(json);

  Map<String, GridCell> get cells {
    final map = <String, GridCell>{};
    for (final p in placements) {
      final isAcross = p.dir == WordDirection.across;
      for (var i = 0; i < p.word.length; i++) {
        final row = isAcross ? p.row : p.row + i;
        final col = isAcross ? p.col + i : p.col;
        final key = '$row-$col';
        assert(
          !map.containsKey(key) || map[key]!.letter == p.word[i],
          'Intersection conflict at $key',
        );
        map[key] = GridCell(row: row, col: col, letter: p.word[i]);
      }
    }
    return map;
  }
}
