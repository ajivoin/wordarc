import 'package:freezed_annotation/freezed_annotation.dart';

part 'pack.freezed.dart';
part 'pack.g.dart';

@freezed
class Pack with _$Pack {
  const factory Pack({
    required String id,
    required String title,
    required String themeKey,
    required String musicKey,
    required List<String> levelIds,
    required Map<String, String> levelAssets,
  }) = _Pack;

  factory Pack.fromJson(Map<String, dynamic> json) => _$PackFromJson(json);
}
