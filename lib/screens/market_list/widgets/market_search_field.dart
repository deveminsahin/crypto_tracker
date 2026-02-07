import 'package:crypto_tracker/core/constants/app_sizes.dart';
import 'package:crypto_tracker/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';

/// Search text field for filtering tickers by symbol name.
final class MarketSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const MarketSearchField({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingSm),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextTheme.of(context).bodyMedium,
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          prefixIcon: Icon(
            Icons.search,
            color: ColorScheme.of(context).onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
