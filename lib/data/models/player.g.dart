// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerImpl _$$PlayerImplFromJson(Map<String, dynamic> json) => _$PlayerImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  team: (json['team'] as num).toInt(),
  seat: (json['seat'] as num).toInt(),
  hand:
      (json['hand'] as List<dynamic>?)
          ?.map((e) => DominoTile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isBot: (json['isBot'] ?? json['is_bot']) as bool? ?? false,
);

Map<String, dynamic> _$$PlayerImplToJson(_$PlayerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'team': instance.team,
      'seat': instance.seat,
      'hand': instance.hand,
      'isBot': instance.isBot,
    };
