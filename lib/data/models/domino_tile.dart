import 'package:freezed_annotation/freezed_annotation.dart';

part 'domino_tile.freezed.dart';
part 'domino_tile.g.dart';

@freezed
class DominoTile with _$DominoTile {
  const DominoTile._();

  const factory DominoTile({
    required int left,
    required int right,
  }) = _DominoTile;

  factory DominoTile.fromJson(Map<String, dynamic> json) =>
      _$DominoTileFromJson(json);

  bool get isDouble => left == right;
  int get pipCount => left + right;

  bool canPlayOn(int openEnd) => left == openEnd || right == openEnd;

  String get displayId => '[$left|$right]';
}
