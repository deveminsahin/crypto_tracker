import 'package:crypto_tracker/core/logging/logger.dart';
import 'package:crypto_tracker/services/search_history_service.dart';
import 'package:flutter/foundation.dart';

/// Provider for managing search history with change notifications.
final class SearchHistoryProvider extends ChangeNotifier {
  static const _tag = 'SearchHistoryProvider';

  final SearchHistoryService _service;
  final Logger _logger;

  List<String> _history = [];
  List<String> get history => _history;

  SearchHistoryProvider(
    final SearchHistoryService service, {
    required final Logger logger,
  }) : _service = service,
       _logger = logger {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      _history = await _service.getRecentSearches();
      notifyListeners();
    } on Exception catch (e, s) {
      _logger.error(_tag, 'Failed to load search history', e, s);
    }
  }

  Future<void> addSearch(final String symbol) async {
    if (symbol.trim().isEmpty) return;
    try {
      await _service.addSearch(symbol);
      await _loadHistory();
    } on Exception catch (e, s) {
      _logger.error(_tag, 'Failed to add search entry', e, s);
    }
  }

  Future<void> clearHistory() async {
    try {
      await _service.clearHistory();
      _history = [];
      notifyListeners();
    } on Exception catch (e, s) {
      _logger.error(_tag, 'Failed to clear search history', e, s);
    }
  }
}
