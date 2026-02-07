# Logging

## Purpose

Provides a centralized, structured logging service for the application.

## Contents

- `app_logger.dart` — `AppLogger` singleton with level-based logging

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

AppLogger.info('API', 'Fetching tickers');
AppLogger.error('API', 'Request failed', error, stackTrace);
```

## Behavior

- **Debug mode:** Logs to console via `dart:developer`
- **Release mode:** Silent unless `AppLogger.logHandler` is set

## Security

Never log:
- API keys or tokens
- User credentials
- Personal identifiable information
