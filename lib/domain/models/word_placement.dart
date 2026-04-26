import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_placement.freezed.dart';
part 'word_placement.g.dart';

@JsonEnum(alwaysCreate: true)
enum WordDirection {
  @JsonValue('across')
  across,
  @JsonValue('down')
  down,
}

@freezed
class WordPlacement with _$WordPlacement {
  const factory WordPlacement({
    required String word,
    required int row,
    required int col,
    required WordDirection dir,
  }) = _WordPlacement;

  factory WordPlacement.fromJson(Map<String, dynamic> json) =>
      _$WordPlacementFromJson(json);
}
