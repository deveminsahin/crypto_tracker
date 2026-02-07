import 'dart:collection';

import 'package:crypto_tracker/core/constants/app_sizes.dart';
import 'package:crypto_tracker/models/ticker.dart';
import 'package:crypto_tracker/providers/market_provider.dart';
import 'package:crypto_tracker/screens/market_list/widgets/ticker_row.dart';
import 'package:crypto_tracker/widgets/empty_state_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Scrollable list of [TickerRow] widgets with a fixed item extent for
/// optimal scroll performance and automatic keep-alive disabled.
final class TickerListView extends StatelessWidget {
  final ScrollController? scrollController;

  const TickerListView({super.key, this.scrollController});

  @override
  Widget build(final BuildContext context) {
    final tickers = context
        .select<MarketProvider, UnmodifiableListView<Ticker>>(
          (final provider) => provider.filteredTickers,
        );

    if (tickers.isEmpty) {
      return const EmptyStateView();
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: tickers.length,
      itemExtent: AppSizes.tickerRowHeight,
      // Flutter's ListView already wraps items with RepaintBoundary.
      // Disable keepAlives since flash animation state doesn't need
      // to survive scrolling off-screen.
      addAutomaticKeepAlives: false,
      itemBuilder: (final context, final index) {
        final ticker = tickers[index];
        return TickerRow(key: ValueKey(ticker.symbol), ticker: ticker);
      },
    );
  }
}
