import 'dart:async';
import 'dart:io';

import 'package:crypto_tracker/core/constants/api_constants.dart';
import 'package:crypto_tracker/core/constants/app_constants.dart';
import 'package:crypto_tracker/core/errors/app_exception.dart';
import 'package:crypto_tracker/core/logging/logger.dart';
import 'package:crypto_tracker/core/result/result.dart';
import 'package:crypto_tracker/services/api_service.dart';
import 'package:http/http.dart' as http;

/// Binance REST API implementation of [ApiService].
///
/// Uses the `/api/v3/ticker/24hr` endpoint to fetch a full
/// snapshot of all trading pair statistics.
///
/// The [http.Client] is injected and its lifecycle is managed
/// externally by the service locator; [dispose] is a no-op.
final class BinanceApiService implements ApiService {
  static const _tag = 'API';

  final http.Client _client;
  final Logger _logger;

  BinanceApiService({
    required final http.Client client,
    required final Logger logger,
  }) : _client = client,
       _logger = logger;

  @override
  Future<Result<String>> fetchTickersRaw() async {
    _logger.info(_tag, 'Fetching tickers from Binance REST API');

    try {
      final uri = Uri.parse(
        '${ApiConstants.restBaseUrl}${ApiConstants.tickerPath}',
      );
      final response = await _client.get(uri).timeout(AppConstants.httpTimeout);

      if (response.statusCode == HttpStatus.ok) {
        _logger.debug(_tag, 'Fetched ${response.contentLength} bytes');
        return Success(response.body);
      }

      _logger.warning(_tag, 'HTTP ${response.statusCode} response');
      return Failure(
        NetworkException(
          'HTTP ${response.statusCode}: Failed to fetch tickers',
        ),
      );
    } on SocketException {
      _logger.error(_tag, 'No internet connection');
      return const Failure(NetworkException('No internet connection'));
    } on TimeoutException {
      _logger.error(_tag, 'Request timed out');
      return const Failure(NetworkException('Request timed out'));
    } on Exception catch (e, stackTrace) {
      _logger.error(_tag, 'Unexpected network error', e, stackTrace);
      return Failure(NetworkException('Unexpected network error: $e'));
    }
  }

  @override
  void dispose() {
    // Client lifecycle managed by service locator.
  }
}
