import 'package:crypto_tracker/core/result/result.dart';
import 'package:crypto_tracker/models/ticker.dart';
import 'package:crypto_tracker/services/websocket_service.dart';

/// Data-access contract for market ticker operations.
///
/// Implementations coordinate REST fetching, WebSocket streaming,
/// isolate-based parsing, and local storage caching.
abstract interface class MarketRepository {
  /// Emits whenever the in-memory ticker cache has been updated by WS data.
  Stream<void> get onTickersUpdated;

  /// Forwards the WebSocket connection lifecycle events.
  Stream<WsState> get wsConnectionState;

  /// Returns a snapshot of the current in-memory ticker cache.
  List<Ticker> get cachedTickers;

  /// Looks up a single cached ticker by [symbol].
  Ticker? cachedTicker(final String symbol);

  /// Fetches tickers from the REST API.
  ///
  /// On network failure, falls back to local storage unless [skipCache] is set.
  Future<Result<List<Ticker>>> fetchTickers({final bool skipCache = false});

  /// Opens the WebSocket stream and starts merging real-time updates.
  Future<void> connectWebSocket();

  /// Closes the WebSocket stream.
  Future<void> disconnectWebSocket();

  /// Releases all subscriptions and child services.
  void dispose();
}
