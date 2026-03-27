import 'package:freezed_annotation/freezed_annotation.dart';
import 'domino_tile.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
class Player with _$Player {
  const Player._();

  const factory Player({
    required String id,
    required String name,
    required int team,
    required int seat,
    @Default([]) List<DominoTile> hand,
    @Default(false) bool isBot,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) =>
      _$PlayerFromJson(json);

  String get teamName => team == 1 ? 'Team A' : 'Team B';
  bool get hasEmptyHand => hand.isEmpty;
  int get handPipCount => hand.fold(0, (sum, tile) => sum + tile.pipCount);
}
