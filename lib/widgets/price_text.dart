import 'package:flutter/material.dart';

import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/core/value_objects/percentage.dart';

class PriceText extends StatelessWidget {
  final Percentage changePercent;
  final String text;
  final double fontSize;

  const PriceText({
    super.key,
    required this.changePercent,
    required this.text,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: changePercent.isNegative
            ? AppTheme.priceDownColor
            : AppTheme.priceUpColor,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
