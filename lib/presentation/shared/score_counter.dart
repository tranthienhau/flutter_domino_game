import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class ScoreCounter extends StatelessWidget {
  final String teamName;
  final int score;
  final Color teamColor;
  final int targetScore;

  const ScoreCounter({
    super.key,
    required this.teamName,
    required this.score,
    required this.teamColor,
    this.targetScore = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: teamColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            teamName,
            style: TextStyle(
              color: teamColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: score),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                '$value',
                style: GoogleFonts.robotoMono(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondary,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 60,
            child: LinearProgressIndicator(
              value: (score / targetScore).clamp(0.0, 1.0),
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(teamColor),
              minHeight: 3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreBoard extends StatelessWidget {
  final Map<String, int> scores;

  const ScoreBoard({
    super.key,
    required this.scores,
  });

  @override
  Widget build(BuildContext context) {
    final teamAScore = scores['teamA'] ?? 0;
    final teamBScore = scores['teamB'] ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScoreCounter(
          teamName: 'Team A',
          score: teamAScore,
          teamColor: AppTheme.teamAColor,
        ),
        const SizedBox(width: 8),
        Text(
          'vs',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        ScoreCounter(
          teamName: 'Team B',
          score: teamBScore,
          teamColor: AppTheme.teamBColor,
        ),
      ],
    );
  }
}
