import 'package:crypto_tracker/core/constants/app_opacity.dart';
import 'package:crypto_tracker/core/constants/app_sizes.dart';
import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/l10n/l10n_extension.dart';
import 'package:crypto_tracker/models/market_category.dart';
import 'package:crypto_tracker/providers/market_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Horizontal row of selectable quote-asset category chips (All, USDT, BTC, ...).
final class CategoryTabBar extends StatelessWidget {
  const CategoryTabBar({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final selected = context.select<MarketProvider, MarketCategory>(
      (final provider) => provider.selectedCategory,
    );
    final colors = ColorScheme.of(context);
    final cryptoColors = CryptoColors.of(context);
    final textTheme = TextTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingSm),
      child: Row(
        children: MarketCategory.values
            .map((final category) {
              final (background, foreground, fontWeight) =
                  category == selected
                      ? (
                          cryptoColors.priceUp.withValues(
                            alpha: AppOpacity.selectedChip,
                          ),
                          cryptoColors.priceUp,
                          FontWeight.w600,
                        )
                      : (
                          colors.surfaceContainerHighest,
                          colors.onSurfaceVariant,
                          FontWeight.w400,
                        );

              return Padding(
                padding: const EdgeInsets.only(right: AppSizes.spacingSm),
                child: GestureDetector(
                  onTap: () =>
                      context.read<MarketProvider>().setCategory(category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingMd,
                      vertical: AppSizes.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadiusMd,
                      ),
                    ),
                    child: Text(
                      category.label(l10n),
                      style: textTheme.labelMedium?.copyWith(
                        color: foreground,
                        fontWeight: fontWeight,
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
