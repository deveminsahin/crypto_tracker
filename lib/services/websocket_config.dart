import 'package:crypto_tracker/core/constants/api_constants.dart';
import 'package:crypto_tracker/core/constants/app_constants.dart';

final class WebSocketConfig {
  final String url;
  final Duration reconnectDelay;
  final int maxReconnectAttempts;

  const WebSocketConfig({
    required this.url,
    required this.reconnectDelay,
    required this.maxReconnectAttempts,
  });

  static const WebSocketConfig production = WebSocketConfig(
    url: ApiConstants.wsBaseUrl,
    reconnectDelay: AppConstants.wsReconnectDelay,
    maxReconnectAttempts: AppConstants.maxReconnectAttempts,
  );
}
