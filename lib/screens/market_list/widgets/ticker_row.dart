import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/models/ticker.dart';

class TickerRow extends StatelessWidget {
  final Ticker ticker;

  const TickerRow({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    final isPositive = ticker.priceChangePercent.isPositive;
    final changeColor =
        isPositive ? AppTheme.priceUpColor : AppTheme.priceDownColor;

    return InkWell(
      onTap: () => context.go('/detail/${ticker.symbol}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticker.symbol,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Vol ${ticker.volume.formatted}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                ticker.lastPrice.formatted,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: changeColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 80,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: changeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ticker.priceChangePercent.formatted,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
