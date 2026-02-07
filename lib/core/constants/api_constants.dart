/// Binance API endpoint constants.
///
/// All URLs use secure protocols (HTTPS / WSS).
/// The REST endpoint serves 24-hour ticker snapshots while the
/// WebSocket stream pushes real-time mini-ticker updates.
abstract final class ApiConstants {
  /// Base URL for the Binance public REST API.
  static const String restBaseUrl = 'https://api.binance.com';

  /// Path for the 24-hour rolling ticker endpoint.
  static const String tickerPath = '/api/v3/ticker/24hr';

  /// Full WebSocket URL for the mini-ticker array stream.
  static const String wsBaseUrl =
      'wss://stream.binance.com:9443/ws/!miniTicker@arr';
}
