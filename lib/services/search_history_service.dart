/// Contract for managing search history.
abstract interface class SearchHistoryService {
  /// Get the most recent search entries, limited to [limit].
  Future<List<String>> getRecentSearches({final int limit = 4});

  /// Add a symbol to search history.
  Future<void> addSearch(final String symbol);

  /// Clear all search history.
  Future<void> clearHistory();
}
