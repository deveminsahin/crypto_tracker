import 'package:crypto_tracker/core/constants/app_sizes.dart';
import 'package:crypto_tracker/l10n/l10n_extension.dart';
import 'package:crypto_tracker/models/ticker.dart';
import 'package:flutter/material.dart';

part 'info_row.dart';

/// Card displaying key ticker statistics (high, low, volume, bid, ask).
final class DetailInfoGrid extends StatelessWidget {
  final Ticker ticker;

  const DetailInfoGrid({required this.ticker, super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacingMd),
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: ColorScheme.of(context).surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: l10n.label24hHigh,
            value: ticker.highPrice.formattedWithSeparators,
          ),
          const Divider(height: AppSizes.spacingLg),
          _InfoRow(
            label: l10n.label24hLow,
            value: ticker.lowPrice.formattedWithSeparators,
          ),
          const Divider(height: AppSizes.spacingLg),
          _InfoRow(
            label: l10n.label24hVolume,
            value: ticker.volume.formattedWithSeparators,
          ),
          const Divider(height: AppSizes.spacingLg),
          _InfoRow(
            label: l10n.labelQuoteVolume,
            value: ticker.quoteVolume.formattedWithSeparators,
          ),
          const Divider(height: AppSizes.spacingLg),
          _InfoRow(
            label: l10n.labelBidPrice,
            value: ticker.bidPrice.formattedWithSeparators,
          ),
          const Divider(height: AppSizes.spacingLg),
          _InfoRow(
            label: l10n.labelAskPrice,
            value: ticker.askPrice.formattedWithSeparators,
          ),
        ],
      ),
    );
  }
}
