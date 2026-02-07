import 'package:flutter/foundation.dart';

/// Immutable value object representing a monetary price in USD (or quote asset).
///
/// Prices below [_compactThreshold] (e.g. micro-cap tokens) are displayed with
/// 8 decimal places; all others use 2 decimal places.
@immutable
final class Price {
  /// The raw numeric price value.
  final double value;

  static const double _compactThreshold = 1;
  static const int _highPrecisionDecimals = 8;
  static const int _standardDecimals = 2;

  const Price(this.value);

  /// Parses a price from a nullable string.
  ///
  /// Returns [zero] when [raw] is `null`, empty, or unparseable.
  factory Price.fromString(final String? raw) {
    if (raw == null || raw.isEmpty) {
      return Price.zero;
    }
    return Price(double.tryParse(raw) ?? 0);
  }

  /// A constant zero-price instance.
  static const Price zero = Price(0);

  /// Human-readable price string with adaptive decimal precision.
  String get formatted {
    if (value == 0) return '0.00';
    if (value < _compactThreshold) {
      return value.toStringAsFixed(_highPrecisionDecimals);
    }
    return value.toStringAsFixed(_standardDecimals);
  }

  /// Human-readable price with comma separators (e.g., 1,169,843.52).
  String get formattedWithSeparators {
    final intPart = value.truncate();
    final formatted = _addThousandSeparators(intPart);
    final decimals = value < _compactThreshold
        ? _highPrecisionDecimals
        : _standardDecimals;
    final decimalStr = (value - intPart).abs().toStringAsFixed(decimals);
    return '$formatted${decimalStr.substring(1)}';
  }

  static String _addThousandSeparators(final int number) {
    final str = number.abs().toString();
    final buffer = StringBuffer();
    final length = str.length;
    for (var i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    final result = buffer.toString();
    return number.isNegative ? '-$result' : result;
  }

  /// Adds two prices.
  Price operator +(final Price other) => Price(value + other.value);

  /// Subtracts two prices.
  Price operator -(final Price other) => Price(value - other.value);

  @override
  bool operator ==(final Object other) =>
      identical(this, other) || other is Price && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Price($formatted)';
}
