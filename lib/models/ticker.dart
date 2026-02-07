import 'package:crypto_tracker/core/value_objects/percentage.dart';
import 'package:crypto_tracker/core/value_objects/price.dart';
import 'package:crypto_tracker/core/value_objects/volume.dart';
import 'package:crypto_tracker/models/mini_ticker.dart';
import 'package:flutter/foundation.dart';

/// Full 24-hour ticker snapshot for a single trading pair.
///
/// Initially populated from the REST `/ticker/24hr` endpoint, then
/// continuously updated via [mergeWithMiniTicker] with real-time
/// WebSocket data.
///
/// Equality is based on [symbol] and [lastPrice] only, enabling
/// efficient UI diffing (the widget tree only rebuilds when the
/// price actually changes).
@immutable
final class Ticker {
  /// Trading pair symbol (e.g. `BTCUSDT`).
  final String symbol;

  /// Most recent trade price.
  final Price lastPrice;

  /// Price at the start of the 24-hour window.
  final Price openPrice;

  /// Highest price in the 24-hour window.
  final Price highPrice;

  /// Lowest price in the 24-hour window.
  final Price lowPrice;

  /// Best current bid price.
  final Price bidPrice;

  /// Best current ask price.
  final Price askPrice;

  /// Absolute price change over 24 hours.
  final Price priceChange;

  /// Percentage price change over 24 hours.
  final Percentage priceChangePercent;

  /// Base asset volume over 24 hours.
  final Volume volume;

  /// Quote asset volume over 24 hours.
  final Volume quoteVolume;

  const Ticker({
    required this.symbol,
    required this.lastPrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.bidPrice,
    required this.askPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.volume,
    required this.quoteVolume,
  });

  /// Deserializes a ticker from the Binance REST 24-hr endpoint JSON.
  factory Ticker.fromRestJson(final Map<String, dynamic> json) => Ticker(
    symbol: json['symbol'] as String? ?? '',
    lastPrice: Price.fromString(json['lastPrice'] as String?),
    openPrice: Price.fromString(json['openPrice'] as String?),
    highPrice: Price.fromString(json['highPrice'] as String?),
    lowPrice: Price.fromString(json['lowPrice'] as String?),
    bidPrice: Price.fromString(json['bidPrice'] as String?),
    askPrice: Price.fromString(json['askPrice'] as String?),
    priceChange: Price.fromString(json['priceChange'] as String?),
    priceChangePercent: Percentage.fromString(
      json['priceChangePercent'] as String?,
    ),
    volume: Volume.fromString(json['volume'] as String?),
    quoteVolume: Volume.fromString(json['quoteVolume'] as String?),
  );

  /// Returns a new [Ticker] with prices updated from a [MiniTicker].
  ///
  /// Preserves [bidPrice] and [askPrice] (not included in the mini stream)
  /// and recomputes [priceChange] / [priceChangePercent] from the new prices.
  Ticker mergeWithMiniTicker(final MiniTicker mini) {
    final newChange = mini.closePrice - mini.openPrice;
    final newChangePercent = Percentage.fromPrices(
      current: mini.closePrice,
      open: mini.openPrice,
    );

    return Ticker(
      symbol: symbol,
      lastPrice: mini.closePrice,
      openPrice: mini.openPrice,
      highPrice: mini.highPrice,
      lowPrice: mini.lowPrice,
      bidPrice: bidPrice,
      askPrice: askPrice,
      priceChange: newChange,
      priceChangePercent: newChangePercent,
      volume: mini.volume,
      quoteVolume: mini.quoteVolume,
    );
  }

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is Ticker && symbol == other.symbol && lastPrice == other.lastPrice;

  @override
  int get hashCode => Object.hash(symbol, lastPrice);
}
