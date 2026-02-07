import 'package:crypto_tracker/core/logging/logger.dart';
import 'package:flutter/widgets.dart';


/// Observes navigation events and logs them for debugging/analytics.
///
/// Tracks push, pop, replace, and remove operations on the navigator stack.
/// Extracts the actual resolved path (e.g., `/detail/BTCUSDT`) not the pattern.
///
/// Usage:
/// ```dart
/// GoRouter(
///   observers: [AppNavigationObserver(logger: logger)],
///   // ...
/// )
/// ```
///
/// **Security Note:** Query parameters are stripped to avoid leaking
/// potentially sensitive data.
final class AppNavigationObserver extends NavigatorObserver {
  static const _tag = 'Navigation';

  final Logger _logger;

  AppNavigationObserver({required final Logger logger}) : _logger = logger;

  @override
  void didPush(
    final Route<dynamic> route,
    final Route<dynamic>? previousRoute,
  ) {
    super.didPush(route, previousRoute);
    final name = _routeName(route);
    final from = _routeName(previousRoute);
    _logger.info(_tag, 'Push: $name (from: $from)');
  }

  @override
  void didPop(final Route<dynamic> route, final Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final name = _routeName(route);
    final to = _routeName(previousRoute);
    _logger.info(_tag, 'Pop: $name (to: $to)');
  }

  @override
  void didReplace({
    final Route<dynamic>? newRoute,
    final Route<dynamic>? oldRoute,
  }) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final newName = _routeName(newRoute);
    final oldName = _routeName(oldRoute);
    _logger.info(_tag, 'Replace: $oldName → $newName');
  }

  @override
  void didRemove(
    final Route<dynamic> route,
    final Route<dynamic>? previousRoute,
  ) {
    super.didRemove(route, previousRoute);
    final name = _routeName(route);
    _logger.info(_tag, 'Remove: $name');
  }

  /// Extracts the actual resolved path from the route.
  ///
  /// GoRouter stores path parameters in `settings.arguments` as a Map.
  /// We use these to substitute `:param` placeholders in the pattern name.
  /// Query parameters are stripped to avoid logging user data.
  String _routeName(final Route<dynamic>? route) {
    if (route == null) return 'unknown';

    final settings = route.settings;
    var name = settings.name;
    if (name == null || name.isEmpty) return 'unknown';

    // GoRouter stores path parameters in arguments as Map<String, String>
    final arguments = settings.arguments;
    if (arguments is Map<String, String>) {
      // Substitute :param placeholders with actual values
      for (final entry in arguments.entries) {
        name = name!.replaceAll(':${entry.key}', entry.value);
      }
    }

    // Strip query params to avoid logging user data
    final uri = Uri.tryParse(name!);
    return uri?.path ?? name;
  }
}
