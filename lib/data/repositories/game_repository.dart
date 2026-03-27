import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_config.dart';

class GameRepository {
  final http.Client _client;
  final String _baseUrl;

  GameRepository({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.vercelApiUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  Future<Map<String, dynamic>> createRoom(
      String hostName, String userId) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/rooms/create'),
      headers: _headers,
      body: jsonEncode({
        'hostName': hostName,
        'userId': userId,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create room: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> joinRoom(
      String code, String playerName, String userId) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/rooms/join'),
      headers: _headers,
      body: jsonEncode({
        'code': code,
        'playerName': playerName,
        'userId': userId,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to join room: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listRooms() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/rooms/list'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to list rooms: ${response.body}');
    }
    final body = jsonDecode(response.body);
    // API returns {"data": {"rooms": [...]}}
    final data = body is Map && body.containsKey('data') ? body['data'] : body;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    if (data is Map && data.containsKey('rooms')) {
      return (data['rooms'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> getRoomDetails(String roomId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/rooms/$roomId'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get room details: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> startGame(String roomId) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/game/start'),
      headers: _headers,
      body: jsonEncode({
        'roomId': roomId,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to start game: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> placeTile(
    String roomId,
    String playerId,
    Map<String, dynamic> tile,
    String end,
  ) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/game/place-tile'),
      headers: _headers,
      body: jsonEncode({
        'roomId': roomId,
        'playerId': playerId,
        'tile': tile,
        'end': end,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to place tile: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> passTurn(
      String roomId, String playerId) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/game/pass'),
      headers: _headers,
      body: jsonEncode({
        'roomId': roomId,
        'playerId': playerId,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to pass turn: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getGameState(
      String roomId, String playerId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/game/state?roomId=$roomId&playerId=$playerId'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get game state: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addBots(String roomId) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/game/add-bots'),
      headers: _headers,
      body: jsonEncode({
        'roomId': roomId,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add bots: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void dispose() {
    _client.close();
  }
}
