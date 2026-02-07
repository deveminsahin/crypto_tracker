part of 'ticker_list_skeleton.dart';

/// Skeleton loading placeholder for ticker rows.
final class TickerRowSkeleton extends StatelessWidget {
  const TickerRowSkeleton({super.key});

  static const double _symbolWidth = 80;
  static const double _volumeWidth = 60;
  static const double _priceWidth = 100;
  static const double _badgeWidth = 70;
  static const double _badgeHeight = 28;
  static const double _lineHeight = 14;
  static const double _smallLineHeight = 10;

  @override
  Widget build(final BuildContext context) => ShimmerLoading(
    isLoading: true,
    child: SizedBox(
      height: AppSizes.tickerRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingMd),
        child: Row(
          children: [
            // Symbol & Volume column
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: _symbolWidth,
                    height: _lineHeight,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadiusSm,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXs),
                  Container(
                    width: _volumeWidth,
                    height: _smallLineHeight,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadiusSm,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Price column
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: _priceWidth,
                  height: _lineHeight,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(
                      AppSizes.borderRadiusSm,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.priceColumnGap),
            // Change % badge
            Container(
              width: _badgeWidth,
              height: _badgeHeight,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
