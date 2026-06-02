import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../domain/entities/statistic_category_summary.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../shared/category_visuals.dart';
import '../stat_chart_mode.dart';

/// Formats a 0..100 percentage to a single decimal place (VAL-STAT-013).
String formatStatPercentage(double percentage) =>
    '${percentage.toStringAsFixed(1)}%';

/// Reusable Statistic structure chart with a shared legend.
///
/// Renders the same computed [rows] as either a donut or a bar chart depending
/// on [mode], plus a legend that always reflects the identical category totals
/// (VAL-STAT-010, VAL-STAT-011). When [rows] is empty (zero total), it shows a
/// stable empty/zero state with no slices/bars and no NaN/Infinity percentages
/// (VAL-STAT-009, VAL-STAT-012).
class StructureChart extends StatelessWidget {
  const StructureChart({
    super.key,
    required this.rows,
    required this.mode,
    required this.type,
    required this.totalAmount,
    this.showLegend = true,
  });

  /// Computed category statistics, ordered by descending amount.
  final List<StatisticCategorySummary> rows;

  /// The active visualization mode.
  final StatChartMode mode;

  /// The structure type these rows represent (income or expense).
  final TransactionType type;

  /// Non-negative sum of all category amounts; shown in the donut center.
  final int totalAmount;

  /// When false, only the chart is rendered (no shared legend). Used by the
  /// Structure detail screen, which renders its own richer category breakdown
  /// list with transaction counts instead of the legend.
  final bool showLegend;

  bool get _isEmpty => rows.isEmpty || totalAmount == 0;

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) {
      return _EmptyChartState(type: type);
    }

    return Column(
      key: const ValueKey('structure-chart'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 200,
          child: mode == StatChartMode.donut
              ? _DonutChart(rows: rows, type: type, totalAmount: totalAmount)
              : _BarChart(rows: rows),
        ),
        if (showLegend) ...[
          const SizedBox(height: 16),
          _Legend(rows: rows, type: type),
        ],
      ],
    );
  }
}

Color _sliceColor(StatisticCategorySummary row) =>
    CategoryVisuals.colorForId(row.category.id);

class _DonutChart extends StatelessWidget {
  const _DonutChart({
    required this.rows,
    required this.type,
    required this.totalAmount,
  });

  final List<StatisticCategorySummary> rows;
  final TransactionType type;
  final int totalAmount;

  @override
  Widget build(BuildContext context) {
    final signedTotal = type.isExpense ? -totalAmount : totalAmount;
    final centerColor = type.isExpense ? AppColors.expense : AppColors.income;

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          key: const ValueKey('structure-donut'),
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 64,
            sections: [
              for (final row in rows)
                PieChartSectionData(
                  value: row.amount.toDouble(),
                  color: _sliceColor(row),
                  radius: 28,
                  showTitle: false,
                ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type.isExpense ? 'Expense' : 'Income',
              style: const TextStyle(
                color: AppColors.onBackground,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              MoneyFormatter.format(signedTotal),
              key: const ValueKey('structure-chart-total'),
              style: TextStyle(
                color: centerColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.rows});

  final List<StatisticCategorySummary> rows;

  @override
  Widget build(BuildContext context) {
    final maxAmount = rows
        .map((r) => r.amount)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final maxY = (maxAmount == 0 ? 1 : maxAmount).toDouble();

    return BarChart(
      key: const ValueKey('structure-bar'),
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        barTouchData: BarTouchData(enabled: false),
        barGroups: [
          for (var i = 0; i < rows.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: rows[i].amount.toDouble(),
                  color: _sliceColor(rows[i]),
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.rows, required this.type});

  final List<StatisticCategorySummary> rows;
  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('structure-legend'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final row in rows) _LegendItem(row: row, type: type)],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.row, required this.type});

  final StatisticCategorySummary row;
  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    final id = row.category.id;
    final signedAmount = type.isExpense ? -row.amount : row.amount;
    final amountColor = type.isExpense ? AppColors.expense : AppColors.income;

    return Padding(
      key: ValueKey('legend-item-$id'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _sliceColor(row),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              row.category.name,
              style: const TextStyle(
                color: AppColors.onBackground,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatStatPercentage(row.percentage),
            key: ValueKey('legend-percentage-$id'),
            style: const TextStyle(
              color: AppColors.onBackground,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            MoneyFormatter.format(signedAmount),
            key: ValueKey('legend-amount-$id'),
            style: TextStyle(
              color: amountColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChartState extends StatelessWidget {
  const _EmptyChartState({required this.type});

  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('structure-chart-empty'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 128,
                  height: 128,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 48,
                      sections: [
                        PieChartSectionData(
                          value: 1,
                          color: AppColors.surface,
                          radius: 16,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  MoneyFormatter.format(0),
                  key: const ValueKey('structure-chart-total'),
                  style: const TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            type.isExpense
                ? 'No expenses in this period'
                : 'No income in this period',
            style: const TextStyle(color: AppColors.onBackground, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
