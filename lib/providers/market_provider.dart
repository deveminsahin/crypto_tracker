import 'dart:async';
import 'dart:collection';

import 'package:crypto_tracker/core/errors/app_exception.dart';
import 'package:crypto_tracker/core/logging/logger.dart';
import 'package:crypto_tracker/core/result/result.dart';
import 'package:crypto_tracker/models/market_category.dart';
import 'package:crypto_tracker/models/ticker.dart';
import 'package:crypto_tracker/repositories/market_repository.dart';
import 'package:crypto_tracker/services/connectivity_service.dart';
import 'package:crypto_tracker/services/websocket_service.dart';
import 'package:flutter/foundation.dart';

/// WebSocket connection state for UI feedback.
enum WsConnectionState { disconnected, connecting, connected, error }

/// Sorting options for ticker list.
enum SortOption { symbol, price, changePercent, volume }

/// Sort direction (none = default API order).
enum SortDirection { none, asc, desc }

/// Central state holder for the market list screen.
///
/// Manages ticker data lifecycle (load, stream, cache fallback),
/// category filtering, text search, sorting, and connectivity awareness.
final class MarketProvider extends ChangeNotifier {
  static const _tag = 'MarketProvider';

  final MarketRepository _repository;
  final ConnectivityService _connectivityService;
  final Logger _logger;

  // ── Data state ──────────────────────────────────────────────────────

  Map<String, Ticker> _tickers = {};
  MarketCategory _selectedCategory = MarketCategory.all;
  String _searchQuery = '';
  SortOption _sortOption = SortOption.changePercent;
  SortDirection _sortDirection = SortDirection.none;

  // ── UI state ────────────────────────────────────────────────────────

  bool _isLoading = false;
  AppException? _error;
  AppException? _refreshError;
  WsConnectionState _wsState = WsConnectionState.disconnected;
  bool _hasNetwork = true;

  // ── Concurrency guards ──────────────────────────────────────────────

  bool _isDisposed = false;
  bool _isRetrying = false;
  bool _isWsStarting = false;

  /// Cached result of [filteredTickers]; invalidated on any state mutation
  /// that affects filtering or sorting.
  UnmodifiableListView<Ticker>? _cachedFilteredTickers;

  // ── Subscriptions ───────────────────────────────────────────────────

  StreamSubscription<void>? _tickersSubscription;
  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<WsState>? _wsStateSubscription;

  MarketProvider({
    required final MarketRepository repository,
    required final ConnectivityService connectivityService,
    required final Logger logger,
  }) : _repository = repository,
       _connectivityService = connectivityService,
       _logger = logger {
    _monitorConnectivity();
  }

  // ── Public getters ──────────────────────────────────────────────────

  /// Returns the filtered and sorted ticker list.
  ///
  /// The result is cached and only recomputed when the underlying state
  /// changes.
  UnmodifiableListView<Ticker> get filteredTickers =>
      _cachedFilteredTickers ??= _computeFilteredTickers();

  MarketCategory get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  AppException? get error => _error;
  AppException? get refreshError => _refreshError;
  WsConnectionState get wsState => _wsState;
  SortOption get sortOption => _sortOption;
  SortDirection get sortDirection => _sortDirection;
  bool get hasNetwork => _hasNetwork;

  /// Looks up a single cached ticker by [symbol], or `null` if not found.
  Ticker? tickerBySymbol(final String symbol) => _tickers[symbol];

  // ── Data loading ────────────────────────────────────────────────────

  /// Fetches tickers from the REST API and starts WebSocket streaming.
  ///
  /// On first load, shows a skeleton. On network failure with empty cache,
  /// surfaces the error. Falls back to local storage when available.
  Future<void> loadMarketData({final bool isRefresh = false}) async {
    if (_isLoading || _isRetrying) return;

    _logger.info(
      _tag,
      isRefresh ? 'Refreshing market data' : 'Loading market data',
    );

    _isLoading = true;
    _refreshError = null;
    if (!isRefresh) {
      _error = null;
    }
    _notify();

    Result<List<Ticker>>? result;
    try {
      result = await _repository.fetchTickers()
        ..when(
          success: (final tickers) {
            _tickers = {for (final t in tickers) t.symbol: t};
            _cachedFilteredTickers = null;
            _error = null;
            _logger.info(_tag, 'Loaded ${tickers.length} tickers');
          },
          failure: (final e) {
            _logger.error(_tag, 'Failed to load tickers', e);
            if (_tickers.isEmpty) {
              _error = e;
            } else {
              _refreshError = e;
            }
          },
        );
    } on Exception catch (e) {
      if (_tickers.isEmpty) {
        _error = NetworkException('Unexpected error: $e');
      } else {
        _refreshError = NetworkException('Unexpected error: $e');
      }
    } finally {
      _isLoading = false;
      _notify();
    }

    if (_error == null && result is Success) {
      unawaited(_startWebSocket());
    }
  }

  /// Refreshes data while keeping existing data visible.
  ///
  /// Used by pull-to-refresh and snackbar retry. Skips cache so network
  /// errors are surfaced to the user.
  Future<void> retry() async {
    if (_isLoading || _isRetrying) return;
    _isRetrying = true;

    _refreshError = null;

    try {
      // Stop listening before intentional disconnect to avoid false snackbar.
      await _wsStateSubscription?.cancel();
      _wsStateSubscription = null;
      await _repository.disconnectWebSocket();

      if (_isDisposed) return;

      final result = await _repository.fetchTickers(skipCache: true);

      if (_isDisposed) return;

      result.when(
        success: (final tickers) {
          _tickers = {for (final t in tickers) t.symbol: t};
          _cachedFilteredTickers = null;
          _error = null;
          _notify();
          unawaited(_startWebSocket());
        },
        failure: (final e) {
          _wsState = WsConnectionState.disconnected;
          _refreshError = e;
          _notify();
        },
      );
    } finally {
      _isRetrying = false;
    }
  }

  /// Clears all data and reloads from scratch. Used in error-state recovery.
  Future<void> forceReload() async {
    await _repository.disconnectWebSocket();
    _tickers = {};
    _cachedFilteredTickers = null;
    _error = null;
    // loadMarketData notifies synchronously on entry — no UI gap.
    await loadMarketData();
  }

  // ── Filtering & sorting ─────────────────────────────────────────────

  /// Updates the active market category filter.
  void setCategory(final MarketCategory category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _cachedFilteredTickers = null;
    _notify();
  }

  /// Updates the search query used to filter tickers by symbol.
  void setSearchQuery(final String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _cachedFilteredTickers = null;
    _notify();
  }

  /// Consumes the refresh error so it is not re-shown on the next rebuild.
  void clearRefreshError() {
    _refreshError = null;
  }

  /// Cycles the sort direction for [option], or sets a new sort option.
  void setSortOption(final SortOption option) {
    if (_sortOption == option) {
      // Cycle through: none → asc → desc → none
      _sortDirection = switch (_sortDirection) {
        SortDirection.none => SortDirection.asc,
        SortDirection.asc => SortDirection.desc,
        SortDirection.desc => SortDirection.none,
      };
    } else {
      _sortOption = option;
      _sortDirection = SortDirection.asc;
    }
    _cachedFilteredTickers = null;
    _notify();
  }

  // ── WebSocket ───────────────────────────────────────────────────────

  /// Connects to the WebSocket and subscribes to ticker updates.
  ///
  /// Guarded by [_isWsStarting] to prevent duplicate connections from
  /// concurrent callers (connectivity restore, load success, retry success).
  Future<void> _startWebSocket() async {
    if (_isDisposed || _isWsStarting) return;
    _isWsStarting = true;

    _wsState = WsConnectionState.connecting;
    _notify();

    await _tickersSubscription?.cancel();
    await _wsStateSubscription?.cancel();

    try {
      _wsStateSubscription = _repository.wsConnectionState.listen((
        final state,
      ) {
        if (_isDisposed) return;
        _logger.debug(_tag, 'WebSocket state changed to: $state');
        final newState = switch (state) {
          WsState.disconnected => WsConnectionState.disconnected,
          WsState.connecting => WsConnectionState.connecting,
          WsState.connected => WsConnectionState.connected,
        };
        if (_wsState != newState) {
          _logger.info(_tag, 'Updating UI state to: $newState');
          _wsState = newState;
          _notify();
        }
      });

      await _repository.connectWebSocket();
      if (_isDisposed) return;

      _tickersSubscription = _repository.onTickersUpdated.listen(
        (_) {
          if (_isDisposed) return;
          for (final t in _repository.cachedTickers) {
            _tickers[t.symbol] = t;
          }
          _cachedFilteredTickers = null;
          _notify();
        },
        onError: (_) {
          if (_isDisposed) return;
          _wsState = WsConnectionState.error;
          _notify();
        },
      );
    } on Exception {
      _wsState = WsConnectionState.error;
      _notify();
    } finally {
      _isWsStarting = false;
    }
  }

  // ── Connectivity ────────────────────────────────────────────────────

  /// Checks initial connectivity and subscribes to changes.
  void _monitorConnectivity() {
    _connectivityService.isConnected.then((final connected) {
      if (_isDisposed) return;
      _hasNetwork = connected;
      if (!connected) {
        _wsState = WsConnectionState.disconnected;
        _notify();
      }
    });

    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen(_handleConnectivityChange);
  }

  /// Reacts to network connectivity changes.
  ///
  /// Going offline: disconnects the WebSocket and updates UI.
  /// Coming back online: restarts the WebSocket or triggers a full load.
  void _handleConnectivityChange(final bool isConnected) {
    if (_isDisposed) return;

    _logger.debug(
      _tag,
      'Connectivity changed: $isConnected (was: $_hasNetwork)',
    );
    final wasOffline = !_hasNetwork;
    _hasNetwork = isConnected;

    if (!isConnected) {
      _logger.info(_tag, 'Device went offline');
      _wsState = WsConnectionState.disconnected;
      _notify();
      unawaited(_repository.disconnectWebSocket());
    } else if (wasOffline) {
      _logger.info(_tag, 'Device back online, reconnecting...');
      if (_tickers.isNotEmpty) {
        unawaited(_startWebSocket());
      } else {
        unawaited(loadMarketData());
      }
    }
  }

  // ── Filtering helpers ───────────────────────────────────────────────

  UnmodifiableListView<Ticker> _computeFilteredTickers() {
    final lowerQuery = _searchQuery.toLowerCase();
    final filtered = _tickers.values
        .where((final ticker) {
          if (!_selectedCategory.matches(ticker.symbol)) return false;
          if (lowerQuery.isNotEmpty) {
            return ticker.symbol.toLowerCase().contains(lowerQuery);
          }
          return true;
        })
        .toList(growable: false);

    if (_sortDirection != SortDirection.none) {
      final multiplier = _sortDirection == SortDirection.desc ? -1 : 1;
      filtered.sort((final a, final b) {
        final comparison = switch (_sortOption) {
          SortOption.symbol => a.symbol.compareTo(b.symbol),
          SortOption.price => a.lastPrice.value.compareTo(b.lastPrice.value),
          SortOption.changePercent => a.priceChangePercent.value.compareTo(
            b.priceChangePercent.value,
          ),
          SortOption.volume => a.volume.value.compareTo(b.volume.value),
        };
        return comparison * multiplier;
      });
    }

    return UnmodifiableListView(filtered);
  }

  // ── Lifecycle ───────────────────────────────────────────────────────

  /// Calls [notifyListeners] only if the provider has not been disposed.
  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _tickersSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _wsStateSubscription?.cancel();
    _repository.dispose();
    super.dispose();
  }
}
