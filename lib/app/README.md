# App

## Purpose

Contains the root application widget that bootstraps the widget tree.

## Contents

- `app.dart` - `CryptoTrackerApp` root widget wiring Provider, GoRouter, theming, and localization.

## Dependencies

- `provider` - state management via `MultiProvider`
- `go_router` - declarative routing
- `flutter_localizations` - i18n support

## Usage

Instantiated once in `main.dart` after the service locator is initialised:

```dart
runApp(const CryptoTrackerApp());
```

## Architecture Notes

- `MarketProvider` is created via `ChangeNotifierProvider(create:)` (factory) so each Provider scope gets a fresh instance.
- `SearchHistoryProvider` uses `.value` because it is a singleton registered in `GetIt`.
