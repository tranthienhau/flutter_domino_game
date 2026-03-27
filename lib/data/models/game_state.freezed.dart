// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameState _$GameStateFromJson(Map<String, dynamic> json) {
  return _GameState.fromJson(json);
}

/// @nodoc
mixin _$GameState {
  String get roomId => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get board => throw _privateConstructorUsedError;
  String? get currentPlayerId => throw _privateConstructorUsedError;
  int get openLeft => throw _privateConstructorUsedError;
  int get openRight => throw _privateConstructorUsedError;
  int get round => throw _privateConstructorUsedError;
  Map<String, int> get scores => throw _privateConstructorUsedError;
  String get phase => throw _privateConstructorUsedError;
  int get consecutivePasses => throw _privateConstructorUsedError;

  /// Serializes this GameState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameStateCopyWith<GameState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameStateCopyWith<$Res> {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) then) =
      _$GameStateCopyWithImpl<$Res, GameState>;
  @useResult
  $Res call({
    String roomId,
    List<Map<String, dynamic>> board,
    String? currentPlayerId,
    int openLeft,
    int openRight,
    int round,
    Map<String, int> scores,
    String phase,
    int consecutivePasses,
  });
}

/// @nodoc
class _$GameStateCopyWithImpl<$Res, $Val extends GameState>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? board = null,
    Object? currentPlayerId = freezed,
    Object? openLeft = null,
    Object? openRight = null,
    Object? round = null,
    Object? scores = null,
    Object? phase = null,
    Object? consecutivePasses = null,
  }) {
    return _then(
      _value.copyWith(
            roomId: null == roomId
                ? _value.roomId
                : roomId // ignore: cast_nullable_to_non_nullable
                      as String,
            board: null == board
                ? _value.board
                : board // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            currentPlayerId: freezed == currentPlayerId
                ? _value.currentPlayerId
                : currentPlayerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            openLeft: null == openLeft
                ? _value.openLeft
                : openLeft // ignore: cast_nullable_to_non_nullable
                      as int,
            openRight: null == openRight
                ? _value.openRight
                : openRight // ignore: cast_nullable_to_non_nullable
                      as int,
            round: null == round
                ? _value.round
                : round // ignore: cast_nullable_to_non_nullable
                      as int,
            scores: null == scores
                ? _value.scores
                : scores // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            phase: null == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                      as String,
            consecutivePasses: null == consecutivePasses
                ? _value.consecutivePasses
                : consecutivePasses // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameStateImplCopyWith<$Res>
    implements $GameStateCopyWith<$Res> {
  factory _$$GameStateImplCopyWith(
    _$GameStateImpl value,
    $Res Function(_$GameStateImpl) then,
  ) = __$$GameStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String roomId,
    List<Map<String, dynamic>> board,
    String? currentPlayerId,
    int openLeft,
    int openRight,
    int round,
    Map<String, int> scores,
    String phase,
    int consecutivePasses,
  });
}

/// @nodoc
class __$$GameStateImplCopyWithImpl<$Res>
    extends _$GameStateCopyWithImpl<$Res, _$GameStateImpl>
    implements _$$GameStateImplCopyWith<$Res> {
  __$$GameStateImplCopyWithImpl(
    _$GameStateImpl _value,
    $Res Function(_$GameStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? board = null,
    Object? currentPlayerId = freezed,
    Object? openLeft = null,
    Object? openRight = null,
    Object? round = null,
    Object? scores = null,
    Object? phase = null,
    Object? consecutivePasses = null,
  }) {
    return _then(
      _$GameStateImpl(
        roomId: null == roomId
            ? _value.roomId
            : roomId // ignore: cast_nullable_to_non_nullable
                  as String,
        board: null == board
            ? _value._board
            : board // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        currentPlayerId: freezed == currentPlayerId
            ? _value.currentPlayerId
            : currentPlayerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        openLeft: null == openLeft
            ? _value.openLeft
            : openLeft // ignore: cast_nullable_to_non_nullable
                  as int,
        openRight: null == openRight
            ? _value.openRight
            : openRight // ignore: cast_nullable_to_non_nullable
                  as int,
        round: null == round
            ? _value.round
            : round // ignore: cast_nullable_to_non_nullable
                  as int,
        scores: null == scores
            ? _value._scores
            : scores // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        phase: null == phase
            ? _value.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as String,
        consecutivePasses: null == consecutivePasses
            ? _value.consecutivePasses
            : consecutivePasses // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameStateImpl extends _GameState {
  const _$GameStateImpl({
    this.roomId = '',
    final List<Map<String, dynamic>> board = const [],
    this.currentPlayerId,
    this.openLeft = -1,
    this.openRight = -1,
    this.round = 1,
    final Map<String, int> scores = const {},
    this.phase = 'waiting',
    this.consecutivePasses = 0,
  }) : _board = board,
       _scores = scores,
       super._();

  factory _$GameStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameStateImplFromJson(json);

  @override
  @JsonKey()
  final String roomId;
  final List<Map<String, dynamic>> _board;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get board {
    if (_board is EqualUnmodifiableListView) return _board;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_board);
  }

  @override
  final String? currentPlayerId;
  @override
  @JsonKey()
  final int openLeft;
  @override
  @JsonKey()
  final int openRight;
  @override
  @JsonKey()
  final int round;
  final Map<String, int> _scores;
  @override
  @JsonKey()
  Map<String, int> get scores {
    if (_scores is EqualUnmodifiableMapView) return _scores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_scores);
  }

  @override
  @JsonKey()
  final String phase;
  @override
  @JsonKey()
  final int consecutivePasses;

  @override
  String toString() {
    return 'GameState(roomId: $roomId, board: $board, currentPlayerId: $currentPlayerId, openLeft: $openLeft, openRight: $openRight, round: $round, scores: $scores, phase: $phase, consecutivePasses: $consecutivePasses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameStateImpl &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            const DeepCollectionEquality().equals(other._board, _board) &&
            (identical(other.currentPlayerId, currentPlayerId) ||
                other.currentPlayerId == currentPlayerId) &&
            (identical(other.openLeft, openLeft) ||
                other.openLeft == openLeft) &&
            (identical(other.openRight, openRight) ||
                other.openRight == openRight) &&
            (identical(other.round, round) || other.round == round) &&
            const DeepCollectionEquality().equals(other._scores, _scores) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.consecutivePasses, consecutivePasses) ||
                other.consecutivePasses == consecutivePasses));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    roomId,
    const DeepCollectionEquality().hash(_board),
    currentPlayerId,
    openLeft,
    openRight,
    round,
    const DeepCollectionEquality().hash(_scores),
    phase,
    consecutivePasses,
  );

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      __$$GameStateImplCopyWithImpl<_$GameStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameStateImplToJson(this);
  }
}

abstract class _GameState extends GameState {
  const factory _GameState({
    final String roomId,
    final List<Map<String, dynamic>> board,
    final String? currentPlayerId,
    final int openLeft,
    final int openRight,
    final int round,
    final Map<String, int> scores,
    final String phase,
    final int consecutivePasses,
  }) = _$GameStateImpl;
  const _GameState._() : super._();

  factory _GameState.fromJson(Map<String, dynamic> json) =
      _$GameStateImpl.fromJson;

  @override
  String get roomId;
  @override
  List<Map<String, dynamic>> get board;
  @override
  String? get currentPlayerId;
  @override
  int get openLeft;
  @override
  int get openRight;
  @override
  int get round;
  @override
  Map<String, int> get scores;
  @override
  String get phase;
  @override
  int get consecutivePasses;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
