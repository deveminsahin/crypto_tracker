// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Crypto Tracker';

  @override
  String get marketsTitle => 'Markets';

  @override
  String get searchHint => 'Search symbol...';

  @override
  String get noPairsFound => 'No pairs found';

  @override
  String get tickerNotFound => 'Ticker not found';

  @override
  String get volumePrefix => 'Vol ';

  @override
  String get retryButton => 'Retry';

  @override
  String get errorNetwork =>
      'Unable to connect. Check your internet and try again.';

  @override
  String get errorParsing =>
      'Something went wrong processing data. Please try again.';

  @override
  String get errorWebSocket => 'Live updates disconnected. Please try again.';

  @override
  String get errorCache => 'Unable to load cached data. Please try again.';

  @override
  String get wsConnected => 'Live updates active';

  @override
  String get wsConnecting => 'Connecting...';

  @override
  String get wsDisconnected => 'Live updates paused';

  @override
  String get wsError => 'Connection error';

  @override
  String get wsLabelLive => 'Live';

  @override
  String get wsLabelSyncing => 'Syncing';

  @override
  String get wsLabelStale => 'Stale';

  @override
  String get label24hHigh => '24h High';

  @override
  String get label24hLow => '24h Low';

  @override
  String get label24hVolume => '24h Volume';

  @override
  String get labelQuoteVolume => 'Quote Volume';

  @override
  String get labelBidPrice => 'Bid Price';

  @override
  String get labelAskPrice => 'Ask Price';

  @override
  String get label24hChange => '24h Change';

  @override
  String get label24hRange => '24h Range';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryUsdt => 'USDT';

  @override
  String get categoryBtc => 'BTC';

  @override
  String get categoryEth => 'ETH';

  @override
  String get categoryBnb => 'BNB';

  @override
  String get sortSymbol => 'Symbol';

  @override
  String get sortPrice => 'Price';

  @override
  String get sortChange => 'Change %';

  @override
  String get sortVolume => 'Volume';

  @override
  String get emptyStateHint => 'Try a different search term or category';

  @override
  String get scrollToTop => 'Scroll to top';

  @override
  String get recentSearches => 'Recent';
}
