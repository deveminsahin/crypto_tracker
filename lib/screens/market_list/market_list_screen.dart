import 'dart:async';

import 'package:crypto_tracker/core/constants/app_constants.dart';
import 'package:crypto_tracker/core/constants/app_sizes.dart';
import 'package:crypto_tracker/core/errors/app_exception.dart';
import 'package:crypto_tracker/l10n/app_localizations.dart';
import 'package:crypto_tracker/l10n/l10n_extension.dart';
import 'package:crypto_tracker/providers/market_provider.dart';
import 'package:crypto_tracker/screens/market_list/widgets/category_tab_bar.dart';
import 'package:crypto_tracker/screens/market_list/widgets/market_search_field.dart';
import 'package:crypto_tracker/screens/market_list/widgets/search_history_chips.dart';
import 'package:crypto_tracker/screens/market_list/widgets/sort_header.dart';
import 'package:crypto_tracker/screens/market_list/widgets/ticker_list_view.dart';
import 'package:crypto_tracker/widgets/error_display.dart';
import 'package:crypto_tracker/widgets/ticker_list_skeleton.dart';
import 'package:crypto_tracker/widgets/ws_connection_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

part 'market_list_mixin.dart';
part 'widgets/market_list_body.dart';

/// Main screen displaying the filterable, sortable list of crypto tickers.
///
/// UI-only — all behaviour lives in [_MarketListMixin].
final class MarketListScreen extends StatefulWidget {
  const MarketListScreen({super.key});

  @override
  State<MarketListScreen> createState() => _MarketListScreenState();
}

class _MarketListScreenState extends State<MarketListScreen>
    with _MarketListMixin {
  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.marketsTitle),
        actions: [
          Selector<MarketProvider, WsConnectionState>(
            selector: (_, final provider) => provider.wsState,
            builder: (_, final wsState, final child) =>
                WsConnectionIndicator(state: wsState),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MarketSearchField(
              controller: searchController,
              onChanged: onSearchChanged,
            ),
            const SearchHistoryChips(),
            const CategoryTabBar(),
            const SortHeader(),
            const Divider(),
            Expanded(
              child: _MarketListBody(scrollController: scrollController),
            ),
          ],
        ),
      ),
      floatingActionButton: showScrollToTop
          ? FloatingActionButton.small(
              onPressed: scrollToTop,
              tooltip: l10n.scrollToTop,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}
