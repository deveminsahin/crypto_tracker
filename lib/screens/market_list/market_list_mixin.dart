part of 'market_list_screen.dart';

/// Encapsulates all non-UI behaviour for [MarketListScreen]:
/// provider lifecycle, WebSocket snackbars, search debouncing,
/// and scroll-to-top logic.
mixin _MarketListMixin on State<MarketListScreen> {
  final searchController = TextEditingController();
  final scrollController = ScrollController();
  Timer? _debounceTimer;
  bool showScrollToTop = false;
  WsConnectionState _lastWsState = WsConnectionState.disconnected;
  MarketProvider? _provider;

  // ── Lifecycle ──────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MarketProvider>();
      _provider = provider;
      provider
        ..addListener(_onProviderChanged)
        ..loadMarketData();
    });
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChanged);
    searchController.dispose();
    scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ── Provider listener ──────────────────────────────────────────────

  void _onProviderChanged() {
    if (!mounted) return;

    final provider = _provider!;

    // Fast path: skip expensive lookups when nothing we care about changed.
    if (provider.refreshError == null && provider.wsState == _lastWsState) {
      return;
    }

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final refreshError = provider.refreshError;
    if (refreshError != null) {
      provider.clearRefreshError();
      _lastWsState = provider.wsState;
      _showRetrySnackBar(messenger, refreshError.localizedMessage(l10n), l10n);
      return;
    }

    final wsState = provider.wsState;
    if (wsState != _lastWsState) {
      final wasConnected = _lastWsState == WsConnectionState.connected;
      _lastWsState = wsState;

      if (wsState == WsConnectionState.connected) {
        messenger.hideCurrentSnackBar();
      } else if (wasConnected &&
          (wsState == WsConnectionState.error ||
              wsState == WsConnectionState.disconnected)) {
        _showRetrySnackBar(messenger, l10n.errorWebSocket, l10n);
      }
    }
  }

  void _showRetrySnackBar(
    final ScaffoldMessengerState messenger,
    final String message,
    final AppLocalizations l10n,
  ) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: l10n.retryButton,
            onPressed: _provider!.retry,
          ),
        ),
      );
  }

  // ── Scroll ─────────────────────────────────────────────────────────

  void _onScroll() {
    final show = scrollController.offset > AppConstants.scrollToTopThreshold;
    if (show != showScrollToTop) {
      setState(() => showScrollToTop = show);
    }
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: AppConstants.scrollAnimationDuration,
      curve: Curves.easeOutCubic,
    );
  }

  // ── Search ─────────────────────────────────────────────────────────

  void onSearchChanged(final String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(AppConstants.searchDebounceDuration, () {
      context.read<MarketProvider>().setSearchQuery(query);
    });
  }
}
