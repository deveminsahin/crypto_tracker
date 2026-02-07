# Services

## Purpose

Business logic services handling API communication, WebSocket streaming, JSON parsing, connectivity monitoring, and search history.

## Contents

### Interfaces

- `api_service.dart` - `ApiService` contract for REST fetching.
- `websocket_service.dart` - `WebSocketService` contract + `WsState` enum.
- `connectivity_service.dart` - `ConnectivityService` contract.
- `isolate_parser.dart` - `IsolateParser` contract for off-main-thread parsing.
- `search_history_service.dart` - `SearchHistoryService` contract for search history CRUD.

### Implementations

- `binance_api_service.dart` - Binance REST API implementation with timeout and error mapping.
- `binance_websocket_service.dart` - Binance WebSocket with auto-reconnection using exponential back-off. Tracks stream subscriptions to prevent ghost listeners on reconnect.
- `connectivity_service_impl.dart` - `connectivity_plus`-backed implementation.
- `background_isolate_parser.dart` - Long-lived isolate for WS parsing with shared response port and correlation IDs, `compute()` for REST. Guards against concurrent initialization and includes parse timeouts.
- `objectbox_search_history_service.dart` - ObjectBox-backed search history CRUD with `StorageException` wrapping.

### Configuration

- `websocket_config.dart` - Reconnection policy and endpoint URL.

## Dependencies

- `http` - HTTP client
- `web_socket_channel` - WebSocket connections
- `connectivity_plus` - Network reachability
- `objectbox` - Local storage for search history

## Architecture Notes

- Every service has an abstract interface in a dedicated file, enabling easy testing via mocks.
- JSON parsing runs on background isolates to keep the UI thread free.
- WebSocket reconnection uses exponential back-off (`base * 2^(n-1)`) up to a configurable max attempts.
- The HTTP client lifecycle is managed by the service locator, not by `BinanceApiService`.
- The WS isolate uses a single long-lived response port with monotonic request IDs, avoiding per-message `ReceivePort` overhead.
- All ObjectBox operations are wrapped in `StorageException` for consistent error handling.
