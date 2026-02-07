import 'package:crypto_tracker/core/errors/app_exception.dart';
import 'package:crypto_tracker/models/ticker.dart';
import 'package:crypto_tracker/storage/local_storage.dart';
import 'package:crypto_tracker/storage/objectbox.g.dart' hide StorageException;
import 'package:crypto_tracker/storage/ticker_entity.dart';

/// ObjectBox-backed implementation of [LocalStorage] for [Ticker]s.
///
/// Uses [TickerEntity] as the persistence layer. The [Store] is
/// injected and its lifecycle managed by the service locator.
final class ObjectBoxTickerStorage implements LocalStorage<Ticker> {
  final Store _store;
  final Box<TickerEntity> _box;

  ObjectBoxTickerStorage(final Store store)
    : _store = store,
      _box = store.box<TickerEntity>();

  @override
  Future<void> init() async {
    // No-op: Store is initialized externally
  }

  @override
  Future<List<Ticker>> getAll() async {
    try {
      return _box.getAll().map((final e) => e.toTicker()).toList();
    } on Exception catch (e, s) {
      throw StorageException('Failed to read cached tickers: $e', s);
    }
  }

  @override
  Future<void> putAll(final List<Ticker> tickers) async {
    try {
      final entities = tickers.map(TickerEntity.fromTicker).toList();
      // Atomic clear-then-put to prune stale entries (e.g. delisted pairs).
      _store.runInTransaction(TxMode.write, () {
        _box
          ..removeAll()
          ..putMany(entities);
      });
    } on Exception catch (e, s) {
      throw StorageException('Failed to persist tickers: $e', s);
    }
  }

  @override
  Future<void> clear() async {
    try {
      _box.removeAll();
    } on Exception catch (e, s) {
      throw StorageException('Failed to clear ticker cache: $e', s);
    }
  }

  @override
  Future<void> close() async {
    // No-op: Store is closed externally
  }
}
