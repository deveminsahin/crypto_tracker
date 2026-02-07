import 'package:crypto_tracker/core/di/service_locator.dart';
import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/l10n/app_localizations.dart';
import 'package:crypto_tracker/providers/market_provider.dart';
import 'package:crypto_tracker/providers/search_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Root widget that wires [Provider], [GoRouter], theming, and localization.
final class CryptoTrackerApp extends StatelessWidget {
  const CryptoTrackerApp({super.key});

  @override
  Widget build(final BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => sl<MarketProvider>()),
      ChangeNotifierProvider.value(value: sl<SearchHistoryProvider>()),
    ],
    child: MaterialApp.router(
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: sl<GoRouter>(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}
