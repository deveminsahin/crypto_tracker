part of 'ticker_row.dart';

/// Encapsulates the price-flash animation lifecycle for [TickerRow].
///
/// Exposes [flashAnimation], [isIncrease], and [flashColor] so that
/// the State class only contains tap handling and the widget tree.
mixin _TickerRowAnimationMixin on State<TickerRow>, TickerProvider {
  late final AnimationController animationController;
  late final Animation<double> flashAnimation;

  bool? isIncrease;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: AppConstants.flashAnimationDuration,
      vsync: this,
    );

    flashAnimation = Tween<double>(
      begin: AppOpacity.flashHighlight,
      end: 0,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant final TickerRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.ticker.lastPrice.value != widget.ticker.lastPrice.value) {
      isIncrease =
          widget.ticker.lastPrice.value > oldWidget.ticker.lastPrice.value;
      animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  /// Returns the flash overlay color, or `null` when idle.
  Color? flashColor(final CryptoColors cryptoColors) {
    if (isIncrease == null || flashAnimation.value <= 0) return null;
    return (isIncrease! ? cryptoColors.priceUp : cryptoColors.priceDown)
        .withValues(alpha: flashAnimation.value);
  }
}
