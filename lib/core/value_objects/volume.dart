final class Volume implements Comparable<Volume> {
  final double value;

  static const double _billionThreshold = 1000000000;
  static const double _millionThreshold = 1000000;
  static const double _thousandThreshold = 1000;

  const Volume(this.value);

  factory Volume.fromString(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const Volume(0);
    }
    return Volume(double.tryParse(raw) ?? 0);
  }

  static const Volume zero = Volume(0);

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

  @override
  int compareTo(Volume other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Volume && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Volume($formatted)';
}
