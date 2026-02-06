import 'dart:async';

import 'package:crypto_tracker/core/constants/app_constants.dart';
import 'package:crypto_tracker/core/result/result.dart';
import 'package:crypto_tracker/models/ticker.dart';
import 'package:crypto_tracker/services/api_service.dart';
import 'package:crypto_tracker/services/isolate_parser.dart';
import 'package:crypto_tracker/services/websocket_service.dart';

final class MarketRepository {
  final ApiService _apiService;
  final WebSocketService _webSocketService;
  final IsolateParser _isolateParser;

  final Map<String, Ticker> _tickerCache = {};

  StreamSubscription<String>? _wsSubscription;
  String? _wsBuffer;
  Timer? _wsFlushTimer;

  final StreamController<void> _tickersUpdatedController =
      StreamController<void>.broadcast();

  bool _isDisposed = false;

  MarketRepository({
    required ApiService apiService,
    required WebSocketService webSocketService,
    required IsolateParser isolateParser,
  })  : _apiService = apiService,
        _webSocketService = webSocketService,
        _isolateParser = isolateParser;

  Stream<void> get onTickersUpdated => _tickersUpdatedController.stream;

  List<Ticker> get cachedTickers =>
      _tickerCache.values.toList(growable: false);

  Ticker? cachedTicker(String symbol) => _tickerCache[symbol];

  Future<Result<List<Ticker>>> fetchTickers() async {
    final rawResult = await _apiService.fetchTickersRaw();

    switch (rawResult) {
      case Success(data: final rawJson):
        final parseResult = await _isolateParser.parseRestTickers(rawJson);

        switch (parseResult) {
          case Success(data: final tickers):
            _tickerCache.clear();
            for (final ticker in tickers) {
              _tickerCache[ticker.symbol] = ticker;
            }
            return Success(tickers);

          case Failure(exception: final e):
            return Failure(e);
        }

      case Failure(exception: final e):
        return Failure(e);
    }
  }

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
  }

  void _onWsMessage(String message) {
    if (_isDisposed) return;
    _wsBuffer = message;
  }

  Future<void> _flushWsBuffer() async {
    if (_isDisposed) return;

    final buffered = _wsBuffer;
    if (buffered == null) return;
    _wsBuffer = null;

    final result = await _isolateParser.parseMiniTickers(buffered);

    switch (result) {
      case Success(data: final miniTickers):
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

      case Failure():
        break;
    }
  }

  Future<void> disconnectWebSocket() async {
    _wsFlushTimer?.cancel();
    _wsFlushTimer = null;
    _wsBuffer = null;
    await _wsSubscription?.cancel();
    _wsSubscription = null;
    await _webSocketService.disconnect();
  }

  void dispose() {
    _isDisposed = true;
    _wsFlushTimer?.cancel();
    _wsSubscription?.cancel();
    _webSocketService.dispose();
    _isolateParser.dispose();
    _apiService.dispose();
    _tickersUpdatedController.close();
    _tickerCache.clear();
  }
}
