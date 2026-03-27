import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/domino_tile_painter.dart';

enum OpponentPosition { top, left, right }

class OpponentHandWidget extends StatelessWidget {
  final String playerName;
  final int tileCount;
  final int team;
  final bool isCurrentTurn;
  final OpponentPosition position;

  const OpponentHandWidget({
    super.key,
    required this.playerName,
    required this.tileCount,
    required this.team,
    this.isCurrentTurn = false,
    this.position = OpponentPosition.top,
  });

  Color get teamColor => team == 0 ? AppTheme.teamAColor : AppTheme.teamBColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? AppTheme.secondary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentTurn
            ? Border.all(
                color: AppTheme.secondary.withValues(alpha: 0.4),
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player name and team indicator
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: teamColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                playerName,
                style: TextStyle(
                  color: isCurrentTurn ? AppTheme.secondary : Colors.white70,
                  fontSize: 12,
                  fontWeight:
                      isCurrentTurn ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Face-down tiles
          _buildTiles(),
          const SizedBox(height: 4),
          Text(
            '$tileCount tiles',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTiles() {
    final isVerticalLayout =
        position == OpponentPosition.left ||
        position == OpponentPosition.right;

    if (isVerticalLayout) {
      return SizedBox(
        height: 100,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              tileCount,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: DominoTileWidget(
                  leftPips: 0,
                  rightPips: 0,
                  isHorizontal: true,
                  isFaceDown: true,
                  tileWidth: 16,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Top position - horizontal fan
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          tileCount,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: DominoTileWidget(
              leftPips: 0,
              rightPips: 0,
              isHorizontal: false,
              isFaceDown: true,
              tileWidth: 20,
            ),
          ),
        ),
      ),
    );
  }
}
