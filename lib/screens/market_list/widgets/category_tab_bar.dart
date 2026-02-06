import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/models/market_category.dart';
import 'package:crypto_tracker/providers/market_provider.dart';

class CategoryTabBar extends StatelessWidget {
  const CategoryTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.select<MarketProvider, MarketCategory>(
      (provider) => provider.selectedCategory,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: MarketCategory.values.map((category) {
          final isSelected = category == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => context.read<MarketProvider>().setCategory(category),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.priceUpColor.withValues(alpha: 0.15)
                      : AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category.label,
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.priceUpColor
                        : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}
