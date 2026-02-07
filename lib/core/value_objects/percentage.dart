import 'dart:ui' show Color;

import 'package:crypto_tracker/core/theme/app_theme.dart';
import 'package:crypto_tracker/core/value_objects/price.dart';
import 'package:flutter/foundation.dart';

/// Immutable value object representing a percentage change.
///
/// Typically used to express the 24-hour price change of a trading pair.
/// Positive values are prefixed with `+` in [formatted] output.
@immutable
final class Percentage {
  /// The raw numeric percentage value (e.g. `2.45` means +2.45 %).
  final double value;

  const Percentage(this.value);

  /// Parses a percentage from a nullable string.
  ///
  /// Returns [zero] when [raw] is `null`, empty, or not a valid number.
  factory Percentage.fromString(final String? raw) {
    if (raw == null || raw.isEmpty) {
      return Percentage.zero;
    }
    return Percentage(double.tryParse(raw) ?? 0);
  }

  /// Computes the percentage change between [current] and [open] prices.
  ///
  /// Returns [zero] when [open] is zero to avoid division by zero.
  factory Percentage.fromPrices({
    required final Price current,
    required final Price open,
  }) {
    if (open.value == 0) return Percentage.zero;
    final change = current.value - open.value;
    return Percentage((change / open.value) * 100);
  }

  /// A constant zero-percent instance.
  static const Percentage zero = Percentage(0);

  /// Whether this percentage represents a gain.
  bool get isPositive => value > 0;

  /// Whether this percentage represents a loss.
  bool get isNegative => value < 0;

  /// Human-readable string such as `+2.45%` or `-1.30%`.
  String get formatted {
    final sign = isPositive ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  /// Returns the appropriate color for this percentage change.
  ///
  /// Positive values return [CryptoColors.priceUp], otherwise [CryptoColors.priceDown].
  Color colorFrom(final CryptoColors colors) =>
      isPositive ? colors.priceUp : colors.priceDown;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) || other is Percentage && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Percentage($formatted)';
}
