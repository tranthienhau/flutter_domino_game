import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/domino_tile.dart';
import '../../../data/models/game_state.dart';
import '../../providers/providers.dart';
import '../../shared/domino_tile_painter.dart';

class PlayerHandWidget extends ConsumerWidget {
  final List<DominoTile> tiles;
  final void Function(int index, DominoTile tile) onTileTap;

  const PlayerHandWidget({
    super.key,
    required this.tiles,
    required this.onTileTap,
  });

  bool _canPlayTile(DominoTile tile, GameState? gameState) {
    if (gameState == null) return false;
    if (gameState.openLeft == -1 && gameState.openRight == -1) return true;
    return tile.canPlayOn(gameState.openLeft) ||
        tile.canPlayOn(gameState.openRight);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTileIndexProvider);
    final gameState = ref.watch(gameStateProvider);
    final isMyTurn = ref.watch(isMyTurnProvider);

    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(
            color: isMyTurn
                ? const Color(0xFFFFD600).withValues(alpha: 0.5)
                : Colors.white12,
            width: isMyTurn ? 2 : 1,
          ),
        ),
      ),
      child: tiles.isEmpty
          ? const Center(
              child: Text(
                'No tiles remaining',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(tiles.length, (index) {
                  final tile = tiles[index];
                  final isSelected = selectedIndex == index;
                  final canPlay = isMyTurn && _canPlayTile(tile, gameState);
                  final isDimmed = isMyTurn && !canPlay;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.translationValues(0, isSelected ? -12.0 : 0.0, 0),
                      child: DominoTileWidget(
                        leftPips: tile.left,
                        rightPips: tile.right,
                        isHorizontal: false,
                        isSelected: isSelected,
                        isDimmed: isDimmed,
                        tileWidth: 48,
                        onTap: isMyTurn
                            ? () => onTileTap(index, tile)
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ),
    );
  }
}
