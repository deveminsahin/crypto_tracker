/// Spacing, border-radius, and icon-size constants.
///
/// Using a consistent size scale prevents magic numbers throughout
/// the widget tree and makes global adjustments trivial.
abstract final class AppSizes {
  // — Spacing —

  /// 2 dp — extra-extra-small spacing.
  static const double spacingXxs = 2;

  /// 4 dp — extra-small spacing.
  static const double spacingXs = 4;

  /// 8 dp — small spacing.
  static const double spacingSm = 8;

  /// 16 dp — medium / default spacing.
  static const double spacingMd = 16;

  /// 24 dp — large spacing.
  static const double spacingLg = 24;

  /// 32 dp — extra-large spacing.
  static const double spacingXl = 32;

  // — Border radius —

  /// 4 dp — small radius (chips, tags).
  static const double borderRadiusSm = 4;

  /// 8 dp — medium radius (cards, inputs).
  static const double borderRadiusMd = 8;

  /// 12 dp — large radius (bottom sheets, dialogs).
  static const double borderRadiusLg = 12;

  // — Ticker row layout —

  /// 64 dp — fixed height / item extent for ticker rows.
  static const double tickerRowHeight = 64;

  /// 80 dp — width of the change-percent badge column.
  static const double badgeColumnWidth = 80;

  /// 12 dp — gap between price column and badge column.
  static const double priceColumnGap = 12;

  // — Icons —

  /// 12 dp — small icon (sort arrows).
  static const double iconSm = 12;

  /// 48 dp — large icon (empty-state illustrations).
  static const double iconLg = 48;

  /// 72 dp — extra-large icon.
  static const double iconXl = 72;
}
