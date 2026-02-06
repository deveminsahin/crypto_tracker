sealed class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException(super.message);
}

final class ParseException extends AppException {
  const ParseException(super.message);
}

final class WebSocketException extends AppException {
  const WebSocketException(super.message);
}
