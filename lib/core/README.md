# Core

## Purpose

Foundation layer containing constants, dependency injection, error handling, result types, theming, and value objects used across the entire application.

## Contents

### `constants/`

- `api_constants.dart` - Binance REST and WebSocket endpoint URLs.
- `app_constants.dart` - Durations for debouncing, throttling, animations, and timeouts.
- `app_opacity.dart` - Standardised opacity values (disabled, medium, high).
- `app_sizes.dart` - Spacing, border-radius, and icon-size scale.

### `di/`

- `service_locator.dart` - GetIt registration of all services, repositories, and providers.

### `errors/`

- `app_exception.dart` - Sealed exception hierarchy (Network, Parse, WebSocket, Storage) with optional `StackTrace`.

### `result/`

- `result.dart` - `Result<T>` sealed union (`Success` / `Failure`) with `map` and `when` convenience methods.

### `theme/`

- `app_theme.dart` - Dark theme configuration with `CryptoColors` theme extension.

### `logging/`

- `app_logger.dart` - Structured logging with debug/info/warning/error levels; silent in release.
- `logger.dart` - Abstract `Logger` interface and `LogLevel` enum for dependency injection.

### `value_objects/`

- `numeric_value.dart` - Abstract `NumericValue` base class providing shared formatting utilities.
- `percentage.dart` - Immutable percentage with formatting (`+2.45%`).
- `price.dart` - Immutable price with adaptive decimal precision and comma-separated formatting.
- `volume.dart` - Immutable volume with K/M/B suffix or comma-separated formatting.

Each value object provides two formatting options:
- `formatted` - Compact display (e.g., `1.25B`, `64523.45`)
- `formattedWithSeparators` - Comma-separated for readability (e.g., `1,250,000,000`, `64,523.45`)

## Dependencies

- `get_it` - service locator / DI container
- `http` - HTTP client (registered as singleton)
- `flutter` - `ThemeExtension`, `@immutable`

## Architecture Notes

- All constant classes use `abstract final class` to prevent instantiation.
- Value objects are `@immutable` and `final class` with `==`/`hashCode` overrides.
- `Result<T>` uses Dart 3 sealed classes for exhaustive pattern matching, with `map()` and `when()` convenience methods using switch expressions.
- The service locator owns the lifecycle of `http.Client` and `ObjectBox Store`.
