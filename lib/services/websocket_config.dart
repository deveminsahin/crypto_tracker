import 'package:crypto_tracker/core/constants/api_constants.dart';
import 'package:crypto_tracker/core/constants/app_constants.dart';

/// Configuration for a WebSocket connection.
///
/// Encapsulates the endpoint URL and reconnection policy so that
/// production and test configurations can be swapped easily.
final class WebSocketConfig {
  /// The WSS endpoint to connect to.
  final String url;

  /// Base delay between reconnection attempts (scaled by attempt number).
  final Duration reconnectDelay;

  /// Maximum number of consecutive reconnection attempts before giving up.
  final int maxReconnectAttempts;

  const WebSocketConfig({
    required this.url,
    required this.reconnectDelay,
    required this.maxReconnectAttempts,
  });

  /// Production configuration pointing to the Binance mini-ticker stream.
  static const production = WebSocketConfig(
    url: ApiConstants.wsBaseUrl,
    reconnectDelay: AppConstants.wsReconnectDelay,
    maxReconnectAttempts: AppConstants.maxReconnectAttempts,
  );
}
