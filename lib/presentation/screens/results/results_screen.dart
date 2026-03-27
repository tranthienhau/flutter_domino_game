import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../shared/score_counter.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  final String roomId;

  const ResultsScreen({super.key, required this.roomId});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    _checkWin();
  }

  void _checkWin() {
    final gameState = ref.read(gameStateProvider);
    final currentPlayer = ref.read(currentPlayerProvider);
    if (gameState == null || currentPlayer == null) return;

    final teamAScore = gameState.scores['teamA'] ?? 0;
    final teamBScore = gameState.scores['teamB'] ?? 0;

    final playerTeam = currentPlayer.team;
    final myTeamWon = (playerTeam == 0 && teamAScore > teamBScore) ||
        (playerTeam == 1 && teamBScore > teamAScore);

    if (myTeamWon) {
      HapticService.win();
    }
  }

  String _getWinnerText() {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return 'Game Over';

    final teamAScore = gameState.scores['teamA'] ?? 0;
    final teamBScore = gameState.scores['teamB'] ?? 0;

    if (teamAScore > teamBScore) return 'Team A Wins!';
    if (teamBScore > teamAScore) return 'Team B Wins!';
    return 'It\'s a Tie!';
  }

  Color _getWinnerColor() {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null) return AppTheme.secondary;

    final teamAScore = gameState.scores['teamA'] ?? 0;
    final teamBScore = gameState.scores['teamB'] ?? 0;

    if (teamAScore > teamBScore) return AppTheme.teamAColor;
    if (teamBScore > teamAScore) return AppTheme.teamBColor;
    return AppTheme.secondary;
  }

  bool _isMyTeamWinner() {
    final gameState = ref.read(gameStateProvider);
    final currentPlayer = ref.read(currentPlayerProvider);
    if (gameState == null || currentPlayer == null) return false;

    final teamAScore = gameState.scores['teamA'] ?? 0;
    final teamBScore = gameState.scores['teamB'] ?? 0;

    return (currentPlayer.team == 0 && teamAScore > teamBScore) ||
        (currentPlayer.team == 1 && teamBScore > teamAScore);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final players = ref.watch(playersProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Trophy/result icon
              Icon(
                _isMyTeamWinner() ? Icons.emoji_events : Icons.sports_score,
                size: 80,
                color: _getWinnerColor(),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .shimmer(
                    duration: 1200.ms,
                    color: _getWinnerColor().withValues(alpha: 0.3),
                  ),
              const SizedBox(height: 16),

              // Winner text
              Text(
                _getWinnerText(),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: _getWinnerColor(),
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms)
                  .slideY(begin: 0.3),

              if (gameState?.isBlocked == true) ...[
                const SizedBox(height: 8),
                Text(
                  'Game blocked - all players passed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ],

              const SizedBox(height: 8),
              Text(
                'Round ${gameState?.round ?? 1}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Score display
              if (gameState != null)
                Center(
                  child: ScoreBoard(scores: gameState.scores),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 500.ms),

              const SizedBox(height: 32),

              // Player breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Player Summary',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...players.asMap().entries.map((entry) {
                      final player = entry.value;
                      final teamColor = player.team == 0
                          ? AppTheme.teamAColor
                          : AppTheme.teamBColor;
                      final remainingPips = player.handPipCount;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: teamColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                player.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              player.hasEmptyHand
                                  ? 'Domino!'
                                  : '$remainingPips pips left',
                              style: TextStyle(
                                color: player.hasEmptyHand
                                    ? AppTheme.secondary
                                    : Colors.white54,
                                fontSize: 12,
                                fontWeight: player.hasEmptyHand
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(delay: (800 + entry.key * 100).ms),
                      );
                    }),
                  ],
                ),
              ),

              const Spacer(),

              // Action buttons
              ElevatedButton.icon(
                onPressed: () {
                  // Reset game state and go back to room
                  ref.read(gameStateProvider.notifier).state = null;
                  ref.read(selectedTileIndexProvider.notifier).state = null;
                  context.go('/');
                },
                icon: const Icon(Icons.replay),
                label: const Text('Play Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  // Full reset
                  ref.read(gameStateProvider.notifier).state = null;
                  ref.read(currentRoomProvider.notifier).state = null;
                  ref.read(currentPlayerProvider.notifier).state = null;
                  ref.read(playersProvider.notifier).state = [];
                  ref.read(selectedTileIndexProvider.notifier).state = null;
                  context.go('/');
                },
                child: const Text('Back to Lobby'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
