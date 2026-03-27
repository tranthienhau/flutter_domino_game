import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/game_state.dart';
import '../../data/models/player.dart';
import '../../data/models/room.dart';
import '../../domain/services/game_service.dart';

final gameServiceProvider = Provider<GameService>((ref) {
  final service = GameService();
  ref.onDispose(() => service.dispose());
  return service;
});

final currentRoomProvider = StateProvider<Room?>((ref) => null);

final gameStateProvider = StateProvider<GameState?>((ref) => null);

final currentPlayerProvider = StateProvider<Player?>((ref) => null);

final playersProvider = StateProvider<List<Player>>((ref) => []);

final playerNameProvider = StateProvider<String>((ref) => '');

final selectedTileIndexProvider = StateProvider<int?>((ref) => null);

final isLoadingProvider = StateProvider<bool>((ref) => false);

final errorMessageProvider = StateProvider<String?>((ref) => null);

final isMyTurnProvider = Provider<bool>((ref) {
  final gameState = ref.watch(gameStateProvider);
  final currentPlayer = ref.watch(currentPlayerProvider);
  if (gameState == null || currentPlayer == null) return false;
  return gameState.currentPlayerId == currentPlayer.id;
});

final canPassProvider = Provider<bool>((ref) {
  final isMyTurn = ref.watch(isMyTurnProvider);
  final gameState = ref.watch(gameStateProvider);
  final currentPlayer = ref.watch(currentPlayerProvider);
  if (!isMyTurn || gameState == null || currentPlayer == null) return false;

  // Can pass if no valid moves
  for (final tile in currentPlayer.hand) {
    if (gameState.openLeft == -1 && gameState.openRight == -1) {
      return false; // First move, must play
    }
    if (tile.canPlayOn(gameState.openLeft) ||
        tile.canPlayOn(gameState.openRight)) {
      return false; // Has a valid move
    }
  }
  return true;
});
