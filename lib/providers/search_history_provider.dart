import 'package:crypto_tracker/storage/objectbox.g.dart';
import 'package:crypto_tracker/storage/search_history_entity.dart';
import 'package:flutter/foundation.dart';

/// Provider for managing search history with change notifications.
final class SearchHistoryProvider extends ChangeNotifier {
  final Box<SearchHistoryEntity> _box;

  static const int _maxEntries = 4;

  List<String> _history = [];
  List<String> get history => _history;

  SearchHistoryProvider(final Store store)
    : _box = store.box<SearchHistoryEntity>() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final query = _box
        .query()
        .order(SearchHistoryEntity_.searchedAt, flags: Order.descending)
        .build();

    _history = query
        .find()
        .take(_maxEntries)
        .map((final e) => e.symbol)
        .toList();
    query.close();
    notifyListeners();
  }

  Future<void> addSearch(final String symbol) async {
    if (symbol.trim().isEmpty) return;

    final upperSymbol = symbol.toUpperCase();

    // Insert or update (unique constraint handles replace)
    _box.put(
      SearchHistoryEntity(symbol: upperSymbol, searchedAt: DateTime.now()),
    );

    // Trim to max entries
    await _trimToMaxEntries();

    // Reload and notify listeners
    await _loadHistory();
  }

  Future<void> _trimToMaxEntries() async {
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

  Future<void> clearHistory() async {
    _box.removeAll();
    _history = [];
    notifyListeners();
  }
}
