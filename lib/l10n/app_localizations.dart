import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Name of the app
  ///
  /// In en, this message translates to:
  /// **'Crypto Tracker'**
  String get appName;

  /// Title for the market list screen
  ///
  /// In en, this message translates to:
  /// **'Markets'**
  String get marketsTitle;

  /// Hint text for the search field
  ///
  /// In en, this message translates to:
  /// **'Search symbol...'**
  String get searchHint;

  /// Message when no trading pairs match the filter
  ///
  /// In en, this message translates to:
  /// **'No pairs found'**
  String get noPairsFound;

  /// Message when ticker is not found in detail view
  ///
  /// In en, this message translates to:
  /// **'Ticker not found'**
  String get tickerNotFound;

  /// Prefix for volume display
  ///
  /// In en, this message translates to:
  /// **'Vol '**
  String get volumePrefix;

  /// Label for retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Unable to connect. Check your internet and try again.'**
  String get errorNetwork;

  /// Data parsing error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong processing data. Please try again.'**
  String get errorParsing;

  /// WebSocket error message
  ///
  /// In en, this message translates to:
  /// **'Live updates disconnected. Please try again.'**
  String get errorWebSocket;

  /// Cache error message
  ///
  /// In en, this message translates to:
  /// **'Unable to load cached data. Please try again.'**
  String get errorCache;

  /// WebSocket connected tooltip
  ///
  /// In en, this message translates to:
  /// **'Live updates active'**
  String get wsConnected;

  /// WebSocket connecting tooltip
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get wsConnecting;

  /// WebSocket disconnected tooltip
  ///
  /// In en, this message translates to:
  /// **'Live updates paused'**
  String get wsDisconnected;

  /// WebSocket error tooltip
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get wsError;

  /// WebSocket connected label
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get wsLabelLive;

  /// WebSocket connecting label
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get wsLabelSyncing;

  /// WebSocket disconnected/error label
  ///
  /// In en, this message translates to:
  /// **'Stale'**
  String get wsLabelStale;

  /// Label for 24-hour high price
  ///
  /// In en, this message translates to:
  /// **'24h High'**
  String get label24hHigh;

  /// Label for 24-hour low price
  ///
  /// In en, this message translates to:
  /// **'24h Low'**
  String get label24hLow;

  /// Label for 24-hour volume
  ///
  /// In en, this message translates to:
  /// **'24h Volume'**
  String get label24hVolume;

  /// Label for quote volume
  ///
  /// In en, this message translates to:
  /// **'Quote Volume'**
  String get labelQuoteVolume;

  /// Label for bid price
  ///
  /// In en, this message translates to:
  /// **'Bid Price'**
  String get labelBidPrice;

  /// Label for ask price
  ///
  /// In en, this message translates to:
  /// **'Ask Price'**
  String get labelAskPrice;

  /// Label for 24-hour price change
  ///
  /// In en, this message translates to:
  /// **'24h Change'**
  String get label24hChange;

  /// Label for 24-hour price range
  ///
  /// In en, this message translates to:
  /// **'24h Range'**
  String get label24hRange;

  /// All category filter label
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// USDT category filter label
  ///
  /// In en, this message translates to:
  /// **'USDT'**
  String get categoryUsdt;

  /// BTC category filter label
  ///
  /// In en, this message translates to:
  /// **'BTC'**
  String get categoryBtc;

  /// ETH category filter label
  ///
  /// In en, this message translates to:
  /// **'ETH'**
  String get categoryEth;

  /// BNB category filter label
  ///
  /// In en, this message translates to:
  /// **'BNB'**
  String get categoryBnb;

  /// Sort by symbol option
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get sortSymbol;

  /// Sort by price option
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get sortPrice;

  /// Sort by change percentage option
  ///
  /// In en, this message translates to:
  /// **'Change %'**
  String get sortChange;

  /// Sort by volume option
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get sortVolume;

  /// Hint text shown in empty state view
  ///
  /// In en, this message translates to:
  /// **'Try a different search term or category'**
  String get emptyStateHint;

  /// Tooltip for scroll to top button
  ///
  /// In en, this message translates to:
  /// **'Scroll to top'**
  String get scrollToTop;

  /// Label for recent search history section
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentSearches;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
