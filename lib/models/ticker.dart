import 'package:crypto_tracker/core/value_objects/percentage.dart';
import 'package:crypto_tracker/core/value_objects/price.dart';
import 'package:crypto_tracker/core/value_objects/volume.dart';
import 'package:crypto_tracker/models/mini_ticker.dart';

final class Ticker {
  final String symbol;
  final Price lastPrice;
  final Price openPrice;
  final Price highPrice;
  final Price lowPrice;
  final Price bidPrice;
  final Price askPrice;
  final Price priceChange;
  final Percentage priceChangePercent;
  final Volume volume;
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

  factory Ticker.fromRestJson(Map<String, dynamic> json) {
    return Ticker(
      symbol: json['symbol'] as String? ?? '',
      lastPrice: Price.fromString(json['lastPrice'] as String?),
      openPrice: Price.fromString(json['openPrice'] as String?),
      highPrice: Price.fromString(json['highPrice'] as String?),
      lowPrice: Price.fromString(json['lowPrice'] as String?),
      bidPrice: Price.fromString(json['bidPrice'] as String?),
      askPrice: Price.fromString(json['askPrice'] as String?),
      priceChange: Price.fromString(json['priceChange'] as String?),
      priceChangePercent:
          Percentage.fromString(json['priceChangePercent'] as String?),
      volume: Volume.fromString(json['volume'] as String?),
      quoteVolume: Volume.fromString(json['quoteVolume'] as String?),
    );
  }

  Ticker mergeWithMiniTicker(MiniTicker mini) {
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ticker &&
          symbol == other.symbol &&
          lastPrice == other.lastPrice;

  @override
  int get hashCode => Object.hash(symbol, lastPrice);
}
