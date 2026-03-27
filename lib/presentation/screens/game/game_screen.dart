import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/domino_tile.dart';
import '../../../data/models/game_state.dart';
import '../../../data/models/player.dart';
import '../../providers/providers.dart';
import '../../shared/score_counter.dart';
import '../../shared/turn_indicator.dart';
import 'board_widget.dart';
import 'opponent_hand_widget.dart';
import 'player_hand_widget.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String roomId;

  const GameScreen({super.key, required this.roomId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _initialized = false;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  Future<void> _initGame() async {
    if (_initialized) return;
    _initialized = true;

    final gameService = ref.read(gameServiceProvider);
    final currentPlayer = ref.read(currentPlayerProvider);

    if (currentPlayer == null) return;

    // Subscribe to realtime updates - use as trigger to refresh full state
    // (Realtime sends snake_case DB keys, but our models expect camelCase)
    gameService.listenToGameUpdates(widget.roomId, (data) {
      if (!mounted || _refreshing) return;
      _refreshing = true;
      _refreshGameState().then((_) {
        _refreshing = false;
        if (!mounted) return;
        final gs = ref.read(gameStateProvider);
        if (gs != null && (gs.isGameOver || gs.isRoundOver)) {
          context.go('/results/${widget.roomId}');
        }
        final me = ref.read(currentPlayerProvider);
        if (gs != null && me != null && gs.currentPlayerId == me.id) {
          HapticService.yourTurn();
        }
      }).catchError((_) {
        _refreshing = false;
      });
    });

    // Fetch initial game state
    try {
      final state = await gameService.getGameState(
        widget.roomId,
        currentPlayer.id,
      );
      if (mounted) {
        ref.read(gameStateProvider.notifier).state = state;

        // Update player hand from API response
        final hand = gameService.lastPlayerHand;
        if (hand != null && hand.isNotEmpty) {
          ref.read(currentPlayerProvider.notifier).state =
              currentPlayer.copyWith(hand: hand);
        }
        // Update all players (opponents get handCount)
        final allPlayers = gameService.lastPlayers;
        if (allPlayers != null) {
          ref.read(playersProvider.notifier).state = allPlayers;
        }
      }
    } catch (e) {
      if (mounted) {
        ref.read(errorMessageProvider.notifier).state = e.toString();
      }
    }
  }

  Future<void> _onTileTap(int index, DominoTile tile) async {
    debugPrint('Tile tapped: $index - [${tile.left}|${tile.right}]');
    final gameState = ref.read(gameStateProvider);
    final currentPlayer = ref.read(currentPlayerProvider);
    final isMyTurn = ref.read(isMyTurnProvider);

    debugPrint('isMyTurn: $isMyTurn, currentPlayerId: ${gameState?.currentPlayerId}, myId: ${currentPlayer?.id}');
    debugPrint('openLeft: ${gameState?.openLeft}, openRight: ${gameState?.openRight}, boardLen: ${gameState?.board.length}');
    debugPrint('My hand: ${currentPlayer?.hand.map((t) => "[${t.left}|${t.right}]").join(", ")}');
    if (!isMyTurn || gameState == null || currentPlayer == null) return;

    final selectedIndex = ref.read(selectedTileIndexProvider);

    // If tapping the same tile, deselect
    if (selectedIndex == index) {
      ref.read(selectedTileIndexProvider.notifier).state = null;
      return;
    }

    // Select the tile
    ref.read(selectedTileIndexProvider.notifier).state = index;

    // If board is empty (first move), auto-play
    if (gameState.openLeft == -1 && gameState.openRight == -1) {
      debugPrint('Board empty, auto-playing on right');
      await _playTile(tile, 'right');
      return;
    }

    // Check which ends the tile can be played on
    final canLeft = tile.canPlayOn(gameState.openLeft);
    final canRight = tile.canPlayOn(gameState.openRight);
    debugPrint('canLeft: $canLeft, canRight: $canRight');

    // If only one valid end, auto-play
    if (canLeft && !canRight) {
      await _playTile(tile, 'left');
    } else if (!canLeft && canRight) {
      await _playTile(tile, 'right');
    }
    // If both ends are valid, user must tap the end indicator on the board
  }

  Future<void> _onEndTap(String end) async {
    final selectedIndex = ref.read(selectedTileIndexProvider);
    final currentPlayer = ref.read(currentPlayerProvider);
    if (selectedIndex == null || currentPlayer == null) return;

    final tile = currentPlayer.hand[selectedIndex];
    await _playTile(tile, end);
  }

  Future<void> _playTile(DominoTile tile, String end) async {
    final gameService = ref.read(gameServiceProvider);
    final currentPlayer = ref.read(currentPlayerProvider);
    if (currentPlayer == null) return;

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(selectedTileIndexProvider.notifier).state = null;

    try {
      debugPrint('Playing tile [${tile.left}|${tile.right}] on $end, playerId: ${currentPlayer.id}');
      await gameService.playTile(
        widget.roomId,
        currentPlayer.id,
        tile,
        end,
      );
      debugPrint('Tile placed successfully, refreshing state...');

      // Refresh full state (bots may have played)
      await _refreshGameState();
      if (mounted) {
        HapticService.tilePlaced();
        final gs = ref.read(gameStateProvider);
        if (gs != null && (gs.isGameOver || gs.isRoundOver)) {
          context.go('/results/${widget.roomId}');
        }
      }
    } catch (e) {
      debugPrint('Play tile error: $e');
      if (mounted) {
        HapticService.invalidMove();
        // Refresh state to get back in sync
        await _refreshGameState();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'.replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _refreshGameState() async {
    final gameService = ref.read(gameServiceProvider);
    final currentPlayer = ref.read(currentPlayerProvider);
    if (currentPlayer == null) return;

    try {
      final refreshed = await gameService.getGameState(
        widget.roomId,
        currentPlayer.id,
      );
      if (mounted) {
        ref.read(gameStateProvider.notifier).state = refreshed;

        final hand = gameService.lastPlayerHand;
        if (hand != null) {
          ref.read(currentPlayerProvider.notifier).state =
              currentPlayer.copyWith(hand: hand);
        }
        final allPlayers = gameService.lastPlayers;
        if (allPlayers != null) {
          ref.read(playersProvider.notifier).state = allPlayers;
        }
      }
    } catch (e) {
      debugPrint('Refresh state error: $e');
    }
  }

  Future<void> _passTurn() async {
    final gameService = ref.read(gameServiceProvider);
    final currentPlayer = ref.read(currentPlayerProvider);
    if (currentPlayer == null) return;

    ref.read(isLoadingProvider.notifier).state = true;

    try {
      final newState = await gameService.pass(
        widget.roomId,
        currentPlayer.id,
      );
      if (mounted) {
        ref.read(gameStateProvider.notifier).state = newState;
        HapticService.passTurn();

        if (newState.isGameOver || newState.isRoundOver) {
          context.go('/results/${widget.roomId}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pass: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  Player? _getOpponentBySeat(List<Player> players, Player? me, int seatOffset) {
    if (me == null || players.isEmpty) return null;
    final targetSeat = (me.seat + seatOffset) % 4;
    try {
      return players.firstWhere((p) => p.seat == targetSeat);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final currentPlayer = ref.watch(currentPlayerProvider);
    final players = ref.watch(playersProvider);
    final isMyTurn = ref.watch(isMyTurnProvider);
    final canPass = ref.watch(canPassProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final selectedIndex = ref.watch(selectedTileIndexProvider);

    final opponentAcross = _getOpponentBySeat(players, currentPlayer, 2);
    final opponentLeft = _getOpponentBySeat(players, currentPlayer, 3);
    final opponentRight = _getOpponentBySeat(players, currentPlayer, 1);

    DominoTile? selectedTile;
    if (selectedIndex != null &&
        currentPlayer != null &&
        selectedIndex < currentPlayer.hand.length) {
      selectedTile = currentPlayer.hand[selectedIndex];
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with scores and round info
            _buildTopBar(gameState),
            // Game area
            Expanded(
              child: Stack(
                children: [
                  // Board in center
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: BoardWidget(
                        boardTiles: gameState?.board ?? [],
                        openLeft: gameState?.openLeft ?? -1,
                        openRight: gameState?.openRight ?? -1,
                        isMyTurn: isMyTurn,
                        selectedTile: selectedTile,
                        onEndTap: _onEndTap,
                      ),
                    ),
                  ),
                  // Opponent across (top)
                  if (opponentAcross != null)
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: OpponentHandWidget(
                          playerName: opponentAcross.name,
                          tileCount: opponentAcross.hand.length,
                          team: opponentAcross.team,
                          isCurrentTurn:
                              gameState?.currentPlayerId == opponentAcross.id,
                          position: OpponentPosition.top,
                        ),
                      ),
                    ),
                  // Opponent left
                  if (opponentLeft != null)
                    Positioned(
                      left: 4,
                      top: 80,
                      bottom: 80,
                      child: Center(
                        child: OpponentHandWidget(
                          playerName: opponentLeft.name,
                          tileCount: opponentLeft.hand.length,
                          team: opponentLeft.team,
                          isCurrentTurn:
                              gameState?.currentPlayerId == opponentLeft.id,
                          position: OpponentPosition.left,
                        ),
                      ),
                    ),
                  // Opponent right
                  if (opponentRight != null)
                    Positioned(
                      right: 4,
                      top: 80,
                      bottom: 80,
                      child: Center(
                        child: OpponentHandWidget(
                          playerName: opponentRight.name,
                          tileCount: opponentRight.hand.length,
                          team: opponentRight.team,
                          isCurrentTurn:
                              gameState?.currentPlayerId == opponentRight.id,
                          position: OpponentPosition.right,
                        ),
                      ),
                    ),
                  // Turn indicator
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TurnIndicator(
                            playerName: isMyTurn
                                ? 'Your Turn!'
                                : '${_getCurrentPlayerName(gameState, players)}\'s Turn',
                            isActive: isMyTurn,
                          ),
                          if (canPass) ...[
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: isLoading ? null : _passTurn,
                              icon: const Icon(Icons.skip_next, size: 18),
                              label: const Text('Pass'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.error,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Player hand at bottom
            PlayerHandWidget(
              tiles: currentPlayer?.hand ?? [],
              onTileTap: _onTileTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(GameState? gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.8),
        border: const Border(
          bottom: BorderSide(color: Colors.white12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Leave Game?'),
                  content: const Text(
                      'Are you sure you want to leave the game?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.go('/');
                      },
                      child: const Text('Leave'),
                    ),
                  ],
                ),
              );
            },
          ),
          // Scores
          if (gameState != null) ScoreBoard(scores: gameState.scores),
          // Round
          Text(
            'Round ${gameState?.round ?? 1}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentPlayerName(GameState? state, List<Player> players) {
    if (state?.currentPlayerId == null) return 'Waiting';
    try {
      return players
          .firstWhere((p) => p.id == state!.currentPlayerId)
          .name;
    } catch (_) {
      return 'Opponent';
    }
  }
}
