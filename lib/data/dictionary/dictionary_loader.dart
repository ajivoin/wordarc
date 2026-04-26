import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';

import 'dictionary.dart';

/// Loads the bundled ENABLE word list from assets in a background [Isolate].
///
/// Returns a fully-built [Dictionary] without blocking the UI thread.
Future<Dictionary> loadDictionary() async {
  // Read the gzipped asset bytes on the main isolate (RootIsolateToken required).
  final bytes = await rootBundle.load('assets/dictionary/enable.txt.gz');
  final compressed = bytes.buffer.asUint8List();

  // Decompress + parse in a background isolate to keep the UI thread free.
  return Isolate.run(() => _parseWords(compressed));
}

Dictionary _parseWords(List<int> compressed) {
  final decoded = utf8.decode(GZipCodec().decode(compressed));
  final words = const LineSplitter().convert(decoded);
  return Dictionary.fromWords(words);
}
