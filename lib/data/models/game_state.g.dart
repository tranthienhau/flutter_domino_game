// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameStateImpl _$$GameStateImplFromJson(Map<String, dynamic> json) =>
    _$GameStateImpl(
      roomId: json['roomId'] as String? ?? '',
      board:
          (json['board'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      currentPlayerId: json['currentPlayerId'] as String?,
      openLeft: (json['openLeft'] as num?)?.toInt() ?? -1,
      openRight: (json['openRight'] as num?)?.toInt() ?? -1,
      round: (json['round'] as num?)?.toInt() ?? 1,
      scores:
          (json['scores'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      phase: json['phase'] as String? ?? 'waiting',
      consecutivePasses: (json['consecutivePasses'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$GameStateImplToJson(_$GameStateImpl instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'board': instance.board,
      'currentPlayerId': instance.currentPlayerId,
      'openLeft': instance.openLeft,
      'openRight': instance.openRight,
      'round': instance.round,
      'scores': instance.scores,
      'phase': instance.phase,
      'consecutivePasses': instance.consecutivePasses,
    };
