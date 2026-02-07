# Widgets

## Purpose

Reusable UI components shared across multiple screens.

## Contents

- `shimmer.dart` - `Shimmer` ancestor widget and `ShimmerLoading` child for coordinated shimmer animation.
- `ticker_list_skeleton.dart` - Full-screen skeleton loading view with multiple shimmer rows.
- `ticker_row_skeleton.dart` - Single skeleton row placeholder (part of `ticker_list_skeleton.dart`).
- `empty_state_view.dart` - Illustrated empty state when no tickers match search/filter.
- `error_display.dart` - Full-screen error state with localized message and retry button.
- `pulsing_dot.dart` - Animated pulsing dot indicator (part of `ws_connection_indicator.dart`).
- `ws_connection_indicator.dart` - WebSocket connection status dot with label.

## Dependencies

- `core/theme/` - `CryptoColors` for themed colours
- `core/constants/` - `AppSizes`, `AppOpacity`, `AppConstants`
- `l10n/` - Localized strings

## Architecture Notes

- `Shimmer` uses an ancestor-state pattern (`findAncestorStateOfType`) so multiple `ShimmerLoading` children share one animation controller.
- `pulsing_dot.dart` and `ticker_row_skeleton.dart` use Dart `part` directives to keep related widgets co-located.
- All widgets follow the single-responsibility principle and use `const` constructors.
