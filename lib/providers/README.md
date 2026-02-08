# Providers

## Purpose

State management layer using `ChangeNotifier` with the `provider` package.

## Contents

- `market_provider.dart` - `MarketProvider` managing ticker data, filtering, sorting, WebSocket state, and connectivity.
- `search_history_provider.dart` - `SearchHistoryProvider` managing recent search history via `SearchHistoryService`.

## Dependencies

- `provider` - ChangeNotifier-based state management
- `repositories/` - data access via `MarketRepository`
- `services/` - `ConnectivityService` for network awareness
- `services/` - `SearchHistoryService` for search history persistence

## Usage

```dart
// Read state
final tickers = context.watch<MarketProvider>().filteredTickers;

// Trigger actions
context.read<MarketProvider>().setCategory(MarketCategory.usdt);
```

## Architecture Notes

- `MarketProvider` is registered as a factory in GetIt (new instance per Provider scope).
- `SearchHistoryProvider` is a singleton since search history is global.
- `filteredTickers` returns a cached `UnmodifiableListView` (lazily computed via `??=`, invalidated at all mutation points) to prevent external mutation and avoid redundant recomputation.

### Concurrency Safety

- `_isWsStarting` guard prevents duplicate WebSocket sessions from overlapping callers (connectivity restore, load success, retry success).
- `_isRetrying` guard prevents concurrent pull-to-refresh or snackbar retry from stacking up.
- `loadMarketData` is blocked during an active retry to avoid conflicting fetch/connect cycles.
- `_isDisposed` flag checked in all async callbacks and stream listeners to prevent post-dispose `notifyListeners` errors.
- `_notify()` helper centralises the dispose check for all notification calls.

### Connectivity Handling

- Monitors network changes via `ConnectivityService`.
- When offline: sets `WsConnectionState.disconnected` and disconnects WebSocket to prevent stale state.
- When back online: auto-reconnects WebSocket (or reloads full data if cache is empty).
- Initial connectivity check guarded against late resolution after dispose.

### Snackbar Coordination

- Shows error snackbar when WebSocket disconnects unexpectedly.
- Automatically hides snackbar when WebSocket reconnects successfully.
