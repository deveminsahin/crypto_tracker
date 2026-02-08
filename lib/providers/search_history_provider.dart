import 'package:crypto_tracker/services/search_history_service.dart';
import 'package:flutter/foundation.dart';

/// Provider for managing search history with change notifications.
final class SearchHistoryProvider extends ChangeNotifier {
  final SearchHistoryService _service;

  List<String> _history = [];
  List<String> get history => _history;

  SearchHistoryProvider(final SearchHistoryService service)
    : _service = service {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _history = await _service.getRecentSearches();
    notifyListeners();
  }

  Future<void> addSearch(final String symbol) async {
    if (symbol.trim().isEmpty) return;
    await _service.addSearch(symbol);
    await _loadHistory();
  }

  Future<void> clearHistory() async {
    await _service.clearHistory();
    _history = [];
    notifyListeners();
  }
}
