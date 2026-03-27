import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TurnIndicator extends StatefulWidget {
  final String playerName;
  final bool isActive;
  final Color? color;

  const TurnIndicator({
    super.key,
    required this.playerName,
    this.isActive = false,
    this.color,
  });

  @override
  State<TurnIndicator> createState() => _TurnIndicatorState();
}

class _TurnIndicatorState extends State<TurnIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TurnIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.secondary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? color.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isActive
                  ? color.withValues(alpha: _glowAnimation.value)
                  : Colors.white24,
              width: widget.isActive ? 2 : 1,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: color.withValues(
                          alpha: _glowAnimation.value * 0.5),
                      blurRadius: 12 * _scaleAnimation.value,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Transform.scale(
            scale: widget.isActive ? _scaleAnimation.value : 1.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isActive)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  widget.playerName,
                  style: TextStyle(
                    color: widget.isActive ? color : Colors.white70,
                    fontWeight:
                        widget.isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
