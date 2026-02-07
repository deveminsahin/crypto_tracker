import 'package:crypto_tracker/app/app.dart';
import 'package:crypto_tracker/core/di/service_locator.dart';
import 'package:flutter/material.dart';

/// Application entry point.
///
/// Initialises the Flutter binding, sets up the service locator
/// (which opens the ObjectBox store), then launches the root widget.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const CryptoTrackerApp());
}
