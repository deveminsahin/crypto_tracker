import 'package:crypto_tracker/core/constants/app_sizes.dart';
import 'package:crypto_tracker/l10n/l10n_extension.dart';

import 'package:crypto_tracker/models/ticker.dart';
import 'package:crypto_tracker/providers/market_provider.dart';
import 'package:crypto_tracker/screens/market_detail/widgets/detail_info_grid.dart';
import 'package:crypto_tracker/screens/market_detail/widgets/price_change_card.dart';
import 'package:crypto_tracker/screens/market_detail/widgets/price_header.dart';
import 'package:crypto_tracker/screens/market_detail/widgets/price_range_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Detail screen for a single trading pair showing price, change,
/// 24-hour range, and additional statistics.
///
/// Subscribes to real-time updates via [Selector] on [MarketProvider].
final class MarketDetailScreen extends StatelessWidget {
  final String symbol;

  const MarketDetailScreen({required this.symbol, super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(symbol)),
      body: Selector<MarketProvider, Ticker?>(
        selector: (_, final provider) => provider.tickerBySymbol(symbol),
        builder: (final context, final ticker, _) {
          if (ticker == null) {
            return Center(
              child: Text(
                l10n.tickerNotFound,
                style: TextTheme.of(context).bodyMedium?.copyWith(
                  color: ColorScheme.of(context).onSurfaceVariant,
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PriceHeader(ticker: ticker),
              const SizedBox(height: AppSizes.spacingSm),
              PriceChangeCard(ticker: ticker),
              const SizedBox(height: AppSizes.spacingMd),
              PriceRangeBar(ticker: ticker),
              const SizedBox(height: AppSizes.spacingMd),
              DetailInfoGrid(ticker: ticker),
              const SizedBox(height: AppSizes.spacingLg),
            ],
          );
        },
      ),
    );
  }
}
