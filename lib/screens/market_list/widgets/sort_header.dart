import 'package:crypto_tracker/core/constants/app_sizes.dart';
import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/l10n/app_localizations.dart';
import 'package:crypto_tracker/l10n/l10n_extension.dart';
import 'package:crypto_tracker/providers/market_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Maps each [SortOption] to a localized column label.
extension SortOptionL10n on SortOption {
  String label(final AppLocalizations l10n) => switch (this) {
    SortOption.symbol => l10n.sortSymbol,
    SortOption.price => l10n.sortPrice,
    SortOption.changePercent => l10n.sortChange,
    SortOption.volume => l10n.sortVolume,
  };
}

/// Header row with sortable column labels.
final class SortHeader extends StatelessWidget {
  const SortHeader({super.key});


  @override
  Widget build(final BuildContext context) {
    final (sortOption, sortDirection) =
        context.select<MarketProvider, (SortOption, SortDirection)>(
          (final provider) => (provider.sortOption, provider.sortDirection),
        );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingSm),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _SortButton(
              option: SortOption.symbol,
              activeOption: sortOption,
              direction: sortDirection,
            ),
          ),
          Expanded(
            flex: 3,
            child: _SortButton(
              option: SortOption.price,
              activeOption: sortOption,
              direction: sortDirection,
              alignEnd: true,
            ),
          ),
          const SizedBox(width: AppSizes.priceColumnGap),
          SizedBox(
            width: AppSizes.badgeColumnWidth,
            child: _SortButton(
              option: SortOption.changePercent,
              activeOption: sortOption,
              direction: sortDirection,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final SortOption option;
  final SortOption activeOption;
  final SortDirection direction;
  final bool alignEnd;


  const _SortButton({
    required this.option,
    required this.activeOption,
    required this.direction,
    this.alignEnd = false,
  });

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final cryptoColors = CryptoColors.of(context);
    final isActive = activeOption == option && direction != SortDirection.none;

    final (foreground, fontWeight) = isActive
        ? (cryptoColors.priceUp, FontWeight.w600)
        : (ColorScheme.of(context).onSurfaceVariant, FontWeight.w400);

    return GestureDetector(
      onTap: () => context.read<MarketProvider>().setSortOption(option),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Text(
            option.label(l10n),
            style: TextTheme.of(context).labelMedium?.copyWith(
              color: foreground,
              fontWeight: fontWeight,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: AppSizes.spacingXxs),
            Icon(
              direction == SortDirection.desc
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              size: AppSizes.iconSm,
              color: cryptoColors.priceUp,
            ),
          ],
        ],
      ),
    );
  }
}
