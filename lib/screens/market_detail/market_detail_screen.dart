import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/models/ticker.dart';
import 'package:crypto_tracker/providers/market_provider.dart';
import 'package:crypto_tracker/screens/market_detail/widgets/detail_info_grid.dart';
import 'package:crypto_tracker/screens/market_detail/widgets/price_change_card.dart';
import 'package:crypto_tracker/screens/market_detail/widgets/price_header.dart';
import 'package:crypto_tracker/screens/market_detail/widgets/price_range_bar.dart';

class MarketDetailScreen extends StatelessWidget {
  final String symbol;

  const MarketDetailScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(symbol),
      ),
      body: Selector<MarketProvider, Ticker?>(
        selector: (_, provider) => provider.tickerBySymbol(symbol),
        builder: (context, ticker, _) {
          if (ticker == null) {
            return const Center(
              child: Text(
                'Ticker not found',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RepaintBoundary(child: PriceHeader(ticker: ticker)),
                const SizedBox(height: 8),
                RepaintBoundary(child: PriceChangeCard(ticker: ticker)),
                const SizedBox(height: 16),
                RepaintBoundary(child: PriceRangeBar(ticker: ticker)),
                const SizedBox(height: 16),
                RepaintBoundary(child: DetailInfoGrid(ticker: ticker)),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
