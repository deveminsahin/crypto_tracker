/// Application-wide timing and limit constants.
///
/// Centralises durations for debouncing, throttling, animations,
/// network timeouts, and retry policies so they can be tuned from
/// a single location.
abstract final class AppConstants {
  /// Delay before a search query is dispatched after the user stops typing.
  static const Duration searchDebounceDuration = Duration(milliseconds: 300);

  /// Minimum interval between WebSocket UI updates to avoid excessive rebuilds.
  ///
  /// Note: Binance's `!miniTicker@arr` stream updates every 1000ms server-side.
  /// For real-time trades on a single symbol, use `<symbol>@trade` instead.
  /// This app updates faster than Binance's main page due to direct WebSocket
  /// consumption with minimal processing overhead.
  static const Duration wsThrottleDuration = Duration(milliseconds: 100);

  /// Wait time before attempting a WebSocket reconnection.
  static const Duration wsReconnectDelay = Duration(seconds: 3);

  /// Duration of the price-flash highlight animation.
  static const Duration flashAnimationDuration = Duration(milliseconds: 500);

  /// Duration of the shimmer loading placeholder animation cycle.
  static const Duration shimmerAnimationDuration = Duration(milliseconds: 1000);

  /// Duration of programmatic scroll animations (e.g. scroll-to-top).
  static const Duration scrollAnimationDuration = Duration(milliseconds: 300);

  /// Timeout for HTTP REST requests.
  static const Duration httpTimeout = Duration(seconds: 10);

  /// Maximum number of consecutive WebSocket reconnection attempts.
  static const int maxReconnectAttempts = 5;

  /// Interval between cache persistence writes during WebSocket streaming.
  ///
  /// Balances freshness of offline data against disk I/O overhead.
  static const Duration cachePersistenceInterval = Duration(seconds: 30);

  /// Scroll offset (in dp) at which the scroll-to-top FAB appears.
  static const double scrollToTopThreshold = 500;
}
