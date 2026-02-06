import 'package:flutter/material.dart';

import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/models/ticker.dart';

class PriceChangeCard extends StatelessWidget {
  final Ticker ticker;

  const PriceChangeCard({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    final isPositive = ticker.priceChangePercent.isPositive;
    final color =
        isPositive ? AppTheme.priceUpColor : AppTheme.priceDownColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '24h Change',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticker.priceChange.formatted,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              ticker.priceChangePercent.formatted,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
