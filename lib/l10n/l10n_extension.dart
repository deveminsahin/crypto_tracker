import 'package:crypto_tracker/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

extension AppLocalizationsX on BuildContext {
  /// Get app-level localizations
  AppLocalizations get l10n => AppLocalizations.of(this);
}
