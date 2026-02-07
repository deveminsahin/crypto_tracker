import 'package:crypto_tracker/core/constants/app_sizes.dart';
import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/models/ticker.dart';
import 'package:flutter/material.dart';

/// Hero section showing the symbol name and large current price.
final class PriceHeader extends StatelessWidget {
  final Ticker ticker;

  const PriceHeader({required this.ticker, super.key});

  @override
  Widget build(final BuildContext context) {
    final textTheme = TextTheme.of(context);
    final cryptoColors = CryptoColors.of(context);
    final color = ticker.priceChangePercent.colorFrom(cryptoColors);

    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ticker.symbol,
            style: textTheme.bodyMedium?.copyWith(
              color: ColorScheme.of(context).onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXs),
          Text(
            ticker.lastPrice.formattedWithSeparators,
            style: textTheme.displaySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
