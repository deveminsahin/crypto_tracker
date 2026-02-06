import 'package:flutter/material.dart';

import 'package:crypto_tracker/core/errors/app_exception.dart';
import 'package:crypto_tracker/core/theme/app_theme.dart';

class ErrorDisplay extends StatelessWidget {
  final AppException exception;
  final VoidCallback onRetry;

  const ErrorDisplay({
    super.key,
    required this.exception,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.priceDownColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _userFacingMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textPrimary,
                side: const BorderSide(color: AppTheme.dividerColor),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String get _userFacingMessage {
    return switch (exception) {
      NetworkException() => 'Unable to connect. Check your internet and try again.',
      ParseException() => 'Something went wrong processing data. Please try again.',
      WebSocketException() => 'Live updates disconnected. Please try again.',
    };
  }
}
