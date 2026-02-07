# Models

## Purpose

Domain data models representing trading pairs and market categories.

## Contents

- `market_category.dart` - `MarketCategory` enum (All, USDT, BTC, ETH, BNB) with symbol matching.
- `mini_ticker.dart` - `MiniTicker` lightweight model from the WebSocket mini-ticker stream.
- `ticker.dart` - `Ticker` full 24-hour ticker snapshot from the REST API.

## Dependencies

- `core/value_objects/` - `Price`, `Volume`, `Percentage` value objects.

## Usage

```dart
// Parse from REST JSON
final ticker = Ticker.fromRestJson(json);

// Update with real-time WS data
final updated = ticker.mergeWithMiniTicker(miniTicker);

// Filter by category
if (MarketCategory.usdt.matches(ticker.symbol)) { ... }
```

## Architecture Notes

- `Ticker` equality is based on `symbol` + `lastPrice` only, enabling efficient UI diffing.
- `MiniTicker` is a transient DTO; it does not need `==`/`hashCode`.
- All models are `@immutable` with `const` constructors.

## MiniTicker Parsing Design

`MiniTicker.fromWsJson` uses defensive parsing with `?.toString()` instead of direct `as String?` casts.

**Rationale:** Binance WebSocket payloads are documented as strings, but using `toString()` prevents `TypeError` if the API ever sends numeric values unexpectedly.

### Known Edge Cases

| Scenario | Behavior |
|----------|----------|
| Missing field (null) | Defaults to `Price.zero` / `Volume.zero` |
| Empty string | Same as above |
| Unparseable string | Same as above |
| Empty symbol | Creates ticker with `symbol: ''` — filtered out downstream |

### Not Logged (Case Study Scope)

Malformed payloads fail silently to zeros. This is acceptable for this case study project. In production, logging can be applied by:
- Injecting a `Logger` into the factory, or
- Using a static logging utility for model parsing errors
