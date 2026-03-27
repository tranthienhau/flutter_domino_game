import 'package:uuid/uuid.dart';
import '../../data/models/domino_tile.dart';
import '../../data/models/game_state.dart';
import '../../data/models/player.dart';
import '../../data/models/room.dart';
import '../../data/repositories/game_repository.dart';
import '../../data/repositories/realtime_repository.dart';

class GameService {
  final GameRepository _gameRepository;
  final RealtimeRepository _realtimeRepository;
  final _uuid = const Uuid();

  String? _userId;
  String get userId => _userId ??= _uuid.v4();

  /// The Supabase player ID assigned when creating/joining a room.
  String? _currentPlayerId;
  String? get currentPlayerId => _currentPlayerId;

  GameService({
    GameRepository? gameRepository,
    RealtimeRepository? realtimeRepository,
  })  : _gameRepository = gameRepository ?? GameRepository(),
        _realtimeRepository = realtimeRepository ?? RealtimeRepository();

  Future<Room> createAndJoinRoom(String playerName) async {
    final result = await _gameRepository.createRoom(playerName, userId);
    final data = _unwrap(result);
    final roomJson = data['room'] as Map<String, dynamic>;
    final playerJson = data['player'] as Map<String, dynamic>;
    _currentPlayerId = playerJson['id'] as String;
    return Room.fromJson({...roomJson, 'players': [playerJson]});
  }

  Future<Room> joinExistingRoom(String code, String playerName) async {
    final result = await _gameRepository.joinRoom(code, playerName, userId);
    final data = _unwrap(result);
    final roomJson = data['room'] as Map<String, dynamic>;
    final playerJson = data['player'] as Map<String, dynamic>;
    _currentPlayerId = playerJson['id'] as String;
    // Room from join includes players list
    if (roomJson.containsKey('players')) {
      return Room.fromJson(roomJson);
    }
    return Room.fromJson({...roomJson, 'players': [playerJson]});
  }

  Future<List<Room>> listRooms() async {
    final results = await _gameRepository.listRooms();
    return results.map((json) => Room.fromJson(json)).toList();
  }

  Future<Room> getRoomDetails(String roomId) async {
    final result = await _gameRepository.getRoomDetails(roomId);
    final data = _unwrap(result);
    return Room.fromJson(data);
  }

  Future<List<Player>> addBots(String roomId) async {
    final result = await _gameRepository.addBots(roomId);
    final data = _unwrap(result);
    final playersList = data['players'] as List;
    return playersList.map((p) => Player.fromJson(p as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> startGame(String roomId) async {
    final result = await _gameRepository.startGame(roomId);
    return _unwrap(result);
  }

  /// Unwrap the `{"data": ...}` envelope from API responses.
  Map<String, dynamic> _unwrap(Map<String, dynamic> response) {
    if (response.containsKey('data')) {
      return response['data'] as Map<String, dynamic>;
    }
    return response;
  }

  Future<GameState> playTile(
    String roomId,
    String playerId,
    DominoTile tile,
    String end,
  ) async {
    final result = await _gameRepository.placeTile(
      roomId,
      playerId,
      tile.toJson(),
      end,
    );
    final data = _unwrap(result);
    return GameState.fromJson(data);
  }

  Future<GameState> pass(String roomId, String playerId) async {
    final result = await _gameRepository.passTurn(roomId, playerId);
    final data = _unwrap(result);
    return GameState.fromJson(data);
  }

  Future<GameState> getGameState(String roomId, String playerId) async {
    final result = await _gameRepository.getGameState(roomId, playerId);
    final data = _unwrap(result);
    // Extract players with hands from the response
    _lastPlayerHand = null;
    _lastPlayers = null;
    final playersList = data['players'] as List?;
    if (playersList != null) {
      final parsedPlayers = <Player>[];
      for (final p in playersList) {
        final pm = p as Map<String, dynamic>;
        if (pm['id'] == playerId && pm.containsKey('hand')) {
          _lastPlayerHand = (pm['hand'] as List)
              .map((t) => DominoTile.fromJson(t as Map<String, dynamic>))
              .toList();
          parsedPlayers.add(Player(
            id: pm['id'] as String,
            name: pm['name'] as String,
            team: (pm['team'] as num).toInt(),
            seat: (pm['seat'] as num).toInt(),
            hand: _lastPlayerHand!,
            isBot: (pm['isBot'] ?? pm['is_bot'] ?? false) as bool,
          ));
        } else {
          // Opponent - create placeholder hand based on handCount
          final handCount = (pm['handCount'] as num?)?.toInt() ?? 0;
          final fakeHand = List.generate(handCount, (_) => const DominoTile(left: 0, right: 0));
          parsedPlayers.add(Player(
            id: pm['id'] as String,
            name: pm['name'] as String,
            team: (pm['team'] as num).toInt(),
            seat: (pm['seat'] as num).toInt(),
            hand: fakeHand,
            isBot: (pm['isBot'] ?? pm['is_bot'] ?? false) as bool,
          ));
        }
      }
      _lastPlayers = parsedPlayers;
    }
    return GameState.fromJson(data);
  }

  List<DominoTile>? _lastPlayerHand;
  List<DominoTile>? get lastPlayerHand => _lastPlayerHand;

  List<Player>? _lastPlayers;
  List<Player>? get lastPlayers => _lastPlayers;

  Player? findCurrentPlayer(List<Player> players) {
    if (_currentPlayerId == null) return null;
    try {
      return players.firstWhere((p) => p.id == _currentPlayerId);
    } catch (_) {
      return null;
    }
  }

  void listenToGameUpdates(
    String roomId,
    void Function(Map<String, dynamic> data) onUpdate,
  ) {
    _realtimeRepository.subscribeToGameState(roomId, onUpdate);
  }

  void listenToMoves(
    String roomId,
    void Function(Map<String, dynamic> data) onMove,
  ) {
    _realtimeRepository.subscribeToMoves(roomId, onMove);
  }

  void listenToRoom(
    String roomId,
    void Function(Map<String, dynamic> data) onUpdate,
  ) {
    _realtimeRepository.subscribeToRoom(roomId, onUpdate);
  }

  void dispose() {
    _realtimeRepository.dispose();
    _gameRepository.dispose();
  }
}
