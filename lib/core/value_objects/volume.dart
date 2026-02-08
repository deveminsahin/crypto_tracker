import 'package:crypto_tracker/core/value_objects/numeric_value.dart';
import 'package:flutter/foundation.dart';

/// Immutable value object representing a trading volume in the quote asset.
///
/// [formatted] produces compact human-readable output using K / M / B
/// suffixes (e.g. `1.25B`, `340.00M`, `12.50K`).
///
/// Implements [Comparable] to support sorting by volume.
@immutable
final class Volume extends NumericValue implements Comparable<Volume> {
  /// The raw numeric volume.
  @override
  final double value;

  static const double _billionThreshold = 1000000000;
  static const double _millionThreshold = 1000000;
  static const double _thousandThreshold = 1000;

  const Volume(this.value);

  /// Parses a volume from a nullable string.
  ///
  /// Returns [zero] when [raw] is `null`, empty, or unparseable.
  factory Volume.fromString(final String? raw) {
    if (raw == null || raw.isEmpty) {
      return Volume.zero;
    }
    return Volume(double.tryParse(raw) ?? 0);
  }

  /// A constant zero-volume instance.
  static const Volume zero = Volume(0);

  /// Human-readable volume with K / M / B suffix.
  String get formatted {
    if (value >= _billionThreshold) {
      return '${(value / _billionThreshold).toStringAsFixed(2)}B';
    }
    if (value >= _millionThreshold) {
      return '${(value / _millionThreshold).toStringAsFixed(2)}M';
    }
    if (value >= _thousandThreshold) {
      return '${(value / _thousandThreshold).toStringAsFixed(2)}K';
    }
    return value.toStringAsFixed(2);
  }

  /// Human-readable volume with comma separators (e.g., 1,169,843,918).
  String get formattedWithSeparators {
    final intPart = value.truncate();
    final decimalPart = value - intPart;
    final formatted = formatWithThousandSeparators(intPart);
    if (decimalPart == 0) {
      return formatted;
    }
    return '$formatted${decimalPart.toStringAsFixed(2).substring(1)}';
  }

  @override
  int compareTo(final Volume other) => value.compareTo(other.value);

  @override
  bool operator ==(final Object other) =>
      identical(this, other) || other is Volume && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Volume($formatted)';
}
