import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:crypto_tracker/services/connectivity_service.dart';

/// Implementation of [ConnectivityService] using connectivity_plus package.
final class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityServiceImpl({final Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity() {
    _subscription = _connectivity.onConnectivityChanged.listen(_handleChange);
  }

  void _handleChange(final List<ConnectivityResult> results) {
    final connected = _isConnectedFromResults(results);
    _controller.add(connected);
  }

  bool _isConnectedFromResults(final List<ConnectivityResult> results) =>
      // Connected if any result is not 'none'
      results.any((final result) => result != ConnectivityResult.none);

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _isConnectedFromResults(results);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
