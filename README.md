# Crypto Tracker

A Flutter application that displays cryptocurrency market data from the Binance API with real-time WebSocket price updates.

Built as a developer case study for **baseinteractive**.

## How to Run

```bash
flutter pub get
flutter run
```

Profile mode (performance verification):

```bash
flutter run --profile
```

## Architecture

```
Core (Constants, Result, ValueObjects, Errors, Theme)
  ↑
Services (ApiService, WebSocketService, IsolateParser)
  ↑
Repository (MarketRepository — caching, WS coordination)
  ↑
Provider (MarketProvider — UI state, filtering)
  ↑
UI (Screens, Widgets — Selector for granular rebuilds)
```

### Layers

- **Core**: API/app constants, sealed `Result<T>` type, `AppException` hierarchy, value objects (`Price`, `Volume`, `Percentage`), dark theme
- **Models**: `Ticker` (REST), `MiniTicker` (WebSocket), `MarketCategory` enum
- **Services**: HTTP client wrapper, WebSocket with reconnection, isolate-based JSON parsing
- **Repository**: `MarketRepository` — coordinates services, owns in-memory cache (`Map<String, Ticker>`), buffers and throttles WebSocket updates
- **Provider**: `MarketProvider` — thin ChangeNotifier, pattern-matches on `Result<T>`, manages category/search filtering
- **Screens**: Market list (search, category tabs, ticker rows) and market detail (price header, change card, range bar, info grid)

### Key Patterns

- **Repository Pattern**: Abstracts data access, owns cache, coordinates REST + WebSocket
- **Sealed Result Type**: `Success<T>` / `Failure<T>` — exhaustive pattern matching, no uncaught exceptions
- **Value Objects**: `Price`, `Volume`, `Percentage` — immutable, formatted output, type-safe
- **Factory Constructors**: `Ticker.fromRestJson`, `MiniTicker.fromWsJson`
- **Strategy**: `MarketCategory.matches()` for symbol filtering

### State Management

Provider with `Selector<T, R>` for granular rebuilds. The provider depends only on the repository (Dependency Inversion), never on services directly.

### Navigation

go_router with declarative routes. Deep-linkable: `/` (list), `/detail/:symbol` (detail).

### Performance

- `RepaintBoundary` on each ticker row and detail section
- `ListView.builder` with fixed `itemExtent` for efficient scrolling
- WebSocket updates throttled to max 2x/sec via buffer + `Timer.periodic(500ms)`
- Long-lived isolate for WebSocket JSON parsing (avoids per-message spawn overhead)
- `compute()` for one-shot REST parsing
- `const` constructors and `final` fields everywhere

### Real-Time Data

WebSocket (`!miniTicker@arr`) provides live OHLCV updates. The repository merges these into cached REST data, computing `priceChange` and `priceChangePercent` from close/open prices while preserving `bidPrice`/`askPrice` from the initial REST load.
