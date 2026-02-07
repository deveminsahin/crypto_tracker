/// Log severity levels for filtering and formatting.
enum LogLevel {
  /// Verbose debugging information.
  debug,

  /// General informational messages.
  info,

  /// Potential issues that are not errors.
  warning,

  /// Errors and exceptions.
  error,
}

/// Abstract logging interface for dependency injection.
///
/// Implementations can log to console, file, or remote services.
/// Inject via constructor instead of using static methods.
///
/// **Security Note:** Never log sensitive data such as API keys,
/// tokens, or user credentials.
abstract interface class Logger {
  /// Logs a debug-level message.
  void debug(final String tag, final String message);

  /// Logs an info-level message.
  void info(final String tag, final String message);

  /// Logs a warning-level message.
  void warning(final String tag, final String message);

  /// Logs an error-level message with optional [error] and [stackTrace].
  void error(
    final String tag,
    final String message, [
    final Object? error,
    final StackTrace? stackTrace,
  ]);
}
