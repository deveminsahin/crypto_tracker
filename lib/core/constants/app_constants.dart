abstract final class AppConstants {
  static const Duration searchDebounceDuration = Duration(milliseconds: 300);
  static const Duration wsThrottleDuration = Duration(milliseconds: 500);
  static const Duration wsReconnectDelay = Duration(seconds: 3);
  static const int maxReconnectAttempts = 5;
}
