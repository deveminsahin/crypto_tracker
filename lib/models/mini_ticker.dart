import 'package:crypto_tracker/core/value_objects/price.dart';
import 'package:crypto_tracker/core/value_objects/volume.dart';

final class MiniTicker {
  final String symbol;
  final Price closePrice;
  final Price openPrice;
  final Price highPrice;
  final Price lowPrice;
  final Volume volume;
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

  factory MiniTicker.fromWsJson(Map<String, dynamic> json) {
    return MiniTicker(
      symbol: json['s'] as String? ?? '',
      closePrice: Price.fromString(json['c'] as String?),
      openPrice: Price.fromString(json['o'] as String?),
      highPrice: Price.fromString(json['h'] as String?),
      lowPrice: Price.fromString(json['l'] as String?),
      volume: Volume.fromString(json['v'] as String?),
      quoteVolume: Volume.fromString(json['q'] as String?),
    );
  }
}
