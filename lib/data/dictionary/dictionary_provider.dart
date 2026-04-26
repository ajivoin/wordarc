import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dictionary.dart';
import 'dictionary_loader.dart';

part 'dictionary_provider.g.dart';

@riverpod
Future<Dictionary> dictionary(DictionaryRef ref) => loadDictionary();
