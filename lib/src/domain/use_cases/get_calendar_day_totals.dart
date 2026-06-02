import '../entities/period_range.dart';
import '../entities/period_summary.dart';
import '../repositories/transaction_repository.dart';

/// Computes per-day income/expense totals for the transactions in [range].
///
/// Returns a map keyed by calendar day (local, midnight) to the day's
/// [PeriodSummary]. Only days with at least one in-range transaction appear in
/// the map, so calendar cells without data show no stale totals (VAL-CAL-005).
/// Totals are derived dynamically and never persisted, and they are filtered to
/// the active period range so a day outside the range never contributes
/// (VAL-CAL-007).
class GetCalendarDayTotals {
  const GetCalendarDayTotals(this._repository);

  final TransactionRepository _repository;

  Future<Map<DateTime, PeriodSummary>> call(PeriodRange range) async {
    final transactions = await _repository.getByDateRange(
      range.start,
      range.end,
    );

    final byDay = <DateTime, PeriodSummary>{};
    for (final transaction in transactions) {
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      final current = byDay[day] ?? const PeriodSummary();
      if (transaction.type.isIncome) {
        byDay[day] = current.copyWith(
          income: current.income + transaction.amount,
        );
      } else {
        byDay[day] = current.copyWith(
          expense: current.expense + transaction.amount,
        );
      }
    }
    return byDay;
  }
}
