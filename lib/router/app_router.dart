import 'package:crypto_tracker/core/logging/logger.dart';
import 'package:crypto_tracker/router/app_navigation_observer.dart';
import 'package:crypto_tracker/screens/market_detail/market_detail_screen.dart';
import 'package:crypto_tracker/screens/market_list/market_list_screen.dart';
import 'package:go_router/go_router.dart';

/// Centralised route path constants and helper methods.
abstract final class AppRoutes {
  static const marketList = '/';
  static const marketDetail = '/detail/:symbol';
  static const _symbolParam = 'symbol';

  static String detailPath(final String symbol) => '/detail/$symbol';
  static String symbolFrom(final GoRouterState state) =>
      state.pathParameters[_symbolParam] ?? '';
}

/// Creates the application [GoRouter] with market-list and detail routes.
///
/// Includes [AppNavigationObserver] for navigation event logging.
GoRouter createAppRouter(final Logger logger) => GoRouter(
  initialLocation: AppRoutes.marketList,
  observers: [AppNavigationObserver(logger: logger)],
  routes: [
    GoRoute(
      path: AppRoutes.marketList,
      builder: (final context, final state) => const MarketListScreen(),
    ),
    GoRoute(
      path: AppRoutes.marketDetail,
      builder: (final context, final state) {
        final symbol = AppRoutes.symbolFrom(state);
        return MarketDetailScreen(symbol: symbol);
      },
    ),
  ],
);
