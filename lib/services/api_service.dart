import 'package:crypto_tracker/core/result/result.dart';

/// Contract for fetching raw ticker data from a remote API.
abstract interface class ApiService {
  /// Fetches the raw JSON string of all 24-hour tickers.
  Future<Result<String>> fetchTickersRaw();

  /// Releases resources held by the service (e.g. HTTP client).
  void dispose();
}
