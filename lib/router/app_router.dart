import 'package:go_router/go_router.dart';

import 'package:crypto_tracker/screens/market_detail/market_detail_screen.dart';
import 'package:crypto_tracker/screens/market_list/market_list_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MarketListScreen(),
    ),
    GoRoute(
      path: '/detail/:symbol',
      builder: (context, state) {
        final symbol = state.pathParameters['symbol']!;
        return MarketDetailScreen(symbol: symbol);
      },
    ),
  ],
);
