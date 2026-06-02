import '../entities/category.dart';
import '../entities/period_range.dart';
import '../entities/statistic_category_summary.dart';
import '../entities/transaction_type.dart';
import '../repositories/category_repository.dart';
import '../repositories/transaction_repository.dart';

/// Computes per-category [StatisticCategorySummary] rows for a period and type.
///
/// Only transactions within the inclusive [PeriodRange] that match [type]
/// contribute. Each row's amount is the sum of contributing transaction
/// magnitudes (always non-negative), the count is the number of contributing
/// transactions, and the percentage is the category amount divided by the
/// selected-type total (using absolute magnitudes, so expense percentages are
/// positive), expressed in the range 0.0..100.0.
///
/// Rows are ordered by descending amount, with ties broken by stable category
/// seed order (then id) for determinism. Categories with no transactions in the
/// period are omitted. All values are computed dynamically and never persisted.
class GetStatisticCategorySummary {
  const GetStatisticCategorySummary(
    this._transactionRepository,
    this._categoryRepository,
  );

  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  Future<List<StatisticCategorySummary>> call(
    PeriodRange range,
    TransactionType type,
  ) async {
    final transactions = await _transactionRepository.getByDateRange(
      range.start,
      range.end,
    );
    final categories = await _categoryRepository.getByType(type);
    final categoriesById = {for (final c in categories) c.id: c};

    final amounts = <String, int>{};
    final counts = <String, int>{};
    var typeTotal = 0;
    for (final t in transactions) {
      if (t.type != type) continue;
      amounts.update(
        t.categoryId,
        (v) => v + t.amount,
        ifAbsent: () => t.amount,
      );
      counts.update(t.categoryId, (v) => v + 1, ifAbsent: () => 1);
      typeTotal += t.amount;
    }

    final rows = <StatisticCategorySummary>[];
    for (final entry in amounts.entries) {
      final category = categoriesById[entry.key];
      if (category == null) continue;
      final amount = entry.value;
      rows.add(
        StatisticCategorySummary(
          category: category,
          amount: amount,
          transactionCount: counts[entry.key]!,
          percentage: typeTotal == 0 ? 0 : (amount / typeTotal) * 100,
        ),
      );
    }

    rows.sort(_compareRows);
    return rows;
  }

  /// Descending by amount, then ascending by stable seed order, then id.
  static int _compareRows(
    StatisticCategorySummary a,
    StatisticCategorySummary b,
  ) {
    final byAmount = b.amount.compareTo(a.amount);
    if (byAmount != 0) return byAmount;
    return _compareSeed(a.category, b.category);
  }

  static int _compareSeed(Category a, Category b) {
    final bySeed = a.seedOrder.compareTo(b.seedOrder);
    if (bySeed != 0) return bySeed;
    return a.id.compareTo(b.id);
  }
}
