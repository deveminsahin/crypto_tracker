import 'package:crypto_tracker/core/result/result.dart';
import 'package:crypto_tracker/models/mini_ticker.dart';
import 'package:crypto_tracker/models/ticker.dart';

/// Contract for off-main-isolate JSON parsing.
///
/// Keeps heavy JSON decoding off the UI thread to maintain 60 fps.
abstract interface class IsolateParser {
  /// Spawns the background isolate(s) used for WebSocket parsing.
  Future<void> initialize();

  /// Parses the raw REST `/ticker/24hr` JSON into a list of [Ticker]s.
  Future<Result<List<Ticker>>> parseRestTickers(final String rawJson);

  /// Parses a raw WebSocket mini-ticker array JSON into [MiniTicker]s.
  Future<Result<List<MiniTicker>>> parseMiniTickers(final String rawJson);

  /// Kills the background isolate and releases ports.
  void dispose();
}
