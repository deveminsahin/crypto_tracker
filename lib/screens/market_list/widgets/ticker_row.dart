import 'package:crypto_tracker/core/constants/app_constants.dart';
import 'package:crypto_tracker/core/constants/app_opacity.dart';
import 'package:crypto_tracker/core/constants/app_sizes.dart';
import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/models/ticker.dart';
import 'package:crypto_tracker/providers/search_history_provider.dart';
import 'package:crypto_tracker/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

part 'ticker_row_mixin.dart';

/// A single ticker row in the market list with a price-flash animation.
///
/// Flashes green/red when the price changes, using a fade-out animation.
/// Animation lifecycle lives in [_TickerRowAnimationMixin].
final class TickerRow extends StatefulWidget {
  final Ticker ticker;

  const TickerRow({required this.ticker, super.key});

  @override
  State<TickerRow> createState() => _TickerRowState();
}

class _TickerRowState extends State<TickerRow>
    with SingleTickerProviderStateMixin, _TickerRowAnimationMixin {
  static const double _badgePaddingVertical = 6;

  void _onTap() {
    context.read<SearchHistoryProvider>().addSearch(widget.ticker.symbol);
    context.push(AppRoutes.detailPath(widget.ticker.symbol));
  }

  @override
  Widget build(final BuildContext context) {
    final ticker = widget.ticker;
    final textTheme = TextTheme.of(context);
    final cryptoColors = CryptoColors.of(context);
    final changeColor = ticker.priceChangePercent.colorFrom(cryptoColors);

    return AnimatedBuilder(
      animation: flashAnimation,
      builder: (final context, final child) => ColoredBox(
        color: flashColor(cryptoColors) ?? cryptoColors.flashIdle,
        child: child,
      ),
      child: InkWell(
        onTap: _onTap,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                ticker.symbol,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                ticker.lastPrice.formattedWithSeparators,
                textAlign: TextAlign.right,
                style: textTheme.bodyMedium?.copyWith(
                  color: changeColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.priceColumnGap),
            SizedBox(
              width: AppSizes.badgeColumnWidth,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingSm,
                  vertical: _badgePaddingVertical,
                ),
                decoration: BoxDecoration(
                  color: changeColor,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
                ),
                child: Text(
                  ticker.priceChangePercent.formatted,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: cryptoColors.onPriceBadge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
