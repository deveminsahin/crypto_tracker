import 'package:crypto_tracker/core/constants/app_sizes.dart';
import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/l10n/l10n_extension.dart';
import 'package:crypto_tracker/models/ticker.dart';
import 'package:flutter/material.dart';

/// Card showing the absolute 24-hour price change and percentage badge.
final class PriceChangeCard extends StatelessWidget {
  const PriceChangeCard({required this.ticker, super.key});

  final Ticker ticker;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final textTheme = TextTheme.of(context);
    final cryptoColors = CryptoColors.of(context);
    final color = ticker.priceChangePercent.colorFrom(cryptoColors);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacingMd),
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: ColorScheme.of(context).surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.label24hChange, style: textTheme.bodySmall),
                const SizedBox(height: AppSizes.spacingXs),
                Text(
                  ticker.priceChange.formattedWithSeparators,
                  style: textTheme.bodyLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingMd,
              vertical: AppSizes.spacingSm,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
            ),
            child: Text(
              ticker.priceChangePercent.formatted,
              style: textTheme.bodyLarge?.copyWith(
                color: cryptoColors.onPriceBadge,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
