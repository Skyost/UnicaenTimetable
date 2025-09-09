import 'package:flutter/material.dart';

/// A widget that fades in.
class FadeInWidget extends StatefulWidget {
  /// The delay.
  final Duration delay;

  /// The duration.
  final Duration duration;

  /// The curve.
  final Curve curve;

  /// The widget child.
  final Widget child;

  /// Creates a new fade in widget instance.
  const FadeInWidget({
    super.key,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _FadeInWidgetState();
}

/// The fade in widget state.
class _FadeInWidgetState extends State<FadeInWidget> {
  /// The current opacity.
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(widget.delay);
      if (mounted) {
        setState(() => opacity = 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: opacity,
    duration: widget.duration,
    curve: widget.curve,
    child: widget.child,
  );
}

/// A small scale animation.
class RepeatingScaleAnimation extends StatefulWidget {
  /// The child.
  final Widget child;

  /// The animation duration.
  final Duration duration;

  /// The animation delay.
  final Duration delay;

  /// Creates a new repeating scale animation instance.
  const RepeatingScaleAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.delay = Duration.zero,
  });

  @override
  State<StatefulWidget> createState() => _RepeatingScaleAnimationState();
}

/// The repeating scale animation state.
class _RepeatingScaleAnimationState extends State<RepeatingScaleAnimation> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  /// The animation controller.
  late AnimationController controller;

  /// The animation.
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    createAndRunAnimation();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform.scale(
        scale: animation.value,
        child: child,
      ),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Initializes and animate the widget.
  void createAndRunAnimation() {
    controller = AnimationController(duration: widget.duration, vsync: this);
    animation = createGrowSequence().animate(CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn));
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.repeat();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(widget.delay);
      if (mounted) {
        controller.forward();
      }
    });
  }

  /// Creates the grow animation sequence.
  Animatable<double> createGrowSequence() => TweenSequence(
    [
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.9),
        weight: 1,
      ),
    ],
  );
}
