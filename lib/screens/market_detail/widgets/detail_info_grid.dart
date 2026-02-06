import 'package:flutter/material.dart';

import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/models/ticker.dart';

class DetailInfoGrid extends StatelessWidget {
  final Ticker ticker;

  const DetailInfoGrid({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildRow('24h High', ticker.highPrice.formatted),
          const Divider(height: 24),
          _buildRow('24h Low', ticker.lowPrice.formatted),
          const Divider(height: 24),
          _buildRow('24h Volume', ticker.volume.formatted),
          const Divider(height: 24),
          _buildRow('Quote Volume', ticker.quoteVolume.formatted),
          const Divider(height: 24),
          _buildRow('Bid Price', ticker.bidPrice.formatted),
          const Divider(height: 24),
          _buildRow('Ask Price', ticker.askPrice.formatted),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
