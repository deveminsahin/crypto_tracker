import 'package:crypto_tracker/l10n/app_localizations.dart';

/// Trading-pair categories used to filter the market list.
///
/// Each value corresponds to a quote asset (USDT, BTC, ETH, BNB)
/// or the special [all] category that matches every symbol.
enum MarketCategory {
  /// Show all trading pairs regardless of quote asset.
  all,

  /// Pairs quoted in USDT (e.g. BTC/USDT).
  usdt,

  /// Pairs quoted in BTC (e.g. ETH/BTC).
  btc,

  /// Pairs quoted in ETH.
  eth,

  /// Pairs quoted in BNB.
  bnb;

  /// Returns `true` when [symbol] belongs to this category.
  bool matches(final String symbol) => switch (this) {
    MarketCategory.all => true,
    MarketCategory.usdt => symbol.endsWith('USDT'),
    MarketCategory.btc => symbol.endsWith('BTC'),
    MarketCategory.eth => symbol.endsWith('ETH'),
    MarketCategory.bnb => symbol.endsWith('BNB'),
  };
}

/// Maps each [MarketCategory] to a localized display label.
extension MarketCategoryL10n on MarketCategory {
  String label(final AppLocalizations l10n) => switch (this) {
    MarketCategory.all => l10n.categoryAll,
    MarketCategory.usdt => l10n.categoryUsdt,
    MarketCategory.btc => l10n.categoryBtc,
    MarketCategory.eth => l10n.categoryEth,
    MarketCategory.bnb => l10n.categoryBnb,
  };
}
