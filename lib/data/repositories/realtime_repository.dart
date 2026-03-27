import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeRepository {
  final SupabaseClient _client;
  final List<RealtimeChannel> _channels = [];

  RealtimeRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  void subscribeToGameState(
    String roomId,
    void Function(Map<String, dynamic> payload) callback,
  ) {
    final channel = _client
        .channel('game_state_$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'game_states',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (PostgresChangePayload payload) {
            final newRecord = payload.newRecord;
            if (newRecord.isNotEmpty) {
              callback(newRecord);
            }
          },
        )
        .subscribe();

    _channels.add(channel);
  }

  void subscribeToMoves(
    String roomId,
    void Function(Map<String, dynamic> payload) callback,
  ) {
    final channel = _client
        .channel('moves_$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'moves',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (PostgresChangePayload payload) {
            final newRecord = payload.newRecord;
            if (newRecord.isNotEmpty) {
              callback(newRecord);
            }
          },
        )
        .subscribe();

    _channels.add(channel);
  }

  void subscribeToRoom(
    String roomId,
    void Function(Map<String, dynamic> payload) callback,
  ) {
    final channel = _client
        .channel('room_$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'rooms',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: roomId,
          ),
          callback: (PostgresChangePayload payload) {
            final newRecord = payload.newRecord;
            if (newRecord.isNotEmpty) {
              callback(newRecord);
            }
          },
        )
        .subscribe();

    _channels.add(channel);
  }

  Future<void> unsubscribeAll() async {
    for (final channel in _channels) {
      await _client.removeChannel(channel);
    }
    _channels.clear();
  }

  void dispose() {
    unsubscribeAll();
  }
}
