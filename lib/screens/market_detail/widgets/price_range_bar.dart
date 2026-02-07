import 'package:crypto_tracker/core/constants/app_sizes.dart';
import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/l10n/l10n_extension.dart';
import 'package:crypto_tracker/models/ticker.dart';
import 'package:flutter/material.dart';

/// Visual bar indicating where the current price sits within the 24-hour
/// low-high range, using a gradient from red (low) to green (high).
final class PriceRangeBar extends StatelessWidget {
  final Ticker ticker;

  static const double _barHeight = 6;
  static const double _indicatorSize = 14;
  static const double _indicatorPadding = 4;
  static const double _barBorderRadius = 3;
  static const double _indicatorBorderWidth = 2;
  static const double _defaultPosition = 0.5;

  const PriceRangeBar({required this.ticker, super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final colors = ColorScheme.of(context);
    final cryptoColors = CryptoColors.of(context);
    final textTheme = TextTheme.of(context);
    final range = ticker.highPrice.value - ticker.lowPrice.value;
    final position = range > 0
        ? ((ticker.lastPrice.value - ticker.lowPrice.value) / range).clamp(
            0.0,
            1.0,
          )
        : _defaultPosition;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacingMd),
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
      ),
      child: Column(
        children: [
          Text(l10n.label24hRange, style: textTheme.bodySmall),
          const SizedBox(height: AppSizes.spacingMd),
          LayoutBuilder(
            builder: (final context, final constraints) {
              final barWidth = constraints.maxWidth;
              final indicatorOffset = (barWidth - _indicatorSize) * position;
              return SizedBox(
                height: _indicatorSize + _indicatorPadding,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    SizedBox(
                      height: _barHeight,
                      width: barWidth,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_barBorderRadius),
                          gradient: LinearGradient(
                            colors: [
                              cryptoColors.priceDown,
                              cryptoColors.priceUp,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: indicatorOffset,
                      child: SizedBox(
                        width: _indicatorSize,
                        height: _indicatorSize,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.onSurface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.surface,
                              width: _indicatorBorderWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSizes.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ticker.lowPrice.formattedWithSeparators,
                style: textTheme.labelMedium?.copyWith(
                  color: cryptoColors.priceDown,
                ),
              ),
              Text(
                ticker.highPrice.formattedWithSeparators,
                style: textTheme.labelMedium?.copyWith(
                  color: cryptoColors.priceUp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
