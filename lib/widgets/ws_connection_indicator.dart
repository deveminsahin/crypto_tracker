import 'package:crypto_tracker/core/constants/app_constants.dart';
import 'package:crypto_tracker/core/constants/app_sizes.dart';
import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/l10n/l10n_extension.dart';
import 'package:crypto_tracker/providers/market_provider.dart';
import 'package:flutter/material.dart';

part 'pulsing_dot.dart';

/// An indicator showing WebSocket connection status with dot and label.
final class WsConnectionIndicator extends StatelessWidget {
  final WsConnectionState state;

  const WsConnectionIndicator({required this.state, super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final cryptoColors = CryptoColors.of(context);
    final colorScheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);

    final (color, label, tooltip) = switch (state) {
      WsConnectionState.connected => (
        cryptoColors.priceUp,
        l10n.wsLabelLive,
        l10n.wsConnected,
      ),
      WsConnectionState.connecting => (
        cryptoColors.warning,
        l10n.wsLabelSyncing,
        l10n.wsConnecting,
      ),
      WsConnectionState.disconnected => (
        colorScheme.onSurfaceVariant,
        l10n.wsLabelStale,
        l10n.wsDisconnected,
      ),
      WsConnectionState.error => (
        cryptoColors.priceDown,
        l10n.wsLabelStale,
        l10n.wsError,
      ),
    };

    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingMd),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: AppSizes.spacingSm,
              height: AppSizes.spacingSm,
              child: _PulsingDot(
                color: color,
                size: AppSizes.spacingSm,
                animate: state.shouldAnimate,
              ),
            ),
            const SizedBox(width: AppSizes.spacingXs),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
