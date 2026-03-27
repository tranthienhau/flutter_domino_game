import 'dart:math' as math;
import 'package:flutter/material.dart';

class TileFlipAnimation extends StatefulWidget {
  final Widget frontWidget;
  final Widget backWidget;
  final Duration duration;
  final Duration delay;
  final bool flipOnStart;

  const TileFlipAnimation({
    super.key,
    required this.frontWidget,
    required this.backWidget,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.flipOnStart = true,
  });

  @override
  State<TileFlipAnimation> createState() => _TileFlipAnimationState();
}

class _TileFlipAnimationState extends State<TileFlipAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _animation.addListener(() {
      if (_animation.value >= math.pi / 2 && _showFront) {
        setState(() => _showFront = false);
      } else if (_animation.value < math.pi / 2 && !_showFront) {
        setState(() => _showFront = true);
      }
    });

    if (widget.flipOnStart) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void flip() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateY(angle);

        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: _showFront
              ? widget.frontWidget
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: widget.backWidget,
                ),
        );
      },
    );
  }
}

class DealingAnimation extends StatelessWidget {
  final List<Widget> tileWidgets;
  final Duration staggerDelay;

  const DealingAnimation({
    super.key,
    required this.tileWidgets,
    this.staggerDelay = const Duration(milliseconds: 100),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(tileWidgets.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: TileFlipAnimation(
            frontWidget: Container(
              width: 40,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF0D47A1)),
              ),
              child: const Center(
                child: Icon(Icons.question_mark, color: Colors.white38, size: 20),
              ),
            ),
            backWidget: tileWidgets[index],
            delay: staggerDelay * index,
          ),
        );
      }),
    );
  }
}
