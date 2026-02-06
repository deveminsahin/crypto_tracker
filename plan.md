# Crypto Tracker — Implementation Plan

## Context

This is a Flutter developer case study for **baseinteractive**. The app lists crypto markets from the Binance public API, shows real-time price updates via WebSocket, and provides a detail screen for each trading pair. We referenced the İş Yatırım app for UX patterns (category filtering, Low-High range bar, dark theme styling).

The case study explicitly requires **Provider** for state management. We implement WebSocket (optional in the case study) for extra points and to demonstrate engineering depth.

Our engineering principles demand: 60fps minimum, profile-mode memory verification, isolates for heavy computation, const/final everywhere, RepaintBoundary on live elements, SOLID, DRY, design patterns, clean code, value objects, and test-ready architecture.

---

## Decisions Made

| # | Decision | Reasoning |
|---|----------|-----------|
| 1 | WebSocket: YES | Extra points, demonstrates real-time engineering |
| 2 | Category tabs: USDT, BTC, ETH, BNB | Inspired by İş Yatırım app. Solves 2000+ pairs UX/perf problem |
| 3 | Dark theme | Industry standard for crypto apps. Green/red stand out better on dark |
| 4 | iOS & Android only | Mobile focus, standard expectation for the case study |
| 5 | Provider (required) | Case study explicitly mandates Provider |
| 6 | go_router for Navigator 2.0 | Declarative routing, Flutter team's official package |
| 7 | Long-lived isolate for WS | Avoids ~2ms spawn overhead per message. compute() for one-shot REST only |
| 8 | Value Objects for numbers | Price, Volume, Percentage — no primitive doubles. Business logic lives in the object |
| 9 | Dependencies: provider, http, web_socket_channel, go_router | Each justified. Minimal |
| 10 | Low-High range bar in detail | Inspired by İş Yatırım detail screen |
| 11 | Feature branches + granular commits | Real engineering workflow. No huge commits. Each commit is 1-2 files max. |

---

## Git Workflow

**Branching strategy:**
- `main` — stable. Only receives merges from completed feature branches.
- Feature branches per logical unit: `feature/project-setup`, `feature/core-layer`, `feature/data-models`, etc.
- Each feature branch has small, atomic commits (1-2 files per commit).
- Merge to `main` when the feature is complete and compiles.

**Branch sequence:**
1. `feature/project-setup` — git init, guidelines, lint rules, dependencies
2. `feature/core-layer` — constants, theme, value objects, error types
3. `feature/data-models` — Ticker, MiniTicker, MarketCategory
4. `feature/services` — API service, WS config, WS service, isolate parser
5. `feature/router` — go_router configuration
6. `feature/state-management` — MarketProvider
7. `feature/shared-widgets` — loading, error, price text
8. `feature/market-list` — list screen and its widgets
9. `feature/market-detail` — detail screen and its widgets
10. `feature/app-wiring` — main.dart entry point, Provider + Router wiring
11. `feature/documentation` — README, final guidelines update

**Commit discipline:**
- Each commit touches 1-2 files maximum
- Every commit message follows conventional commits (`feat:`, `chore:`, `docs:`)
- Every commit compiles (no broken intermediate states)
- No magic numbers, no magic strings in any committed file

---

## API Data Mapping

### REST: `GET https://api.binance.com/api/v3/ticker/24hr`
All price/volume fields are **strings**. Key fields we use:
- `symbol`, `lastPrice`, `priceChange`, `priceChangePercent`, `highPrice`, `lowPrice`, `volume`, `quoteVolume`, `bidPrice`, `askPrice`, `openPrice`, `weightedAvgPrice`

### WebSocket: `wss://stream.binance.com:9443/ws/!miniTicker@arr`
Fires every ~1 second. Fields (short keys, all strings):
- `s` (symbol), `c` (close/lastPrice), `o` (open), `h` (high), `l` (low), `v` (volume), `q` (quoteVolume)

**Critical gap**: WebSocket does NOT provide `bidPrice`, `askPrice`, `priceChange`, `priceChangePercent`. We must:
- Compute: `priceChange = c - o`, `priceChangePercent = ((c - o) / o) * 100`
- Preserve: `bidPrice`, `askPrice` from initial REST load

---

## Step 0 — Update ENGINEERING_GUIDELINES.md

Add these sections to the existing guidelines file:

**Software Engineering Principles:**
- **SOLID**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion — applied at every layer
- **DRY**: Extract shared logic into value objects, utilities, or base classes. No copy-paste.
- **Design Patterns**: Factory (model parsing), Observer (Provider/ChangeNotifier), Strategy (category filtering), Value Object (Price, Volume, Percentage). Applied where they solve real problems, never forced.
- **Clean Code**: Explanatory function names, meaningful variable names, self-documenting code. No abbreviations that aren't universally understood. No magic numbers.

**Provider Best Practices:**
- `context.read<T>()` for one-time access (event handlers, initState callbacks)
- `context.watch<T>()` or `Consumer<T>` only when the widget needs to rebuild
- `Selector<T, R>` for granular rebuilds — select only the data the widget needs
- Never call `notifyListeners()` inside a constructor or synchronous build
- Inject services via constructor (Dependency Inversion)

**Widget Architecture:**
- Avoid `StatefulWidget` — use only when owning a controller lifecycle (TextEditingController, AnimationController) or WidgetsBindingObserver
- Prefer composition over inheritance
- Test-ready: all services injected, no singletons, no static mutable state

**Testability:**
- Architecture is test-ready: services are injectable, providers accept service instances via constructor
- No hard dependencies on concrete implementations where abstraction is warranted
- We do NOT write tests in this phase, but every class is testable in isolation

Update the Decision Log table with all decisions.

---

## Step 1 — Branch: `feature/project-setup`

**Commit 1a:** `chore: initialize git repository`
- `git init`, initial commit with existing .gitignore

**Commit 1b:** `chore: update engineering guidelines with SOLID, DRY, and clean code principles`
- Update `ENGINEERING_GUIDELINES.md` with all new sections (SOLID, DRY, Provider best practices, widget architecture, testability, decision log)

**Commit 1c:** `chore: configure strict lint rules in analysis_options`
- `analysis_options.yaml` — add: `prefer_const_constructors`, `prefer_const_declarations`, `prefer_const_literals_to_create_immutables`, `prefer_final_fields`, `prefer_final_locals`, `prefer_final_in_for_each`, `avoid_print`, `avoid_unnecessary_containers`, `sized_box_for_whitespace`, `use_key_in_widget_constructors`, `prefer_single_quotes`

**Commit 1d:** `chore: add provider, http, web_socket_channel, and go_router dependencies`
- `pubspec.yaml` — add 4 dependencies, each with justification comment
- `flutter pub get`

**Merge to main.**

---

## Step 2 — Branch: `feature/core-layer`

**Commit 2a:** `feat: add API and app constants`
- `lib/core/constants/api_constants.dart` — `abstract final class ApiConstants`, REST base URL, ticker path, WS URL. All `static const`.
- `lib/core/constants/app_constants.dart` — search debounce 300ms, WS throttle 500ms, WS reconnect delay 3s, max reconnect 5. All named `static const`.

**Commit 2b:** `feat: add sealed AppException hierarchy`
- `lib/core/errors/app_exception.dart` — sealed class with NetworkException, ParseException, WebSocketException. Each `final class`.

**Commit 2c:** `feat: add Price value object`
- `lib/core/value_objects/price.dart` — immutable, `fromString` factory, operator overloads, `formatted` getter with named threshold constants, value-based equality.

**Commit 2d:** `feat: add Volume value object`
- `lib/core/value_objects/volume.dart` — immutable, `fromString` factory, `formatted` getter with K/M/B abbreviation, `compareTo`, value-based equality.

**Commit 2e:** `feat: add Percentage value object`
- `lib/core/value_objects/percentage.dart` — immutable, `fromString`, `fromPrices` factory (computes from Price objects), `formatted` getter (+/-%), `isPositive`/`isNegative`, value-based equality.

**Commit 2f:** `feat: add dark theme configuration`
- `lib/core/theme/app_theme.dart` — `abstract final class AppTheme` with `static ThemeData get darkTheme`. All colors as named `static const Color` (navy `scaffoldBackground`, `cardBackground`, `priceUpColor`, `priceDownColor`, `textPrimary`, `textSecondary`, `dividerColor`, `searchFieldBackground`). Text styles, input decoration, app bar theme centralized.

**Why Value Objects (not primitives):**
- Formatting logic lives WITH the data, not scattered across widgets (DRY)
- Business rules encapsulated (SRP) — e.g., Percentage.fromPrices
- Type safety: can't pass Volume where Price expected
- Equality is value-based
- Each handles null/malformed API data via `fromString`

**Merge to main.**

---

## Step 3 — Branch: `feature/data-models`

**Commit 3a:** `feat: add MarketCategory enum with symbol matching`
- `lib/models/market_category.dart` — enum with `usdt`, `btc`, `eth`, `bnb`. Each has `label`. `matches(String symbol)` with priority waterfall to prevent BTCUSDT appearing in BTC tab.

**Commit 3b:** `feat: add MiniTicker model for WebSocket events`
- `lib/models/mini_ticker.dart` — `final class MiniTicker`, fields use Value Objects (Price, Volume). `factory fromWsJson` maps short keys (s, c, o, h, l, v, q).

**Commit 3c:** `feat: add Ticker model with REST parsing and WebSocket merge`
- `lib/models/ticker.dart` — `final class Ticker`, immutable, all fields are Value Objects. `factory fromRestJson` parses string fields. `mergeWithMiniTicker` fuses WS data (updates OHLCV, computes change/changePercent via Percentage.fromPrices, preserves bidPrice/askPrice). `operator ==` and `hashCode` on symbol + lastPrice.

**Merge to main.**

---

## Step 4 — Branch: `feature/services`

**Commit 4a:** `feat: add API service for REST ticker data`
- `lib/services/api_service.dart` — `final class ApiService`. Constructor accepts `http.Client` (DI). `fetchTickersRaw()` returns raw JSON string (no parsing on main isolate). Throws `NetworkException`. `dispose()` closes client.

**Commit 4b:** `feat: add WebSocket configuration`
- `lib/services/websocket_config.dart` — `final class WebSocketConfig` with url, reconnectDelay, maxReconnectAttempts. `static const production` default. Separates config from service (SRP, Open/Closed). Injectable for testing.

**Commit 4c:** `feat: add WebSocket service with reconnection logic`
- `lib/services/websocket_service.dart` — `final class WebSocketService`. Constructor accepts `WebSocketConfig` (DI). `Stream<String> messages` broadcast stream. `connect()`, `disconnect()`, `_scheduleReconnect()` with linear backoff. `_isDisposed` flag prevents zombie reconnections. Emits `WebSocketException` on max attempts exceeded.

**Commit 4d:** `feat: add isolate parser with long-lived WS isolate`
- `lib/services/isolate_parser.dart` — `final class IsolateParser`. REST parsing via `compute()` (one-shot). WS parsing via long-lived `Isolate.spawn` + `SendPort`/`ReceivePort` (spawns once, reuses). `initialize()`, `parseMiniTickers()`, `dispose()`. Top-level functions for isolate entry points. `toList(growable: false)`.

**Why long-lived isolate for WS**: compute() has ~2ms spawn overhead per call. At 500ms throttle = 2 spawns/sec. Long-lived isolate spawns once — zero repeated overhead.

**Merge to main.**

---

## Step 5 — Branch: `feature/router`

**Commit 5a:** `feat: configure go_router with declarative route definitions`
- `lib/router/app_router.dart` — `GoRouter` with `initialLocation: '/'`. Routes: `/` → MarketListScreen, `/detail/:symbol` → MarketDetailScreen. Type-safe path parameters. Deep-linkable.

**Merge to main.**

---

## Step 6 — Branch: `feature/state-management`

**Commit 6a:** `feat: implement MarketProvider with REST data loading`
- `lib/providers/market_provider.dart` — `final class MarketProvider extends ChangeNotifier`. Constructor injection of ApiService, WebSocketService, IsolateParser (SOLID - DI). `loadMarketData()`, `_applyFilters()`, `setCategory()`, `setSearchQuery()`, `tickerBySymbol()`, `retry()`. Loading/error state management.

**Commit 6b:** `feat: add WebSocket integration with throttled updates to MarketProvider`
- Same file — add `_startWebSocket()`, `_onWsMessage()`, `_flushWebSocketBuffer()`, `dispose()`. Buffer + Timer.periodic(500ms) throttling. Long-lived isolate usage.

**Data structures (evaluated choices):**
- `Map<String, Ticker> _tickers` — **HashMap** for O(1) lookup. Essential for WS merge.
- `UnmodifiableListView<Ticker> _filteredTickers` — exposed unmodifiable. Prevents external mutation.
- `MarketCategory _selectedCategory` — enum, not raw string.
- `String _searchQuery` — UI input, not domain data. No value object needed.
- `bool _isLoading`, `AppException? _error` — simple state flags.

**Why Map not List**: WS sends ~300 updated tickers/message. Map: O(1) per ticker = O(m). List: O(n) per ticker = O(n*m). For n=2000, m=300: 300 vs 600,000 operations.

**WS throttle**: Buffer raw messages. Timer.periodic(500ms) flushes. Takes LAST message only. notifyListeners() max 2x/sec.

**Merge to main.**

---

## Step 7 — Branch: `feature/shared-widgets`

**Commit 7a:** `feat: add loading indicator widget`
- `lib/widgets/loading_indicator.dart` — `const` StatelessWidget. Centered CircularProgressIndicator.

**Commit 7b:** `feat: add error display widget with retry`
- `lib/widgets/error_display.dart` — StatelessWidget. Takes `AppException` + `VoidCallback onRetry`. Error icon, user-facing message, retry button.

**Commit 7c:** `feat: add color-coded price text widget`
- `lib/widgets/price_text.dart` — StatelessWidget. Takes `Price` value object. Uses `price.formatted` (DRY — formatting lives in value object, not widget). Green/red based on direction.

**Merge to main.**

---

## Step 8 — Branch: `feature/market-list`

**Commit 8a:** `feat: add market search field widget`
- `lib/screens/market_list/widgets/market_search_field.dart` — StatelessWidget. Controller + onChanged from parent. Dark TextField, search icon, rounded border.

**Commit 8b:** `feat: add category tab bar widget`
- `lib/screens/market_list/widgets/category_tab_bar.dart` — StatelessWidget with `Selector<MarketProvider, MarketCategory>`. Row of 4 tabs. Only rebuilds on category change.

**Commit 8c:** `feat: add ticker row widget`
- `lib/screens/market_list/widgets/ticker_row.dart` — StatelessWidget. Takes `final Ticker`. Three columns: symbol | lastPrice (via value object `formatted`) | change% badge. Navigates via `context.go('/detail/${ticker.symbol}')`. All `const` styles.

**Commit 8d:** `feat: add ticker list view with RepaintBoundary`
- `lib/screens/market_list/widgets/ticker_list_view.dart` — StatelessWidget with `Selector<MarketProvider, UnmodifiableListView<Ticker>>`. `ListView.builder` with `itemExtent: 64`. `RepaintBoundary` + `ValueKey` per row.

**Commit 8e:** `feat: add market list screen with data loading`
- `lib/screens/market_list/market_list_screen.dart` — **StatefulWidget** (justified: owns TextEditingController + debounce Timer). Triggers `loadMarketData()` in initState. Composes search + tabs + list. `Selector` for loading/error state only.

**Merge to main.**

---

## Step 9 — Branch: `feature/market-detail`

**Commit 9a:** `feat: add price header widget for detail screen`
- `lib/screens/market_detail/widgets/price_header.dart` — StatelessWidget. Large `lastPrice.formatted`, symbol name, color-coded.

**Commit 9b:** `feat: add price change card widget`
- `lib/screens/market_detail/widgets/price_change_card.dart` — StatelessWidget. `priceChange.formatted` + `priceChangePercent.formatted`. Value object formatting (DRY).

**Commit 9c:** `feat: add price range bar visualization`
- `lib/screens/market_detail/widgets/price_range_bar.dart` — StatelessWidget. Low-High visual bar. Position: `((lastPrice.value - lowPrice.value) / (highPrice.value - lowPrice.value)).clamp(0.0, 1.0)`. Green-to-red gradient with position indicator.

**Commit 9d:** `feat: add detail info grid widget`
- `lib/screens/market_detail/widgets/detail_info_grid.dart` — StatelessWidget. 2-column grid: highPrice/lowPrice, volume/quoteVolume, bidPrice/askPrice. Uses `price.formatted`, `volume.formatted`.

**Commit 9e:** `feat: add market detail screen with Selector`
- `lib/screens/market_detail/market_detail_screen.dart` — StatelessWidget. `Selector<MarketProvider, Ticker?>` with `tickerBySymbol(symbol)`. Composes all detail widgets with `RepaintBoundary` around each.

**Merge to main.**

---

## Step 10 — Branch: `feature/app-wiring`

**Commit 10a:** `feat: wire main.dart with Provider, go_router, and dark theme`
- `lib/main.dart` — replace counter boilerplate. `CryptoTrackerApp` StatelessWidget. `ChangeNotifierProvider<MarketProvider>` at root with injected services. `MaterialApp.router` with `routerConfig: appRouter`. `AppTheme.darkTheme`. `debugShowCheckedModeBanner: false`.

**Merge to main. App is fully functional at this point.**

---

## Step 11 — Branch: `feature/documentation`

**Commit 11a:** `docs: update README with architecture and setup instructions`
- `README.md` — project description, how to run, architecture overview (value objects → models → services → providers → screens), state management (Provider + Selector), navigation (go_router), technical decisions, performance approach, screenshots placeholder.

**Commit 11b:** `docs: finalize engineering guidelines with all decisions`
- `ENGINEERING_GUIDELINES.md` — update Decision Log with all 11 decisions.

**Merge to main.**

---

## Folder Structure (Final)

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── value_objects/
│   │   ├── price.dart
│   │   ├── volume.dart
│   │   └── percentage.dart
│   └── errors/
│       └── app_exception.dart
├── models/
│   ├── ticker.dart
│   ├── mini_ticker.dart
│   └── market_category.dart
├── services/
│   ├── api_service.dart
│   ├── websocket_config.dart
│   ├── websocket_service.dart
│   └── isolate_parser.dart
├── router/
│   └── app_router.dart
├── providers/
│   └── market_provider.dart
├── screens/
│   ├── market_list/
│   │   ├── market_list_screen.dart
│   │   └── widgets/
│   │       ├── market_search_field.dart
│   │       ├── category_tab_bar.dart
│   │       ├── ticker_list_view.dart
│   │       └── ticker_row.dart
│   └── market_detail/
│       ├── market_detail_screen.dart
│       └── widgets/
│           ├── price_header.dart
│           ├── price_change_card.dart
│           ├── price_range_bar.dart
│           └── detail_info_grid.dart
└── widgets/
    ├── loading_indicator.dart
    ├── error_display.dart
    └── price_text.dart
```

**30 Dart files total.** Each has a single responsibility.

---

## Data Flow

```
REST API → ApiService (raw String)
  → IsolateParser.parseRestTickers (compute(), background isolate, one-shot)
  → List<Ticker> (with Value Objects)
  → MarketProvider._tickers (Map<String, Ticker>)

WebSocket → WebSocketService (uses WebSocketConfig)
  → Stream<String> → MarketProvider buffers raw messages
  → Timer.periodic(500ms) flushes buffer
  → IsolateParser.parseMiniTickers (long-lived isolate, reused)
  → List<MiniTicker>
  → MarketProvider: ticker.mergeWithMiniTicker(mini)
    → Computes priceChange, priceChangePercent via Value Objects
    → Preserves bidPrice, askPrice from REST
  → _applyFilters() → UnmodifiableListView<Ticker>
  → notifyListeners() (max 2x/sec)

UI reads via Selector → rebuilds only what changed
Navigation via go_router → /detail/:symbol
```

---

## Verification

After implementation, verify in **profile mode** (`flutter run --profile`):

1. Scroll market list rapidly — all frames < 16ms
2. Watch list 30 seconds — WS updates cause no frame drops
3. Navigate to detail — smooth transition, no jank
4. Watch detail 30 seconds — smooth real-time price updates
5. Search while WS active — no stutter during typing
6. Switch category tabs — immediate response
7. Memory tab: check baseline, then verify no leaks after 5 minutes
8. Kill network (airplane mode) — error UI appears, restore — recovery works
9. Navigate back from detail — no memory growth (proper disposal)
10. Verify isolate is alive and reused (not respawned per WS message)
