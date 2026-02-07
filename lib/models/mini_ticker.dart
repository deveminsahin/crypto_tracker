import 'package:crypto_tracker/core/value_objects/price.dart';
import 'package:crypto_tracker/core/value_objects/volume.dart';
import 'package:flutter/foundation.dart';

/// Lightweight ticker snapshot received from the Binance WebSocket
/// `!miniTicker@arr` stream.
///
/// Contains a subset of ticker fields used for real-time price updates.
/// Merged into [Ticker] via [Ticker.mergeWithMiniTicker].
@immutable
final class MiniTicker {
  /// Trading pair symbol (e.g. `BTCUSDT`).
  final String symbol;

  /// Latest close / last price.
  final Price closePrice;

  /// 24-hour open price.
  final Price openPrice;

  /// 24-hour high price.
  final Price highPrice;

  /// 24-hour low price.
  final Price lowPrice;

  /// Base asset volume over the last 24 hours.
  final Volume volume;

  /// Quote asset volume over the last 24 hours.
  final Volume quoteVolume;

  const MiniTicker({
    required this.symbol,
    required this.closePrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.quoteVolume,
  });

  /// Deserializes a single entry from the WebSocket JSON array.
  ///
  /// Field keys follow the Binance mini-ticker stream format:
  /// `s` = symbol, `c` = close, `o` = open, `h` = high, `l` = low,
  /// `v` = volume, `q` = quote volume.
  factory MiniTicker.fromWsJson(final Map<String, dynamic> json) => MiniTicker(
    symbol: json['s']?.toString() ?? '',
    closePrice: Price.fromString(json['c']?.toString()),
    openPrice: Price.fromString(json['o']?.toString()),
    highPrice: Price.fromString(json['h']?.toString()),
    lowPrice: Price.fromString(json['l']?.toString()),
    volume: Volume.fromString(json['v']?.toString()),
    quoteVolume: Volume.fromString(json['q']?.toString()),
  );
}
