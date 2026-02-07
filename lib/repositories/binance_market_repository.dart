import 'dart:async';

import 'package:crypto_tracker/core/constants/app_constants.dart';
import 'package:crypto_tracker/core/result/result.dart';
import 'package:crypto_tracker/models/ticker.dart';
import 'package:crypto_tracker/repositories/market_repository.dart';
import 'package:crypto_tracker/services/api_service.dart';
import 'package:crypto_tracker/services/isolate_parser.dart';
import 'package:crypto_tracker/services/websocket_service.dart';
import 'package:crypto_tracker/storage/local_storage.dart';

/// Binance implementation of [MarketRepository].
///
/// Orchestrates:
/// 1. REST fetch via [ApiService] + isolate-based JSON parsing.
/// 2. WebSocket streaming via [WebSocketService] with throttled UI updates.
/// 3. ObjectBox caching via [LocalStorage] for offline resilience.
final class BinanceMarketRepository implements MarketRepository {
  final ApiService _apiService;
  final WebSocketService _webSocketService;
  final IsolateParser _isolateParser;
  final LocalStorage<Ticker> _storage;

  final Map<String, Ticker> _tickerCache = {};

  StreamSubscription<String>? _wsSubscription;
  String? _wsBuffer;
  Timer? _wsFlushTimer;
  Timer? _cachePersistenceTimer;

  final StreamController<void> _tickersUpdatedController =
      StreamController<void>.broadcast();

  bool _isDisposed = false;

  BinanceMarketRepository({
    required final ApiService apiService,
    required final WebSocketService webSocketService,
    required final IsolateParser isolateParser,
    required final LocalStorage<Ticker> storage,
  }) : _apiService = apiService,
       _webSocketService = webSocketService,
       _isolateParser = isolateParser,
       _storage = storage;

  @override
  Stream<void> get onTickersUpdated => _tickersUpdatedController.stream;

  @override
  Stream<WsState> get wsConnectionState => _webSocketService.connectionState;

  @override
  List<Ticker> get cachedTickers => _tickerCache.values.toList(growable: false);

  @override
  Ticker? cachedTicker(final String symbol) => _tickerCache[symbol];

  @override
  Future<Result<List<Ticker>>> fetchTickers({
    final bool skipCache = false,
  }) async {
    final rawResult = await _apiService.fetchTickersRaw();

    return rawResult.when(
      success: (final rawJson) async {
        final parseResult = await _isolateParser.parseRestTickers(rawJson);
        return parseResult.when(
          success: (final tickers) {
            _tickerCache.clear();
            for (final ticker in tickers) {
              _tickerCache[ticker.symbol] = ticker;
            }
            unawaited(_storage.putAll(tickers));
            return Success(tickers);
          },
          failure: Failure.new,
        );
      },
      failure: (final e) async {
        if (!skipCache) {
          try {
            final cached = await _storage.getAll();
            if (cached.isNotEmpty) {
              _tickerCache.clear();
              for (final ticker in cached) {
                _tickerCache[ticker.symbol] = ticker;
              }
              return Success(cachedTickers);
            }
          } on Object {
            // Storage also failed — return original network error
          }
        }
        return Failure(e);
      },
    );
  }

  @override
  Future<void> connectWebSocket() async {
    if (_isDisposed) return;

    await _isolateParser.initialize();
    await _webSocketService.connect();

    _wsSubscription = _webSocketService.messages.listen(
      _onWsMessage,
      onError: (_) {},
      cancelOnError: false,
    );

    _wsFlushTimer = Timer.periodic(
      AppConstants.wsThrottleDuration,
      (_) => _flushWsBuffer(),
    );

    // Throttled persistence: save cache to disk periodically for fresher offline data
    _cachePersistenceTimer = Timer.periodic(
      AppConstants.cachePersistenceInterval,
      (_) => _persistCache(),
    );
  }

  /// Persists current ticker cache to local storage for offline resilience.
  void _persistCache() {
    if (_isDisposed || _tickerCache.isEmpty) return;
    unawaited(_storage.putAll(_tickerCache.values.toList()));
  }

  void _onWsMessage(final String message) {
    if (_isDisposed) return;
    _wsBuffer = message;
  }

  Future<void> _flushWsBuffer() async {
    if (_isDisposed) return;

    final buffered = _wsBuffer;
    if (buffered == null) return;
    _wsBuffer = null;

    final result = await _isolateParser.parseMiniTickers(buffered);

    result.when(
      success: (final miniTickers) {
        var hasUpdates = false;
        for (final mini in miniTickers) {
          final cached = _tickerCache[mini.symbol];
          if (cached != null) {
            _tickerCache[mini.symbol] = cached.mergeWithMiniTicker(mini);
            hasUpdates = true;
          }
        }
        if (hasUpdates && !_isDisposed) {
          _tickersUpdatedController.add(null);
        }
      },
      failure: (final _) {},
    );
  }

  @override
  Future<void> disconnectWebSocket() async {
    _cachePersistenceTimer?.cancel();
    _cachePersistenceTimer = null;
    _wsFlushTimer?.cancel();
    _wsFlushTimer = null;
    _wsBuffer = null;
    await _wsSubscription?.cancel();
    _wsSubscription = null;
    await _webSocketService.disconnect();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cachePersistenceTimer?.cancel();
    _wsFlushTimer?.cancel();
    _wsSubscription?.cancel();
    _webSocketService.dispose();
    _isolateParser.dispose();
    _apiService.dispose();
    _tickersUpdatedController.close();
    _tickerCache.clear();
    unawaited(_storage.close());
  }
}
