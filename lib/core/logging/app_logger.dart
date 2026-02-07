import 'dart:developer' as developer;

import 'package:crypto_tracker/core/logging/logger.dart';
import 'package:flutter/foundation.dart';

/// Default [Logger] implementation using `dart:developer`.
///
/// In debug mode, logs to the console. In release mode, logs are
/// suppressed unless a custom [logHandler] is registered.
///
/// Usage:
/// ```dart
/// final logger = AppLogger();
/// logger.info('API', 'Fetching tickers');
/// ```
final class AppLogger implements Logger {
  /// Optional custom log handler for release builds.
  ///
  /// Set this to forward logs to a crash reporting service.
  void Function(LogLevel, String, String, Object?, StackTrace?)? logHandler;

  /// Creates an [AppLogger] instance.
  ///
  /// Optionally accepts a [logHandler] for custom log processing.
  AppLogger({this.logHandler});

  @override
  void debug(final String tag, final String message) {
    _log(LogLevel.debug, tag, message);
  }

  @override
  void info(final String tag, final String message) {
    _log(LogLevel.info, tag, message);
  }

  @override
  void warning(final String tag, final String message) {
    _log(LogLevel.warning, tag, message);
  }

  @override
  void error(
    final String tag,
    final String message, [
    final Object? error,
    final StackTrace? stackTrace,
  ]) {
    _log(LogLevel.error, tag, message, error, stackTrace);
  }

  void _log(
    final LogLevel level,
    final String tag,
    final String message, [
    final Object? error,
    final StackTrace? stackTrace,
  ]) {
    // Forward to custom handler if registered.
    logHandler?.call(level, tag, message, error, stackTrace);

    // Only log to console in debug mode.
    if (!kDebugMode) return;

    final prefix = '[${level.name.toUpperCase()}] [$tag]';
    final fullMessage = error != null
        ? '$prefix $message — $error'
        : '$prefix $message';

    developer.log(
      fullMessage,
      name: 'CryptoTracker',
      level: _logLevelToInt(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Maps [LogLevel] to `dart:developer` severity integers.
  int _logLevelToInt(final LogLevel level) => switch (level) {
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warning => 900,
    LogLevel.error => 1000,
  };
}
