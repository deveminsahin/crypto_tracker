import 'package:flutter/foundation.dart';

/// Abstract base class for immutable numeric value objects.
///
/// Provides shared formatting utilities and enforces a common interface
/// for value objects like [Price] and [Volume].
@immutable
abstract class NumericValue {
  /// The raw numeric value.
  double get value;

  const NumericValue();

  /// Formats an [int] with comma thousand separators (e.g. 1234567 → "1,234,567").
  @protected
  String formatWithThousandSeparators(final int number) {
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
}
