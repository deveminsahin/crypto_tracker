# Repositories

## Purpose

Data access layer that coordinates API fetching, WebSocket streaming, isolate parsing, and local caching.

## Contents

- `market_repository.dart` - `MarketRepository` abstract interface.
- `binance_market_repository.dart` - `BinanceMarketRepository` concrete implementation.

## Dependencies

- `services/` - `ApiService`, `WebSocketService`, `IsolateParser`
- `storage/` - `LocalStorage<Ticker>` for offline cache

## Usage

```dart
final result = await repository.fetchTickers();
await repository.connectWebSocket();
repository.onTickersUpdated.listen((_) { /* refresh UI */ });
```

## Architecture Notes

- **WebSocket throttle**: Only the latest message per 100ms window is parsed and applied.
  - Binance's `!miniTicker@arr` stream updates every ~1000ms server-side.
  - For real-time trades on a single symbol, `<symbol>@trade` can be used instead.
  - This app updates faster than Binance's main page due to direct WebSocket consumption.
- On REST failure, falls back to locally cached tickers from ObjectBox.
- `dispose()` cascades to child services (API, WebSocket, isolate parser).
