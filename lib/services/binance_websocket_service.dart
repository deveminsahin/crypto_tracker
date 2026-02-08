import 'dart:async';

import 'package:crypto_tracker/core/constants/app_constants.dart';
import 'package:crypto_tracker/core/logging/logger.dart';
import 'package:crypto_tracker/services/websocket_config.dart';
import 'package:crypto_tracker/services/websocket_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Binance WebSocket implementation of [WebSocketService].
///
/// Connects to the mini-ticker array stream and supports automatic
/// reconnection with exponential back-off up to [WebSocketConfig.maxReconnectAttempts].
final class BinanceWebSocketService implements WebSocketService {
  static const _tag = 'WebSocket';

  final WebSocketConfig _config;
  final Logger _logger;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSubscription;
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  final StreamController<WsState> _stateController =
      StreamController<WsState>.broadcast();
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isDisposed = false;
  bool _isConnecting = false;

  BinanceWebSocketService({
    required final WebSocketConfig config,
    required final Logger logger,
  }) : _config = config,
       _logger = logger;

  @override
  Stream<String> get messages => _controller.stream;

  @override
  Stream<WsState> get connectionState => _stateController.stream;

  @override
  Future<void> connect() async {
    if (_isDisposed) return;

    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
    _logger.info(_tag, 'Initiating connection');
    await _establishConnection();
  }

  Future<void> _establishConnection() async {
    if (_isDisposed || _isConnecting) return;

    _isConnecting = true;
    _stateController.add(WsState.connecting);

    try {
      // Clean up previous channel to prevent ghost listeners.
      await _cleanupChannel();

      _channel = WebSocketChannel.connect(Uri.parse(_config.url));
      await _channel!.ready;
      _reconnectAttempts = 0;
      _stateController.add(WsState.connected);
      _logger.info(_tag, 'Connected to ${_config.url}');

      _channelSubscription = _channel!.stream.listen(
        (final data) {
          if (!_isDisposed && data is String) {
            _controller.add(data);
          }
        },
        onError: (final Object error) {
          _logger.error(_tag, 'Stream error', error);
          _handleDisconnect();
        },
        onDone: _handleDisconnect,
        cancelOnError: false,
      );
    } on Exception catch (e) {
      _logger.error(_tag, 'Connection failed', e);
      _stateController.add(WsState.disconnected);
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  void _handleDisconnect() {
    if (_isDisposed) return;

    // Cancel subscription immediately to prevent double-fire from
    // both onError and onDone triggering this method.
    _channelSubscription?.cancel();
    _channelSubscription = null;

    _logger.info(_tag, 'Disconnected');
    _stateController.add(WsState.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isDisposed) return;
    if (_reconnectAttempts >= _config.maxReconnectAttempts) {
      _logger.warning(_tag, 'Max reconnect attempts reached');
      return;
    }

    _reconnectAttempts++;
    // Exponential back-off: 3s, 6s, 12s, 24s, 48s (base * 2^(n-1))
    final delay = _config.reconnectDelay * (1 << (_reconnectAttempts - 1));

    _logger.info(
      _tag,
      'Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts/${_config.maxReconnectAttempts})',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, _establishConnection);
  }

  /// Closes the current channel and cancels its stream subscription.
  Future<void> _cleanupChannel() async {
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    unawaited(_channel?.sink.close());
    _channel = null;
  }

  @override
  Future<void> disconnect() async {
    _logger.info(_tag, 'Disconnecting');
    _reconnectTimer?.cancel();
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    try {
      await _channel?.sink.close().timeout(AppConstants.wsReconnectDelay);
    } on TimeoutException {
      // Server unreachable (e.g. WiFi off) — force-close
      _logger.warning(_tag, 'Close timed out, forcing disconnect');
    }
    _channel = null;
    _stateController.add(WsState.disconnected);
  }

  @override
  void dispose() {
    _logger.debug(_tag, 'Disposing service');
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel?.sink.close();
    _controller.close();
    _stateController.close();
    _channel = null;
  }
}
