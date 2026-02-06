import 'package:flutter/material.dart';

import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/models/ticker.dart';

class PriceHeader extends StatelessWidget {
  final Ticker ticker;

  const PriceHeader({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    final isPositive = ticker.priceChangePercent.isPositive;
    final color =
        isPositive ? AppTheme.priceUpColor : AppTheme.priceDownColor;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ticker.symbol,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ticker.lastPrice.formatted,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
