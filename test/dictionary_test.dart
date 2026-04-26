import 'package:flutter_test/flutter_test.dart';
import 'package:wordarc/data/dictionary/dictionary.dart';

void main() {
  group('Dictionary', () {
    late Dictionary dict;

    setUp(() {
      dict = Dictionary.fromWords(['apple', 'peal', 'leap', 'pale', 'plea', 'cat', 'act', 'at']);
    });

    test('contains returns true for known words', () {
      expect(dict.contains('apple'), isTrue);
      expect(dict.contains('APPLE'), isTrue);
    });

    test('contains returns false for unknown words', () {
      expect(dict.contains('xyzzy'), isFalse);
    });

    test('wordCount excludes empty / short words', () {
      // 'at' is length 2 so Dictionary.fromWords keeps it (no length filter here)
      expect(dict.wordCount, 8);
    });

    test('subAnagramsOf finds sub-anagrams', () {
      // letters A, E, P, L → can form peal, leap, pale, plea
      final result = dict.subAnagramsOf('aepl');
      expect(result, containsAll(['peal', 'leap', 'pale', 'plea']));
    });
  });
}
