import 'category.dart';

/// Computed per-category statistics for a period and transaction type.
///
/// Derived value object, never persisted. [amount] is the non-negative total
/// magnitude for the category in the selected period/type, [transactionCount]
/// is the number of contributing transactions, and [percentage] is the share of
/// the selected type total in the range 0.0..100.0.
class StatisticCategorySummary {
  const StatisticCategorySummary({
    required this.category,
    required this.amount,
    required this.transactionCount,
    required this.percentage,
  });

  final Category category;

  /// Non-negative total magnitude for this category in whole Rupiah.
  final int amount;

  /// Number of transactions contributing to [amount].
  final int transactionCount;

  /// Share of the selected-type total, 0.0..100.0.
  final double percentage;

  @override
  bool operator ==(Object other) =>
      other is StatisticCategorySummary &&
      other.category == category &&
      other.amount == amount &&
      other.transactionCount == transactionCount &&
      other.percentage == percentage;

  @override
  int get hashCode =>
      Object.hash(category, amount, transactionCount, percentage);

  @override
  String toString() =>
      'StatisticCategorySummary(${category.name}, amount: $amount, '
      'count: $transactionCount, pct: $percentage)';
}
