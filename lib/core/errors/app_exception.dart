import 'package:crypto_tracker/l10n/app_localizations.dart';

/// Base exception for all application-level errors.
///
/// Sealed so that `switch` on [AppException] is exhaustive across
/// [NetworkException], [ParseException], [WebSocketException], and
/// [StorageException].
///
/// Carries an optional [stackTrace] captured at the throw site for
/// debugging purposes.
sealed class AppException implements Exception {
  /// Human-readable error description.
  final String message;

  /// Stack trace captured when the exception was created (if available).
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);

  @override
  String toString() => message;
}

/// Thrown when an HTTP request fails (timeout, no connectivity, non-2xx).
final class NetworkException extends AppException {
  const NetworkException(super.message, [super.stackTrace]);
}

/// Thrown when JSON decoding or model deserialization fails.
final class ParseException extends AppException {
  const ParseException(super.message, [super.stackTrace]);
}

/// Thrown on WebSocket connection or stream errors.
final class WebSocketException extends AppException {
  const WebSocketException(super.message, [super.stackTrace]);
}

/// Thrown when a local storage operation (ObjectBox) fails.
final class StorageException extends AppException {
  const StorageException(super.message, [super.stackTrace]);
}

/// Maps each [AppException] subtype to a localized, user-facing string.
extension AppExceptionL10n on AppException {
  String localizedMessage(final AppLocalizations l10n) => switch (this) {
    NetworkException() => l10n.errorNetwork,
    ParseException() => l10n.errorParsing,
    WebSocketException() => l10n.errorWebSocket,
    StorageException() => l10n.errorCache,
  };
}
