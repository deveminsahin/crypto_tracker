# Storage

## Purpose

Local persistence layer using ObjectBox for offline caching and search history.

## Contents

- `local_storage.dart` - `LocalStorage<T>` generic interface.
- `ticker_entity.dart` - `TickerEntity` ObjectBox entity mapping `Ticker` to DB columns.
- `search_history_entity.dart` - `SearchHistoryEntity` ObjectBox entity for search history.
- `objectbox_ticker_storage.dart` - `ObjectBoxTickerStorage` implementing `LocalStorage<Ticker>` with transactional writes and `StorageException` wrapping.
- `objectbox-model.json` - ObjectBox schema definition (auto-managed).
- `objectbox.g.dart` - Generated ObjectBox bindings (excluded from analysis).

## Dependencies

- `objectbox` - High-performance NoSQL embedded database
- `objectbox_flutter_libs` - Platform-specific native libraries

## Usage

```dart
// Store tickers (atomic clear + put to prune stale entries)
await storage.putAll(tickers);

// Retrieve cached tickers
final cached = await storage.getAll();
```

## Architecture Notes

- The `Store` is opened once in the service locator and shared across all boxes.
- Entity classes cannot be `final` or `@immutable` due to ObjectBox code-generation requirements.
- `@Unique(onConflict: ConflictStrategy.replace)` on `symbol` enables upsert semantics.
- `putAll` uses `Store.runInTransaction(TxMode.write, ...)` to atomically clear and repopulate, preventing stale entries from accumulating (e.g. delisted trading pairs).
- All ObjectBox operations are wrapped in `StorageException` to integrate with the app's sealed exception hierarchy and prevent unhandled errors in `unawaited` callers.
- Generated files (`objectbox.g.dart`) are excluded from lint analysis.
