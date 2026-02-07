import 'package:crypto_tracker/core/constants/app_sizes.dart';
import 'package:crypto_tracker/l10n/l10n_extension.dart';
import 'package:crypto_tracker/providers/search_history_provider.dart';
import 'package:crypto_tracker/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Displays recent search history as tappable chips.
/// Tapping a chip navigates directly to the detail screen.
final class SearchHistoryChips extends StatelessWidget {
  const SearchHistoryChips({super.key});

  @override
  Widget build(final BuildContext context) {
    final history = context.select<SearchHistoryProvider, List<String>>(
      (final provider) => provider.history,
    );

    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final colorScheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recentSearches,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXs),
          Wrap(
            spacing: AppSizes.spacingSm,
            children: history
                .map(
                  (final symbol) => ActionChip(
                    label: Text(symbol),
                    onPressed: () => context.push(AppRoutes.detailPath(symbol)),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    labelStyle: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingSm,
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}
