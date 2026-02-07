import 'package:crypto_tracker/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Ancestor widget that provides shimmer gradient and animation to descendants.
///
/// Wrap your loading content with this widget to enable coordinated shimmer
/// animation across multiple [ShimmerLoading] children.
final class Shimmer extends StatefulWidget {
  final LinearGradient linearGradient;
  final Widget? child;

  const Shimmer({required this.linearGradient, this.child, super.key});

  static ShimmerState? of(final BuildContext context) =>
      context.findAncestorStateOfType<ShimmerState>();

  @override
  ShimmerState createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(
        min: -0.5,
        max: 1.5,
        period: AppConstants.shimmerAnimationDuration,
      );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  LinearGradient get gradient => LinearGradient(
    colors: widget.linearGradient.colors,
    stops: widget.linearGradient.stops,
    begin: widget.linearGradient.begin,
    end: widget.linearGradient.end,
    transform: _SlidingGradientTransform(
      slidePercent: _shimmerController.value,
    ),
  );

  bool get isSized {
    final renderObject = context.findRenderObject();
    return renderObject is RenderBox && renderObject.hasSize;
  }

  Size get size {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) {
      throw StateError('Shimmer must be laid out before accessing size');
    }
    return renderObject.size;
  }

  Offset getDescendantOffset({
    required final RenderBox descendant,
    final Offset offset = Offset.zero,
  }) {
    final shimmerBox = context.findRenderObject();
    return descendant.localToGlobal(
      offset,
      ancestor: shimmerBox is RenderBox ? shimmerBox : null,
    );
  }

  Listenable get shimmerChanges => _shimmerController;

  @override
  Widget build(final BuildContext context) => widget.child ?? const SizedBox();
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(final Rect bounds, {final TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
}

/// Widget that applies shimmer effect to its child when loading.
///
/// Must be a descendant of a [Shimmer] widget.
final class ShimmerLoading extends StatefulWidget {
  final bool isLoading;
  final Widget child;

  const ShimmerLoading({
    required this.isLoading,
    required this.child,
    super.key,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  Listenable? _shimmerChanges;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shimmerChanges != null) {
      _shimmerChanges!.removeListener(_onShimmerChange);
    }
    _shimmerChanges = Shimmer.of(context)?.shimmerChanges;
    if (_shimmerChanges != null) {
      _shimmerChanges!.addListener(_onShimmerChange);
    }
  }

  @override
  void dispose() {
    _shimmerChanges?.removeListener(_onShimmerChange);
    super.dispose();
  }

  void _onShimmerChange() {
    if (widget.isLoading) {
      setState(() {
        // Trigger rebuild to update shimmer painting.
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final shimmer = Shimmer.of(context);
    if (shimmer == null || !shimmer.isSized) {
      return const SizedBox();
    }

    final shimmerSize = shimmer.size;
    final gradient = shimmer.gradient;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) {
      return const SizedBox();
    }
    final offsetWithinShimmer = shimmer.getDescendantOffset(
      descendant: renderObject,
    );

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (final bounds) => gradient.createShader(
        Rect.fromLTWH(
          -offsetWithinShimmer.dx,
          -offsetWithinShimmer.dy,
          shimmerSize.width,
          shimmerSize.height,
        ),
      ),
      child: widget.child,
    );
  }
}
