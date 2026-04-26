import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wordarc/data/levels/level_repository.dart';
import 'package:wordarc/domain/models/level.dart';
import 'package:wordarc/domain/models/pack.dart';

part 'level_provider.g.dart';

@riverpod
LevelRepository levelRepository(LevelRepositoryRef ref) => LevelRepository();

@riverpod
Future<List<Pack>> packs(PacksRef ref) =>
    ref.watch(levelRepositoryProvider).loadPacks();

@riverpod
Future<Level> levelLoader(LevelLoaderRef ref, String levelId) async {
  final packList = await ref.watch(packsProvider.future);
  for (final pack in packList) {
    final assetPath = pack.levelAssets[levelId];
    if (assetPath != null) {
      return ref.watch(levelRepositoryProvider).loadLevel(assetPath);
    }
  }
  throw StateError('No asset path found for levelId: $levelId');
}

@riverpod
class CurrentLevel extends _$CurrentLevel {
  @override
  String? build() => null;

  void setLevel(String levelId) => state = levelId;
}
