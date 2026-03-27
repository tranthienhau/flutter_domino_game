import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_state.freezed.dart';
part 'game_state.g.dart';

@freezed
class GameState with _$GameState {
  const GameState._();

  const factory GameState({
    @Default('') String roomId,
    @Default([]) List<Map<String, dynamic>> board,
    String? currentPlayerId,
    @Default(-1) int openLeft,
    @Default(-1) int openRight,
    @Default(1) int round,
    @Default({}) Map<String, int> scores,
    @Default('waiting') String phase,
    @Default(0) int consecutivePasses,
  }) = _GameState;

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);

  bool get isWaiting => phase == 'waiting';
  bool get isPlaying => phase == 'playing';
  bool get isRoundOver => phase == 'round_over';
  bool get isGameOver => phase == 'game_over';
  bool get isBlocked => consecutivePasses >= 4;
}
