# Router

## Purpose

Declarative navigation using `go_router` with navigation event logging.

## Contents

- `app_router.dart` - Route definitions and `AppRoutes` path constants.
- `app_navigation_observer.dart` - Logs push/pop/replace/remove navigation events.

## Dependencies

- `go_router` - Flutter team's official declarative routing package
- `core/logging` - App's logging infrastructure

## Usage

```dart
// Navigate to detail
context.push(AppRoutes.detailPath('BTCUSDT'));

// Extract symbol from route state
final symbol = AppRoutes.symbolFrom(state);
```

## Architecture Notes

- Two routes: market list (`/`) and market detail (`/detail/:symbol`).
- The router is registered as a lazy singleton in GetIt and injected into `MaterialApp.router`.
- `AppNavigationObserver` logs all navigation events using the injected `Logger` instance.
  - Extracts the **resolved path** (e.g., `/detail/BTCUSDT`) by substituting `:param` placeholders with actual values from GoRouter's `settings.arguments`.
  - Query parameters are stripped to avoid logging potentially sensitive user data.
