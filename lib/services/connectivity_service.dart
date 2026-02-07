import 'dart:async';

/// Abstract interface for network connectivity monitoring.
///
/// Allows injection of different implementations for testing and
/// platform-specific behavior.
abstract interface class ConnectivityService {
  /// Stream that emits connectivity status changes.
  Stream<bool> get onConnectivityChanged;

  /// Checks if the device currently has network connectivity.
  Future<bool> get isConnected;

  /// Releases resources used by the service.
  void dispose();
}
