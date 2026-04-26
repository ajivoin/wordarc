import 'dart:convert';
import 'dart:io' show gzip;
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:wordarc/data/dictionary/dictionary.dart';

/// Loads the bundled ENABLE word list from assets in a background [Isolate].
///
/// Returns a fully-built [Dictionary] without blocking the UI thread.
Future<Dictionary> loadDictionary() async {
  final bytes = await rootBundle.load('assets/dictionary/enable.txt.gz');
  final compressed = bytes.buffer.asUint8List();
  return Isolate.run(() => _parseWords(compressed));
}

Dictionary _parseWords(List<int> compressed) {
  final decoded = utf8.decode(gzip.decoder.convert(compressed));
  final words = const LineSplitter().convert(decoded);
  return Dictionary.fromWords(words);
}
