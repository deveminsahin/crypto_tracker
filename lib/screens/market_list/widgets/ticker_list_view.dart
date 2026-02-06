import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crypto_tracker/models/ticker.dart';
import 'package:crypto_tracker/providers/market_provider.dart';
import 'package:crypto_tracker/screens/market_list/widgets/ticker_row.dart';

class TickerListView extends StatelessWidget {
  const TickerListView({super.key});

  static const double _itemExtent = 64;

  @override
  Widget build(BuildContext context) {
    final tickers = context.select<MarketProvider, UnmodifiableListView<Ticker>>(
      (provider) => provider.filteredTickers,
    );

    if (tickers.isEmpty) {
      return const Center(
        child: Text(
          'No pairs found',
          style: TextStyle(color: Color(0xFF848E9C), fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      itemCount: tickers.length,
      itemExtent: _itemExtent,
      itemBuilder: (context, index) {
        final ticker = tickers[index];
        return RepaintBoundary(
          key: ValueKey(ticker.symbol),
          child: TickerRow(ticker: ticker),
        );
      },
    );
  }
}
