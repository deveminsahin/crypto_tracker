import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:crypto_tracker/core/errors/app_exception.dart';
import 'package:crypto_tracker/core/result/result.dart';
import 'package:crypto_tracker/models/mini_ticker.dart';
import 'package:crypto_tracker/models/ticker.dart';
import 'package:crypto_tracker/services/isolate_parser.dart';
import 'package:flutter/foundation.dart';

/// Background-isolate implementation of [IsolateParser].
///
/// REST ticker parsing uses [compute] (one-shot isolate).
/// WebSocket mini-ticker parsing uses a long-lived isolate
/// with a shared response port to avoid per-message overhead.
final class BackgroundIsolateParser implements IsolateParser {
  static const Duration _parseTimeout = Duration(seconds: 5);

  Isolate? _wsIsolate;
  SendPort? _wsSendPort;
  ReceivePort? _wsReceivePort;
  ReceivePort? _wsResponsePort;

  /// Guards against concurrent [initialize] calls leaking isolates.
  Future<void>? _initFuture;

  /// Monotonically increasing ID for correlating requests with responses.
  int _nextRequestId = 0;

  /// Pending parse requests awaiting a response from the isolate.
  final Map<int, Completer<dynamic>> _pendingRequests = {};

  @override
  Future<void> initialize() {
    _initFuture ??= _doInitialize();
    return _initFuture!;
  }

  Future<void> _doInitialize() async {
    _wsReceivePort = ReceivePort();
    _wsResponsePort = ReceivePort();
    _wsIsolate = await Isolate.spawn(
      _wsIsolateEntryPoint,
      _wsReceivePort!.sendPort,
    );

    // Wait for the isolate to send back its SendPort.
    final completer = Completer<SendPort>();
    _wsReceivePort!.listen((final message) {
      if (message is SendPort) {
        completer.complete(message);
      }
    });
    _wsSendPort = await completer.future;

    // Send the shared response port so the isolate can reply on it.
    _wsSendPort!.send(_wsResponsePort!.sendPort);

    // Route responses to the matching pending request.
    _wsResponsePort!.listen((final message) {
      if (message is List && message.length == 2) {
        final id = message[0] as int;
        final result = message[1];
        _pendingRequests.remove(id)?.complete(result);
      }
    });
  }

  @override
  Future<Result<List<Ticker>>> parseRestTickers(final String rawJson) async {
    try {
      final tickers = await compute(_parseRestTickersInIsolate, rawJson);
      return Success(tickers);
    } on Exception catch (e) {
      return Failure(ParseException('Failed to parse REST tickers: $e'));
    }
  }

  @override
  Future<Result<List<MiniTicker>>> parseMiniTickers(
    final String rawJson,
  ) async {
    if (_wsSendPort == null) {
      return const Failure(ParseException('WS isolate not initialized'));
    }

    final id = _nextRequestId++;
    final completer = Completer<dynamic>();
    _pendingRequests[id] = completer;

    try {
      _wsSendPort!.send([id, rawJson]);

      final result = await completer.future.timeout(_parseTimeout);

      if (result is List<MiniTicker>) {
        return Success(result);
      }

      // Forward the actual error message from the isolate.
      if (result is String) {
        return Failure(ParseException(result));
      }

      return const Failure(
        ParseException('Unexpected parse result from isolate'),
      );
    } on TimeoutException {
      _pendingRequests.remove(id);
      return const Failure(ParseException('WS parse timed out'));
    } on Exception catch (e) {
      _pendingRequests.remove(id);
      return Failure(ParseException('Failed to parse WS tickers: $e'));
    }
  }

  @override
  void dispose() {
    _wsIsolate?.kill(priority: Isolate.immediate);
    _wsReceivePort?.close();
    _wsResponsePort?.close();
    for (final completer in _pendingRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError(const ParseException('Parser disposed'));
      }
    }
    _pendingRequests.clear();
    _wsIsolate = null;
    _wsSendPort = null;
    _wsReceivePort = null;
    _wsResponsePort = null;
    _initFuture = null;
  }
}

List<Ticker> _parseRestTickersInIsolate(final String rawJson) {
  final jsonList = jsonDecode(rawJson) as List<dynamic>;
  return jsonList
      .map((final json) => Ticker.fromRestJson(json as Map<String, dynamic>))
      .toList(growable: false);
}

void _wsIsolateEntryPoint(final SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  SendPort? responseSendPort;

  receivePort.listen((final message) {
    // First message from main isolate: the shared response port.
    if (message is SendPort) {
      responseSendPort = message;
      return;
    }

    if (message is List && message.length == 2 && responseSendPort != null) {
      final id = message[0] as int;
      final rawJson = message[1] as String;

      try {
        final jsonList = jsonDecode(rawJson) as List<dynamic>;
        final miniTickers = jsonList
            .map(
              (final json) =>
                  MiniTicker.fromWsJson(json as Map<String, dynamic>),
            )
            .toList(growable: false);
        responseSendPort!.send([id, miniTickers]);
      } on Exception catch (e) {
        responseSendPort!.send([id, 'ParseError: $e']);
      }
    }
  });
}
