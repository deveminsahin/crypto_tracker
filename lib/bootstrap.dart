import 'dart:async';
import 'dart:ui';

import 'package:crypto_tracker/app/app.dart';
import 'package:crypto_tracker/core/di/service_locator.dart';
import 'package:crypto_tracker/core/logging/logger.dart';
import 'package:flutter/material.dart';

/// Bootstraps the application with global error handling.
///
/// Sets up three error boundaries:
/// - [FlutterError.onError] for framework errors (build, layout, painting)
/// - [PlatformDispatcher.instance.onError] for platform-level errors
/// - [runZonedGuarded] for uncaught async errors
Future<void> bootstrap() => runZonedGuarded(
  () async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await setupServiceLocator();
    } on Exception catch (e) {
      debugPrint('Fatal initialisation error: $e');
      runApp(_FatalErrorApp(message: e.toString()));
      return;
    }

    final logger = sl<Logger>();

    FlutterError.onError = (final details) {
      logger.error(
        'FlutterError',
        details.exceptionAsString(),
        details.exception,
        details.stack,
      );
    };

    PlatformDispatcher.instance.onError =
        (final Object error, final StackTrace stack) {
          logger.error('PlatformError', 'Platform error', error, stack);
          return true;
        };

    runApp(const CryptoTrackerApp());
  },
  (final Object error, final StackTrace stack) {
    try {
      sl<Logger>().error('ZoneError', 'Uncaught async error', error, stack);
    } on Exception {
      debugPrint('Uncaught async error: $error\n$stack');
    }
  },
)!;

final class _FatalErrorApp extends StatelessWidget {
  final String message;

  const _FatalErrorApp({required this.message});

  @override
  Widget build(final BuildContext context) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Unable to start the app.\n\n$message',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
