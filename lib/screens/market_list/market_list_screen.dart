import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crypto_tracker/core/constants/app_constants.dart';
import 'package:crypto_tracker/core/errors/app_exception.dart';
import 'package:crypto_tracker/providers/market_provider.dart';
import 'package:crypto_tracker/screens/market_list/widgets/category_tab_bar.dart';
import 'package:crypto_tracker/screens/market_list/widgets/market_search_field.dart';
import 'package:crypto_tracker/screens/market_list/widgets/ticker_list_view.dart';
import 'package:crypto_tracker/widgets/error_display.dart';
import 'package:crypto_tracker/widgets/loading_indicator.dart';

class MarketListScreen extends StatefulWidget {
  const MarketListScreen({super.key});

  @override
  State<MarketListScreen> createState() => _MarketListScreenState();
}

class _MarketListScreenState extends State<MarketListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    context.read<MarketProvider>().loadMarketData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(AppConstants.searchDebounceDuration, () {
      context.read<MarketProvider>().setSearchQuery(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: MarketSearchField(
              controller: _searchController,
              onChanged: _onSearchChanged,
            ),
          ),
          const CategoryTabBar(),
          const Divider(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final isLoading = context.select<MarketProvider, bool>(
      (provider) => provider.isLoading,
    );
    final error = context.select<MarketProvider, AppException?>(
      (provider) => provider.error,
    );

    if (isLoading) {
      return const LoadingIndicator();
    }

    if (error != null) {
      return ErrorDisplay(
        exception: error,
        onRetry: () => context.read<MarketProvider>().retry(),
      );
    }

    return const TickerListView();
  }
}
