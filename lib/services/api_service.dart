import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:crypto_tracker/core/constants/api_constants.dart';
import 'package:crypto_tracker/core/errors/app_exception.dart';
import 'package:crypto_tracker/core/result/result.dart';

final class ApiService {
  final http.Client _client;

  ApiService(this._client);

  Future<Result<String>> fetchTickersRaw() async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.restBaseUrl}${ApiConstants.tickerPath}',
      );
      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return Success(response.body);
      }

      return Failure(
        NetworkException(
          'HTTP ${response.statusCode}: Failed to fetch tickers',
        ),
      );
    } on SocketException catch (e) {
      return Failure(NetworkException('No internet connection: $e'));
    } on TimeoutException {
      return const Failure(NetworkException('Request timed out'));
    } on Exception catch (e) {
      return Failure(NetworkException('Unexpected network error: $e'));
    }
  }

  void dispose() {
    _client.close();
  }
}
