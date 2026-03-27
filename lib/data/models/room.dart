import 'package:freezed_annotation/freezed_annotation.dart';
import 'player.dart';

part 'room.freezed.dart';
part 'room.g.dart';

@freezed
class Room with _$Room {
  const Room._();

  const factory Room({
    required String id,
    required String code,
    @Default('waiting') String status,
    @Default([]) List<Player> players,
    DateTime? createdAt,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  bool get isFull => players.length >= 4;
  bool get canStart => players.length == 4 && status == 'waiting';
  bool get isActive => status == 'active';
}
