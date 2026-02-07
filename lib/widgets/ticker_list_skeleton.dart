import 'package:crypto_tracker/core/constants/app_sizes.dart';
import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/widgets/shimmer.dart';
import 'package:flutter/material.dart';

part 'ticker_row_skeleton.dart';

/// Loading view with multiple skeleton rows wrapped in Shimmer.
final class TickerListSkeleton extends StatelessWidget {
  const TickerListSkeleton({super.key});

  static const int _skeletonCount = 12;

  @override
  Widget build(final BuildContext context) {
    final cryptoColors = CryptoColors.of(context);
    return Shimmer(
      linearGradient: LinearGradient(
        colors: [
          cryptoColors.shimmerBase,
          cryptoColors.shimmerHighlight,
          cryptoColors.shimmerBase,
        ],
        stops: const [0.1, 0.3, 0.4],
        begin: const Alignment(-1, -0.3),
        end: const Alignment(1, 0.3),
      ),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _skeletonCount,
        itemBuilder: (final context, final index) => const TickerRowSkeleton(),
      ),
    );
  }
}
