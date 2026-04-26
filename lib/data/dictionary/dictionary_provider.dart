import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wordarc/data/dictionary/dictionary.dart';
import 'package:wordarc/data/dictionary/dictionary_loader.dart';

part 'dictionary_provider.g.dart';

@riverpod
Future<Dictionary> dictionary(DictionaryRef ref) => loadDictionary();
