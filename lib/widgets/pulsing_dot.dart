part of 'ws_connection_indicator.dart';

final class _PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingDot({required this.color, required this.size});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.shimmerAnimationDuration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.4,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => AnimatedBuilder(
    animation: _animation,
    builder: (final context, final child) => SizedBox(
      width: widget.size,
      height: widget.size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: _animation.value),
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}
