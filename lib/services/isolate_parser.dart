import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

import 'package:crypto_tracker/core/errors/app_exception.dart';
import 'package:crypto_tracker/core/result/result.dart';
import 'package:crypto_tracker/models/mini_ticker.dart';
import 'package:crypto_tracker/models/ticker.dart';

final class IsolateParser {
  Isolate? _wsIsolate;
  SendPort? _wsSendPort;
  ReceivePort? _wsReceivePort;

  Future<void> initialize() async {
    _wsReceivePort = ReceivePort();
    _wsIsolate = await Isolate.spawn(
      _wsIsolateEntryPoint,
      _wsReceivePort!.sendPort,
    );

    final completer = Completer<SendPort>();
    _wsReceivePort!.listen((message) {
      if (message is SendPort) {
        completer.complete(message);
      }
    });
    _wsSendPort = await completer.future;
  }

  Future<Result<List<Ticker>>> parseRestTickers(String rawJson) async {
    try {
      final tickers = await compute(_parseRestTickersInIsolate, rawJson);
      return Success(tickers);
    } on Exception catch (e) {
      return Failure(ParseException('Failed to parse REST tickers: $e'));
    }
  }

  Future<Result<List<MiniTicker>>> parseMiniTickers(String rawJson) async {
    if (_wsSendPort == null) {
      return const Failure(
        ParseException('WS isolate not initialized'),
      );
    }

    try {
      final responsePort = ReceivePort();
      _wsSendPort!.send([rawJson, responsePort.sendPort]);

      final result = await responsePort.first;
      responsePort.close();

      if (result is List<MiniTicker>) {
        return Success(result);
      }

      return Failure(
        ParseException('Unexpected parse result: ${result.runtimeType}'),
      );
    } on Exception catch (e) {
      return Failure(ParseException('Failed to parse WS tickers: $e'));
    }
  }

  void dispose() {
    _wsIsolate?.kill(priority: Isolate.immediate);
    _wsReceivePort?.close();
    _wsIsolate = null;
    _wsSendPort = null;
    _wsReceivePort = null;
  }
}

List<Ticker> _parseRestTickersInIsolate(String rawJson) {
  final List<dynamic> jsonList = jsonDecode(rawJson) as List<dynamic>;
  return jsonList
      .map((json) => Ticker.fromRestJson(json as Map<String, dynamic>))
      .toList(growable: false);
}

void _wsIsolateEntryPoint(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    if (message is List && message.length == 2) {
      final rawJson = message[0] as String;
      final replyPort = message[1] as SendPort;

      try {
        final List<dynamic> jsonList = jsonDecode(rawJson) as List<dynamic>;
        final miniTickers = jsonList
            .map(
              (json) => MiniTicker.fromWsJson(json as Map<String, dynamic>),
            )
            .toList(growable: false);
        replyPort.send(miniTickers);
      } on Exception catch (e) {
        replyPort.send('ParseError: $e');
      }
    }
  });
}
