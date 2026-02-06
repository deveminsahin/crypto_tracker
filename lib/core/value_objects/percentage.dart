import 'package:crypto_tracker/core/value_objects/price.dart';

final class Percentage {
  final double value;

  const Percentage(this.value);

  factory Percentage.fromString(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const Percentage(0);
    }
    return Percentage(double.tryParse(raw) ?? 0);
  }

  factory Percentage.fromPrices({
    required Price current,
    required Price open,
  }) {
    if (open.value == 0) return const Percentage(0);
    final change = current.value - open.value;
    return Percentage((change / open.value) * 100);
  }

  static const Percentage zero = Percentage(0);

  bool get isPositive => value > 0;
  bool get isNegative => value < 0;

  String get formatted {
    final sign = isPositive ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Percentage && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Percentage($formatted)';
}
