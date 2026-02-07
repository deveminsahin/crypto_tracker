import 'package:crypto_tracker/core/value_objects/percentage.dart';
import 'package:crypto_tracker/core/value_objects/price.dart';
import 'package:crypto_tracker/core/value_objects/volume.dart';
import 'package:crypto_tracker/models/ticker.dart';
import 'package:objectbox/objectbox.dart';

/// ObjectBox entity that maps a [Ticker] domain model to a flat DB row.
///
/// All value-object fields (Price, Volume, Percentage) are stored as
/// raw [double]s. Conversion methods [toTicker] and [fromTicker]
/// handle the mapping.
@Entity()
class TickerEntity {
  @Id()
  int id = 0;

  @Unique(onConflict: ConflictStrategy.replace)
  String symbol;

  double lastPrice;
  double openPrice;
  double highPrice;
  double lowPrice;
  double bidPrice;
  double askPrice;
  double priceChange;
  double priceChangePercent;
  double volume;
  double quoteVolume;

  TickerEntity({
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
    this.id = 0,
  });

  Ticker toTicker() => Ticker(
    symbol: symbol,
    lastPrice: Price(lastPrice),
    openPrice: Price(openPrice),
    highPrice: Price(highPrice),
    lowPrice: Price(lowPrice),
    bidPrice: Price(bidPrice),
    askPrice: Price(askPrice),
    priceChange: Price(priceChange),
    priceChangePercent: Percentage(priceChangePercent),
    volume: Volume(volume),
    quoteVolume: Volume(quoteVolume),
  );

  factory TickerEntity.fromTicker(final Ticker t) => TickerEntity(
    symbol: t.symbol,
    lastPrice: t.lastPrice.value,
    openPrice: t.openPrice.value,
    highPrice: t.highPrice.value,
    lowPrice: t.lowPrice.value,
    bidPrice: t.bidPrice.value,
    askPrice: t.askPrice.value,
    priceChange: t.priceChange.value,
    priceChangePercent: t.priceChangePercent.value,
    volume: t.volume.value,
    quoteVolume: t.quoteVolume.value,
  );
}
