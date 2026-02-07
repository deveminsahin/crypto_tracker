import 'package:crypto_tracker/core/constants/app_sizes.dart';
import 'package:crypto_tracker/core/errors/app_exception.dart';
import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

/// Full-screen error state with a localized message and retry button.
final class ErrorDisplay extends StatelessWidget {
  final AppException exception;
  final VoidCallback onRetry;

  const ErrorDisplay({
    required this.exception,
    required this.onRetry,
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final cryptoColors = CryptoColors.of(context);
    final bodyMedium = TextTheme.of(context).bodyMedium;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: cryptoColors.priceDown,
              size: AppSizes.iconLg,
            ),
            const SizedBox(height: AppSizes.spacingMd),
            Text(
              exception.localizedMessage(l10n),
              textAlign: TextAlign.center,
              style: bodyMedium?.copyWith(
                color: ColorScheme.of(context).onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.spacingLg),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.retryButton)),
          ],
        ),
      ),
    );
  }
}
