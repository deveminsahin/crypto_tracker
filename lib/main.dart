import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/providers/market_provider.dart';
import 'package:crypto_tracker/repositories/market_repository.dart';
import 'package:crypto_tracker/router/app_router.dart';
import 'package:crypto_tracker/services/api_service.dart';
import 'package:crypto_tracker/services/isolate_parser.dart';
import 'package:crypto_tracker/services/websocket_config.dart';
import 'package:crypto_tracker/services/websocket_service.dart';

void main() {
  runApp(const CryptoTrackerApp());
}

class CryptoTrackerApp extends StatelessWidget {
  const CryptoTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final apiService = ApiService(http.Client());
        final wsService = WebSocketService(WebSocketConfig.production);
        final isolateParser = IsolateParser();

        final repository = MarketRepository(
          apiService: apiService,
          webSocketService: wsService,
          isolateParser: isolateParser,
        );

        return MarketProvider(repository: repository);
      },
      child: MaterialApp.router(
        title: 'Crypto Tracker',
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
