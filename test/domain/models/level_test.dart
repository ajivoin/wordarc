import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordarc/domain/models/level.dart';
import 'package:wordarc/domain/models/word_placement.dart';

// APPLE across row=1, col=0: (1,0)=A (1,1)=P (1,2)=P (1,3)=L (1,4)=E
// PEAL  down  row=0, col=4: (0,4)=P (1,4)=E (2,4)=A (3,4)=L
// Intersection at (1,4): both 'E' — valid.
// Total cells: 5 + 4 - 1 = 8
const _level001Json = '''
{
  "id": "forest-001",
  "packId": "forest",
  "index": 0,
  "title": "Sunrise 1",
  "letters": "AEPPL",
  "rows": 5,
  "cols": 5,
  "placements": [
    { "word": "APPLE", "row": 1, "col": 0, "dir": "across" },
    { "word": "PEAL",  "row": 0, "col": 4, "dir": "down"   }
  ],
  "rewardCoins": 25
}
''';

// TAP across row=1, col=0: (1,0)=T (1,1)=A (1,2)=P
// PAT down  row=0, col=1: (0,1)=P (1,1)=A (2,1)=T
// Intersection at (1,1): both 'A' — valid.
// Total cells: 3 + 3 - 1 = 5
const _cleanJson = '''
{
  "id": "test-001",
  "packId": "test",
  "index": 0,
  "title": "Test",
  "letters": "APT",
  "rows": 4,
  "cols": 4,
  "placements": [
    { "word": "TAP", "row": 1, "col": 0, "dir": "across" },
    { "word": "PAT", "row": 0, "col": 1, "dir": "down"   }
  ],
  "rewardCoins": 10
}
''';

void main() {
  group('Level.fromJson', () {
    late Level level;

    setUp(() {
      level = Level.fromJson(
        jsonDecode(_level001Json) as Map<String, dynamic>,
      );
    });

    test('parses top-level fields correctly', () {
      expect(level.id, 'forest-001');
      expect(level.packId, 'forest');
      expect(level.index, 0);
      expect(level.title, 'Sunrise 1');
      expect(level.letters, 'AEPPL');
      expect(level.rows, 5);
      expect(level.cols, 5);
      expect(level.rewardCoins, 25);
    });

    test('parses placements correctly', () {
      expect(level.placements.length, 2);
      final apple = level.placements[0];
      expect(apple.word, 'APPLE');
      expect(apple.row, 1);
      expect(apple.col, 0);
      expect(apple.dir, WordDirection.across);
      final peal = level.placements[1];
      expect(peal.word, 'PEAL');
      expect(peal.dir, WordDirection.down);
    });

    test('derives cells with correct count', () {
      // APPLE 5 cells + PEAL 4 cells − 1 shared intersection = 8
      expect(level.cells.length, 8);
    });

    test('intersection cell has correct letter', () {
      // (1,4): APPLE[4]='E', PEAL[1]='E'
      expect(level.cells['1-4']?.letter, 'E');
    });

    test('non-intersection cells have correct letters', () {
      expect(level.cells['1-0']?.letter, 'A'); // APPLE start
      expect(level.cells['0-4']?.letter, 'P'); // PEAL start
      expect(level.cells['2-4']?.letter, 'A'); // PEAL[2]
      expect(level.cells['3-4']?.letter, 'L'); // PEAL end
    });

    test('JSON round-trip preserves equality', () {
      final roundTripped = Level.fromJson(level.toJson());
      expect(roundTripped, level);
    });
  });

  group('Level.cells with clean intersection', () {
    late Level level;

    setUp(() {
      level = Level.fromJson(
        jsonDecode(_cleanJson) as Map<String, dynamic>,
      );
    });

    test('derives correct cell count', () {
      expect(level.cells.length, 5);
    });

    test('intersection letter is correct', () {
      expect(level.cells['1-1']?.letter, 'A');
    });

    test('non-intersection letters are correct', () {
      expect(level.cells['1-0']?.letter, 'T'); // TAP start
      expect(level.cells['0-1']?.letter, 'P'); // PAT start
      expect(level.cells['2-1']?.letter, 'T'); // PAT end
    });
  });
}
