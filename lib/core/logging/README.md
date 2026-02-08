# Logging

## Purpose

Provides a centralized, structured logging service for the application.

## Contents

- `app_logger.dart` — `AppLogger` implementation with level-based logging
- `logger.dart` — Abstract `Logger` interface for dependency injection

## Log Levels

| Level | Usage |
|-------|-------|
| `debug` | Verbose dev-only information |
| `info` | General operational events |
| `warning` | Recoverable issues |
| `error` | Exceptions and failures |

## Usage

```dart
import 'package:crypto_tracker/core/logging/app_logger.dart';

final logger = AppLogger();
logger.info('API', 'Fetching tickers');
logger.error('API', 'Request failed', error, stackTrace);
```

## Behavior

- **Debug mode:** Logs to console via `dart:developer`
- **Release mode:** Silent unless `logHandler` is set on the `AppLogger` instance

## Security

Never log:
- API keys or tokens
- User credentials
- Personal identifiable information
