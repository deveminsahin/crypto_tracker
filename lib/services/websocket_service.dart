/// WebSocket connection state.
enum WsState {
  /// Not connected to the server.
  disconnected,

  /// Handshake / connection in progress.
  connecting,

  /// Actively receiving data.
  connected,
}

/// Contract for a WebSocket service that streams real-time data.
abstract interface class WebSocketService {
  /// Stream of raw JSON messages from the server.
  Stream<String> get messages;

  /// Stream of connection lifecycle events.
  Stream<WsState> get connectionState;

  /// Opens the WebSocket connection.
  Future<void> connect();

  /// Gracefully closes the WebSocket connection.
  Future<void> disconnect();

  /// Releases all resources (channels, timers, controllers).
  void dispose();
}
