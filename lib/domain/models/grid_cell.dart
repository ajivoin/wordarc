import 'package:freezed_annotation/freezed_annotation.dart';

part 'grid_cell.freezed.dart';

@freezed
class GridCell with _$GridCell {
  const factory GridCell({
    required int row,
    required int col,
    required String letter,
  }) = _GridCell;
}
