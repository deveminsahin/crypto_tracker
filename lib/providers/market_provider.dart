import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'package:crypto_tracker/core/errors/app_exception.dart';
import 'package:crypto_tracker/core/result/result.dart';
import 'package:crypto_tracker/models/market_category.dart';
import 'package:crypto_tracker/models/ticker.dart';
import 'package:crypto_tracker/repositories/market_repository.dart';

final class MarketProvider extends ChangeNotifier {
  final MarketRepository _repository;

  Map<String, Ticker> _tickers = {};
  MarketCategory _selectedCategory = MarketCategory.usdt;
  String _searchQuery = '';
  bool _isLoading = false;
  AppException? _error;

  StreamSubscription<void>? _tickersSubscription;

  MarketProvider({required MarketRepository repository})
      : _repository = repository;

  UnmodifiableListView<Ticker> get filteredTickers {
    final filtered = _tickers.values.where((ticker) {
      if (!_selectedCategory.matches(ticker.symbol)) return false;
      if (_searchQuery.isNotEmpty) {
        return ticker.symbol
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList(growable: false);

    return UnmodifiableListView(filtered);
  }

  MarketCategory get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  AppException? get error => _error;

  Ticker? tickerBySymbol(String symbol) => _tickers[symbol];

  Future<void> loadMarketData() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.fetchTickers();

    switch (result) {
      case Success(data: final tickers):
        _tickers = {for (final t in tickers) t.symbol: t};
        _error = null;
      case Failure(exception: final e):
        _error = e;
    }

    _isLoading = false;
    notifyListeners();

    if (_error == null) {
      await _startWebSocket();
    }
  }

  Future<void> _startWebSocket() async {
    await _tickersSubscription?.cancel();
    await _repository.connectWebSocket();

    _tickersSubscription = _repository.onTickersUpdated.listen((_) {
      _tickers = {
        for (final t in _repository.cachedTickers) t.symbol: t,
      };
      notifyListeners();
    });
  }

  void setCategory(MarketCategory category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> retry() async {
    await _repository.disconnectWebSocket();
    _tickers.clear();
    await loadMarketData();
  }

  @override
  void dispose() {
    _tickersSubscription?.cancel();
    _repository.dispose();
    super.dispose();
  }
}
