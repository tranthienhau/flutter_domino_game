// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'domino_tile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DominoTile _$DominoTileFromJson(Map<String, dynamic> json) {
  return _DominoTile.fromJson(json);
}

/// @nodoc
mixin _$DominoTile {
  int get left => throw _privateConstructorUsedError;
  int get right => throw _privateConstructorUsedError;

  /// Serializes this DominoTile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DominoTile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DominoTileCopyWith<DominoTile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DominoTileCopyWith<$Res> {
  factory $DominoTileCopyWith(
    DominoTile value,
    $Res Function(DominoTile) then,
  ) = _$DominoTileCopyWithImpl<$Res, DominoTile>;
  @useResult
  $Res call({int left, int right});
}

/// @nodoc
class _$DominoTileCopyWithImpl<$Res, $Val extends DominoTile>
    implements $DominoTileCopyWith<$Res> {
  _$DominoTileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DominoTile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? left = null, Object? right = null}) {
    return _then(
      _value.copyWith(
            left: null == left
                ? _value.left
                : left // ignore: cast_nullable_to_non_nullable
                      as int,
            right: null == right
                ? _value.right
                : right // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DominoTileImplCopyWith<$Res>
    implements $DominoTileCopyWith<$Res> {
  factory _$$DominoTileImplCopyWith(
    _$DominoTileImpl value,
    $Res Function(_$DominoTileImpl) then,
  ) = __$$DominoTileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int left, int right});
}

/// @nodoc
class __$$DominoTileImplCopyWithImpl<$Res>
    extends _$DominoTileCopyWithImpl<$Res, _$DominoTileImpl>
    implements _$$DominoTileImplCopyWith<$Res> {
  __$$DominoTileImplCopyWithImpl(
    _$DominoTileImpl _value,
    $Res Function(_$DominoTileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DominoTile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? left = null, Object? right = null}) {
    return _then(
      _$DominoTileImpl(
        left: null == left
            ? _value.left
            : left // ignore: cast_nullable_to_non_nullable
                  as int,
        right: null == right
            ? _value.right
            : right // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DominoTileImpl extends _DominoTile {
  const _$DominoTileImpl({required this.left, required this.right}) : super._();

  factory _$DominoTileImpl.fromJson(Map<String, dynamic> json) =>
      _$$DominoTileImplFromJson(json);

  @override
  final int left;
  @override
  final int right;

  @override
  String toString() {
    return 'DominoTile(left: $left, right: $right)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DominoTileImpl &&
            (identical(other.left, left) || other.left == left) &&
            (identical(other.right, right) || other.right == right));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, left, right);

  /// Create a copy of DominoTile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DominoTileImplCopyWith<_$DominoTileImpl> get copyWith =>
      __$$DominoTileImplCopyWithImpl<_$DominoTileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DominoTileImplToJson(this);
  }
}

abstract class _DominoTile extends DominoTile {
  const factory _DominoTile({
    required final int left,
    required final int right,
  }) = _$DominoTileImpl;
  const _DominoTile._() : super._();

  factory _DominoTile.fromJson(Map<String, dynamic> json) =
      _$DominoTileImpl.fromJson;

  @override
  int get left;
  @override
  int get right;

  /// Create a copy of DominoTile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DominoTileImplCopyWith<_$DominoTileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
