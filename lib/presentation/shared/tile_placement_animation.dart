import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TilePlacementAnimation extends StatelessWidget {
  final Widget child;
  final bool animate;

  const TilePlacementAnimation({
    super.key,
    required this.child,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!animate) return child;

    return child
        .animate()
        .scale(
          begin: const Offset(0.0, 0.0),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(
          duration: 200.ms,
        );
  }
}

class TileSlideAnimation extends StatelessWidget {
  final Widget child;
  final Offset beginOffset;
  final Duration duration;
  final Duration delay;

  const TileSlideAnimation({
    super.key,
    required this.child,
    this.beginOffset = const Offset(0, 100),
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .slideY(
          begin: beginOffset.dy / 100,
          end: 0,
          duration: duration,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(
          duration: duration * 0.5,
        );
  }
}

class TileRemoveAnimation extends StatefulWidget {
  final Widget child;
  final bool isRemoving;
  final VoidCallback? onComplete;

  const TileRemoveAnimation({
    super.key,
    required this.child,
    this.isRemoving = false,
    this.onComplete,
  });

  @override
  State<TileRemoveAnimation> createState() => _TileRemoveAnimationState();
}

class _TileRemoveAnimationState extends State<TileRemoveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInBack),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInCubic),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(TileRemoveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRemoving && !oldWidget.isRemoving) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
