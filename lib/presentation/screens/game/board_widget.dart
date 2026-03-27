import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/domino_tile.dart';
import '../../shared/domino_tile_painter.dart';
import '../../shared/tile_placement_animation.dart';

class BoardWidget extends StatelessWidget {
  final List<Map<String, dynamic>> boardTiles;
  final int openLeft;
  final int openRight;
  final bool isMyTurn;
  final DominoTile? selectedTile;
  final void Function(String end)? onEndTap;

  const BoardWidget({
    super.key,
    required this.boardTiles,
    required this.openLeft,
    required this.openRight,
    this.isMyTurn = false,
    this.selectedTile,
    this.onEndTap,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.3,
      maxScale: 3.0,
      boundaryMargin: const EdgeInsets.all(300),
      child: Center(
        child: boardTiles.isEmpty
            ? _buildEmptyBoard()
            : _buildBoardChain(),
      ),
    );
  }

  Widget _buildEmptyBoard() {
    return Container(
      width: 200,
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white12,
          width: 1,
        ),
      ),
      child: const Center(
        child: Text(
          'Play a tile to start',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBoardChain() {
    // Build the chain of tiles horizontally with wrapping
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 2,
      runSpacing: 2,
      children: [
        // Left end indicator (clickable if tile is selected)
        if (isMyTurn && selectedTile != null && _canPlayOnLeft())
          _buildEndIndicator('left'),
        // Board tiles
        ...boardTiles.asMap().entries.map((entry) {
          final index = entry.key;
          final tileData = entry.value;
          // Board tiles are nested: {tile: {left, right}, end, flipped}
          final tile = tileData['tile'] as Map<String, dynamic>?;
          final left = (tile?['left'] as num?)?.toInt() ?? 0;
          final right = (tile?['right'] as num?)?.toInt() ?? 0;
          final flipped = tileData['flipped'] as bool? ?? false;
          final displayLeft = flipped ? right : left;
          final displayRight = flipped ? left : right;
          final isLastPlaced = index == boardTiles.length - 1;

          return TilePlacementAnimation(
            animate: isLastPlaced,
            child: DominoTileWidget(
              leftPips: displayLeft,
              rightPips: displayRight,
              isHorizontal: true,
              tileWidth: 30,
            ),
          );
        }),
        // Right end indicator (clickable if tile is selected)
        if (isMyTurn && selectedTile != null && _canPlayOnRight())
          _buildEndIndicator('right'),
      ],
    );
  }

  bool _canPlayOnLeft() {
    if (selectedTile == null || openLeft == -1) return false;
    return selectedTile!.canPlayOn(openLeft);
  }

  bool _canPlayOnRight() {
    if (selectedTile == null || openRight == -1) return false;
    return selectedTile!.canPlayOn(openRight);
  }

  Widget _buildEndIndicator(String end) {
    return GestureDetector(
      onTap: () => onEndTap?.call(end),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.secondary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.secondary,
            width: 2,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: AppTheme.secondary,
            size: 20,
          ),
        ),
      ),
    );
  }
}
