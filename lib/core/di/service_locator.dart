import 'package:crypto_tracker/core/logging/app_logger.dart';
import 'package:crypto_tracker/core/logging/logger.dart';
import 'package:crypto_tracker/models/ticker.dart';
import 'package:crypto_tracker/providers/market_provider.dart';
import 'package:crypto_tracker/providers/search_history_provider.dart';
import 'package:crypto_tracker/repositories/binance_market_repository.dart';
import 'package:crypto_tracker/repositories/market_repository.dart';
import 'package:crypto_tracker/router/app_router.dart';
import 'package:crypto_tracker/services/api_service.dart';
import 'package:crypto_tracker/services/background_isolate_parser.dart';
import 'package:crypto_tracker/services/binance_api_service.dart';
import 'package:crypto_tracker/services/binance_websocket_service.dart';
import 'package:crypto_tracker/services/connectivity_service.dart';
import 'package:crypto_tracker/services/connectivity_service_impl.dart';
import 'package:crypto_tracker/services/isolate_parser.dart';
import 'package:crypto_tracker/services/objectbox_search_history_service.dart';
import 'package:crypto_tracker/services/search_history_service.dart';
import 'package:crypto_tracker/services/websocket_config.dart';
import 'package:crypto_tracker/services/websocket_service.dart';
import 'package:crypto_tracker/storage/local_storage.dart';
import 'package:crypto_tracker/storage/objectbox.g.dart';
import 'package:crypto_tracker/storage/objectbox_ticker_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

/// Global [GetIt] service-locator instance.
///
/// Access registered dependencies anywhere via `sl<Type>()`.
final sl = GetIt.instance;

/// Registers all application dependencies into [sl].
///
/// Must be awaited before `runApp` because [ObjectBox] `openStore` is async.
/// Registration order: logging -> storage -> services -> repository -> provider -> router.
Future<void> setupServiceLocator() async {
  // ObjectBox Store (shared)
  final store = await openStore();
  final httpClient = http.Client();

  // Logging
  sl
    ..registerSingleton<Logger>(AppLogger())
    // Storage & Providers
    ..registerSingleton<Store>(store)
    ..registerSingleton<http.Client>(httpClient)
    ..registerSingleton<LocalStorage<Ticker>>(ObjectBoxTickerStorage(store))
    ..registerSingleton<SearchHistoryService>(
      ObjectBoxSearchHistoryService(store),
    )
    ..registerSingleton<SearchHistoryProvider>(SearchHistoryProvider(store))
    // Services
    ..registerLazySingleton<ApiService>(
      () => BinanceApiService(client: sl(), logger: sl()),
    )
    ..registerLazySingleton<WebSocketService>(
      () => BinanceWebSocketService(
        config: WebSocketConfig.production,
        logger: sl(),
      ),
    )
    ..registerLazySingleton<IsolateParser>(BackgroundIsolateParser.new)
    ..registerLazySingleton<ConnectivityService>(ConnectivityServiceImpl.new)
    // Repository
    ..registerLazySingleton<MarketRepository>(
      () => BinanceMarketRepository(
        apiService: sl(),
        webSocketService: sl(),
        isolateParser: sl(),
        storage: sl(),
      ),
    )
    // Provider
    ..registerFactory<MarketProvider>(
      () => MarketProvider(
        repository: sl(),
        connectivityService: sl(),
        logger: sl(),
      ),
    )
    // Router
    ..registerLazySingleton<GoRouter>(() => createAppRouter(sl()));
}
