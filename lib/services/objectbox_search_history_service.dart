import 'package:crypto_tracker/core/errors/app_exception.dart';
import 'package:crypto_tracker/services/search_history_service.dart';
import 'package:crypto_tracker/storage/objectbox.g.dart' hide StorageException;
import 'package:crypto_tracker/storage/search_history_entity.dart';

/// ObjectBox implementation of search history service.
final class ObjectBoxSearchHistoryService implements SearchHistoryService {
  final Box<SearchHistoryEntity> _box;

  static const int _maxEntries = 4;

  ObjectBoxSearchHistoryService(final Store store)
    : _box = store.box<SearchHistoryEntity>();

  @override
  Future<List<String>> getRecentSearches({
    final int limit = _maxEntries,
  }) async {
    try {
      final query = _box
          .query()
          .order(SearchHistoryEntity_.searchedAt, flags: Order.descending)
          .build()
        ..limit = limit;

      final results = query
          .find()
          .map((final e) => e.symbol)
          .toList();
      query.close();

      return results;
    } on Exception catch (e, s) {
      throw StorageException('Failed to read search history: $e', s);
    }
  }

  @override
  Future<void> addSearch(final String symbol) async {
    if (symbol.trim().isEmpty) return;

    try {
      final upperSymbol = symbol.toUpperCase();

      // Insert or update (unique constraint handles replace)
      _box.put(
        SearchHistoryEntity(symbol: upperSymbol, searchedAt: DateTime.now()),
      );

      // Trim to max entries
      _trimToMaxEntries();
    } on Exception catch (e, s) {
      throw StorageException('Failed to save search entry: $e', s);
    }
  }

  void _trimToMaxEntries() {
    final query = _box
        .query()
        .order(SearchHistoryEntity_.searchedAt, flags: Order.descending)
        .build();

    final all = query.find();
    query.close();

    if (all.length > _maxEntries) {
      final toRemove = all.skip(_maxEntries).map((final e) => e.id).toList();
      _box.removeMany(toRemove);
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      _box.removeAll();
    } on Exception catch (e, s) {
      throw StorageException('Failed to clear search history: $e', s);
    }
  }
}
