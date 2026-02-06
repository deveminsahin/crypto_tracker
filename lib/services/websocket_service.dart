import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:crypto_tracker/services/websocket_config.dart';

final class WebSocketService {
  final WebSocketConfig _config;

  WebSocketChannel? _channel;
  StreamController<String>? _controller;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isDisposed = false;

  WebSocketService(this._config);

  Stream<String> get messages {
    _controller ??= StreamController<String>.broadcast();
    return _controller!.stream;
  }

  Future<void> connect() async {
    if (_isDisposed) return;

    _reconnectAttempts = 0;
    await _establishConnection();
  }

  Future<void> _establishConnection() async {
    if (_isDisposed) return;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_config.url));
      await _channel!.ready;
      _reconnectAttempts = 0;

      _channel!.stream.listen(
        (data) {
          if (!_isDisposed && data is String) {
            _controller?.add(data);
          }
        },
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: false,
      );
    } on Exception {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_isDisposed) return;
    if (_reconnectAttempts >= _config.maxReconnectAttempts) return;

    _reconnectAttempts++;
    final delay = _config.reconnectDelay * _reconnectAttempts;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, _establishConnection);
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    await _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _controller?.close();
    _channel = null;
    _controller = null;
  }
}
