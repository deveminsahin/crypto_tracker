part of 'detail_info_grid.dart';

final class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(final BuildContext context) {
    final textTheme = TextTheme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.labelMedium),
        Text(
          value,
          style: textTheme.labelMedium?.copyWith(
            color: ColorScheme.of(context).onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
