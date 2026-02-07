/// Generic local persistence contract.
///
/// Implementations back this with a concrete storage engine (e.g. ObjectBox).
/// The type parameter [T] represents the domain model being stored.
abstract interface class LocalStorage<T> {
  /// One-time initialisation (no-op when the store is managed externally).
  Future<void> init();

  /// Retrieves all persisted items.
  Future<List<T>> getAll();

  /// Persists [items], replacing any existing entries with the same key.
  Future<void> putAll(final List<T> items);

  /// Removes all persisted items.
  Future<void> clear();

  /// Closes the backing store (no-op when managed externally).
  Future<void> close();
}
