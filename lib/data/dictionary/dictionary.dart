import 'dart:collection';

/// In-memory dictionary built from the ENABLE word list.
///
/// Provides O(1) word lookup and sub-anagram enumeration used by
/// [LevelGenerator] and [WordValidator].
class Dictionary {
  Dictionary._({
    required Set<String> words,
    required Map<String, List<String>> byKey,
  })  : _words = UnmodifiableSetView(words),
        _byKey = UnmodifiableMapView(byKey);

  final Set<String> _words;

  /// Words grouped by their sorted-letter key, e.g. "aelpp" → ["apple", "appel"].
  final Map<String, List<String>> _byKey;

  int get wordCount => _words.length;

  bool contains(String word) => _words.contains(word.toLowerCase());

  /// Returns all words that can be formed from a subset of [letters].
  List<String> subAnagramsOf(String letters) {
    final sorted = (letters.toLowerCase().split('')..sort()).join();
    final results = <String>[];
    for (var i = 0; i < sorted.length; i++) {
      for (var j = i + 3; j <= sorted.length; j++) {
        final sub = sorted.substring(i, j);
        final candidates = _byKey[sub];
        if (candidates != null) results.addAll(candidates);
      }
    }
    return results.toSet().toList();
  }

  factory Dictionary.fromWords(Iterable<String> words) {
    final wordSet = <String>{};
    final byKey = <String, List<String>>{};

    for (final w in words) {
      final lower = w.trim().toLowerCase();
      if (lower.isEmpty) continue;
      wordSet.add(lower);
      final key = (lower.split('')..sort()).join();
      byKey.putIfAbsent(key, () => []).add(lower);
    }

    return Dictionary._(words: wordSet, byKey: byKey);
  }
}
