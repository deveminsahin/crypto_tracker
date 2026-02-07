part of '../market_list_screen.dart';

final class _MarketListBody extends StatelessWidget {
  final ScrollController scrollController;

  const _MarketListBody({required this.scrollController});

  @override
  Widget build(final BuildContext context) {
    final isLoading = context.select<MarketProvider, bool>(
      (final provider) => provider.isLoading,
    );
    final error = context.select<MarketProvider, AppException?>(
      (final provider) => provider.error,
    );

    if (isLoading) {
      return const TickerListSkeleton();
    }

    if (error != null) {
      return ErrorDisplay(
        exception: error,
        onRetry: () => context.read<MarketProvider>().forceReload(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<MarketProvider>().retry(),
      child: TickerListView(scrollController: scrollController),
    );
  }
}
