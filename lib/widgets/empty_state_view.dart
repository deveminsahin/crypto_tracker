import 'package:crypto_tracker/core/constants/app_opacity.dart';
import 'package:crypto_tracker/core/constants/app_sizes.dart';
import 'package:crypto_tracker/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

/// Illustrated empty state when no ticker pairs match the search/filter.
final class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final colors = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: AppSizes.iconXl,
              color: colors.onSurfaceVariant.withValues(
                alpha: AppOpacity.medium,
              ),
            ),
            const SizedBox(height: AppSizes.spacingMd),
            Text(
              l10n.noPairsFound,
              style: textTheme.titleMedium?.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Text(
              l10n.emptyStateHint,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
