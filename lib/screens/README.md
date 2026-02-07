# Screens

## Purpose

Top-level screen widgets and their decomposed child widgets.

## Contents

### `market_list/`

- `market_list_screen.dart` - Main screen with search, filters, sort, and ticker list.
- `widgets/category_tab_bar.dart` - Quote-asset category chips.
- `widgets/market_search_field.dart` - Symbol search text field.
- `widgets/search_history_chips.dart` - Recent search history action chips.
- `widgets/sort_header.dart` - Sortable column header row.
- `widgets/ticker_list_view.dart` - Scrollable `ListView.builder` of ticker rows.
- `widgets/ticker_row.dart` - Single ticker row with price-flash animation.

### `market_detail/`

- `market_detail_screen.dart` - Detail screen for a single trading pair.
- `widgets/price_header.dart` - Symbol and large current price.
- `widgets/price_change_card.dart` - 24h change and percentage badge.
- `widgets/price_range_bar.dart` - Visual low-high range bar with position indicator.
- `widgets/detail_info_grid.dart` - Key statistics grid (high, low, volume, bid, ask).

## Dependencies

- `provider` - state access via `context.watch` / `context.select`
- `go_router` - navigation between screens

## Architecture Notes

- `Selector` is used for granular rebuilds (e.g. only on category change or WS state change).
- `RepaintBoundary` isolates frequently-updating sections (price header, flash animation).
- `TickerListView` uses fixed `itemExtent` and `addAutomaticKeepAlives: false` for scroll performance.
- Each widget gets its own file, following the single-responsibility principle.
