import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DominoTilePainter extends CustomPainter {
  final int leftPips;
  final int rightPips;
  final bool isHorizontal;
  final bool isFaceDown;
  final bool isSelected;
  final double width;

  DominoTilePainter({
    required this.leftPips,
    required this.rightPips,
    this.isHorizontal = true,
    this.isFaceDown = false,
    this.isSelected = false,
    this.width = 80,
  });

  double get height => width * 2;
  double get halfSize => width;
  double get pipRadius => width * 0.08;
  double get cornerRadius => width * 0.12;
  double get padding => width * 0.15;

  @override
  void paint(Canvas canvas, Size size) {
    final tileRect = isHorizontal
        ? Rect.fromLTWH(0, 0, height, width)
        : Rect.fromLTWH(0, 0, width, height);

    // Shadow
    final shadowPaint = Paint()
      ..color = AppTheme.tileShadow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        tileRect.shift(const Offset(2, 3)),
        Radius.circular(cornerRadius),
      ),
      shadowPaint,
    );

    // Selected glow
    if (isSelected) {
      final glowPaint = Paint()
        ..color = AppTheme.tileSelected.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          tileRect.inflate(4),
          Radius.circular(cornerRadius + 4),
        ),
        glowPaint,
      );
    }

    // Tile background
    final bgPaint = Paint()
      ..color = isFaceDown ? const Color(0xFF1565C0) : AppTheme.tileColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(tileRect, Radius.circular(cornerRadius)),
      bgPaint,
    );

    // Border
    final borderPaint = Paint()
      ..color = isFaceDown ? const Color(0xFF0D47A1) : const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(tileRect, Radius.circular(cornerRadius)),
      borderPaint,
    );

    if (isFaceDown) {
      _drawFaceDownPattern(canvas, tileRect);
      return;
    }

    // Dividing line
    final dividerPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 1.5;

    if (isHorizontal) {
      final midX = tileRect.center.dx;
      canvas.drawLine(
        Offset(midX, tileRect.top + padding),
        Offset(midX, tileRect.bottom - padding),
        dividerPaint,
      );
      // Draw pips
      _drawPipsInRect(
        canvas,
        Rect.fromLTRB(
            tileRect.left, tileRect.top, tileRect.center.dx, tileRect.bottom),
        leftPips,
      );
      _drawPipsInRect(
        canvas,
        Rect.fromLTRB(
            tileRect.center.dx, tileRect.top, tileRect.right, tileRect.bottom),
        rightPips,
      );
    } else {
      final midY = tileRect.center.dy;
      canvas.drawLine(
        Offset(tileRect.left + padding, midY),
        Offset(tileRect.right - padding, midY),
        dividerPaint,
      );
      // Draw pips
      _drawPipsInRect(
        canvas,
        Rect.fromLTRB(
            tileRect.left, tileRect.top, tileRect.right, tileRect.center.dy),
        leftPips,
      );
      _drawPipsInRect(
        canvas,
        Rect.fromLTRB(
            tileRect.left, tileRect.center.dy, tileRect.right, tileRect.bottom),
        rightPips,
      );
    }
  }

  void _drawFaceDownPattern(Canvas canvas, Rect rect) {
    final patternPaint = Paint()
      ..color = const Color(0xFF1976D2)
      ..style = PaintingStyle.fill;

    final centerX = rect.center.dx;
    final centerY = rect.center.dy;
    final diamondSize = math.min(rect.width, rect.height) * 0.25;

    // Draw a diamond pattern
    final path = Path()
      ..moveTo(centerX, centerY - diamondSize)
      ..lineTo(centerX + diamondSize, centerY)
      ..lineTo(centerX, centerY + diamondSize)
      ..lineTo(centerX - diamondSize, centerY)
      ..close();

    canvas.drawPath(path, patternPaint);

    // Draw border on diamond
    final diamondBorder = Paint()
      ..color = const Color(0xFF90CAF9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, diamondBorder);
  }

  void _drawPipsInRect(Canvas canvas, Rect rect, int count) {
    final pipPaint = Paint()..color = const Color(0xFF212121);
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final s = math.min(rect.width, rect.height);
    final offset = s * 0.25;

    // Pip positions relative to center
    final topLeft = Offset(cx - offset, cy - offset);
    final topRight = Offset(cx + offset, cy - offset);
    final midLeft = Offset(cx - offset, cy);
    final center = Offset(cx, cy);
    final midRight = Offset(cx + offset, cy);
    final bottomLeft = Offset(cx - offset, cy + offset);
    final bottomRight = Offset(cx + offset, cy + offset);

    List<Offset> positions;
    switch (count) {
      case 0:
        positions = [];
        break;
      case 1:
        positions = [center];
        break;
      case 2:
        positions = [topRight, bottomLeft];
        break;
      case 3:
        positions = [topRight, center, bottomLeft];
        break;
      case 4:
        positions = [topLeft, topRight, bottomLeft, bottomRight];
        break;
      case 5:
        positions = [topLeft, topRight, center, bottomLeft, bottomRight];
        break;
      case 6:
        positions = [
          topLeft,
          topRight,
          midLeft,
          midRight,
          bottomLeft,
          bottomRight,
        ];
        break;
      default:
        positions = [];
    }

    // Also add small highlight for 3D effect
    final highlightPaint = Paint()
      ..color = const Color(0xFF424242)
      ..style = PaintingStyle.fill;

    for (final pos in positions) {
      canvas.drawCircle(pos, pipRadius, pipPaint);
      canvas.drawCircle(
        Offset(pos.dx - pipRadius * 0.2, pos.dy - pipRadius * 0.2),
        pipRadius * 0.3,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(DominoTilePainter oldDelegate) {
    return oldDelegate.leftPips != leftPips ||
        oldDelegate.rightPips != rightPips ||
        oldDelegate.isHorizontal != isHorizontal ||
        oldDelegate.isFaceDown != isFaceDown ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.width != width;
  }
}

class DominoTileWidget extends StatelessWidget {
  final int leftPips;
  final int rightPips;
  final bool isHorizontal;
  final bool isFaceDown;
  final bool isSelected;
  final bool isDimmed;
  final double tileWidth;
  final VoidCallback? onTap;

  const DominoTileWidget({
    super.key,
    required this.leftPips,
    required this.rightPips,
    this.isHorizontal = true,
    this.isFaceDown = false,
    this.isSelected = false,
    this.isDimmed = false,
    this.tileWidth = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = isHorizontal ? tileWidth * 2 : tileWidth;
    final h = isHorizontal ? tileWidth : tileWidth * 2;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDimmed ? 0.4 : 1.0,
        child: CustomPaint(
          size: Size(w, h),
          painter: DominoTilePainter(
            leftPips: leftPips,
            rightPips: rightPips,
            isHorizontal: isHorizontal,
            isFaceDown: isFaceDown,
            isSelected: isSelected,
            width: tileWidth,
          ),
        ),
      ),
    );
  }
}
