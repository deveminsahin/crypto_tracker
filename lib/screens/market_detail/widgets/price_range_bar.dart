import 'package:flutter/material.dart';

import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/models/ticker.dart';

class PriceRangeBar extends StatelessWidget {
  final Ticker ticker;

  const PriceRangeBar({super.key, required this.ticker});

  static const double _barHeight = 6;
  static const double _indicatorSize = 14;

  @override
  Widget build(BuildContext context) {
    final range = ticker.highPrice.value - ticker.lowPrice.value;
    final position = range > 0
        ? ((ticker.lastPrice.value - ticker.lowPrice.value) / range)
            .clamp(0.0, 1.0)
        : 0.5;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            '24h Range',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final indicatorOffset =
                  (barWidth - _indicatorSize) * position;

              return SizedBox(
                height: _indicatorSize + 4,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: _barHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.priceDownColor,
                            AppTheme.priceUpColor,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: indicatorOffset,
                      child: Container(
                        width: _indicatorSize,
                        height: _indicatorSize,
                        decoration: BoxDecoration(
                          color: AppTheme.textPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.scaffoldBackground,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ticker.lowPrice.formatted,
                style: const TextStyle(
                  color: AppTheme.priceDownColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                ticker.highPrice.formatted,
                style: const TextStyle(
                  color: AppTheme.priceUpColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
