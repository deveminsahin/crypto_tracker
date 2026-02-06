import 'package:flutter/material.dart';

import 'package:crypto_tracker/core/theme/app_theme.dart';

class MarketSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const MarketSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: const InputDecoration(
        hintText: 'Search symbol...',
        prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
      ),
    );
  }
}
