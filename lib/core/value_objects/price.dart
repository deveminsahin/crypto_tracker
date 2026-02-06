final class Price {
  final double value;

  static const double _compactThreshold = 1.0;
  static const int _highPrecisionDecimals = 8;
  static const int _standardDecimals = 2;

  const Price(this.value);

  factory Price.fromString(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const Price(0);
    }
    return Price(double.tryParse(raw) ?? 0);
  }

  static const Price zero = Price(0);

  String get formatted {
    if (value == 0) return '0.00';
    if (value < _compactThreshold) {
      return value.toStringAsFixed(_highPrecisionDecimals);
    }
    return value.toStringAsFixed(_standardDecimals);
  }

  Price operator +(Price other) => Price(value + other.value);
  Price operator -(Price other) => Price(value - other.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Price && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Price($formatted)';
}
