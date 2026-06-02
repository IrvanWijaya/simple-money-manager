import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../domain/entities/statistic_category_summary.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../shared/category_visuals.dart';
import 'structure_chart.dart';

/// Singular/plural transaction count label, e.g. `1 transaction`,
/// `2 transactions`.
String transactionCountLabel(int count) =>
    count == 1 ? '1 transaction' : '$count transactions';

/// A single Structure detail category breakdown row.
///
/// Shows the category icon, name, computed one-decimal percentage, signed
/// amount, and a singular/plural transaction count, all derived from the
/// computed [StatisticCategorySummary] (VAL-STAT-008, VAL-STAT-013).
class StructureCategoryRow extends StatelessWidget {
  const StructureCategoryRow({
    super.key,
    required this.row,
    required this.type,
  });

  final StatisticCategorySummary row;
  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    final id = row.category.id;
    final signedAmount = type.isExpense ? -row.amount : row.amount;
    final amountColor = type.isExpense ? AppColors.expense : AppColors.income;

    return Padding(
      key: ValueKey('structure-row-$id'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: CategoryVisuals.colorForId(id),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CategoryVisuals.iconForId(id, type: type),
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.category.name,
                        style: const TextStyle(
                          color: AppColors.onBackground,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatStatPercentage(row.percentage),
                      key: ValueKey('structure-row-percentage-$id'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      MoneyFormatter.format(signedAmount),
                      key: ValueKey('structure-row-amount-$id'),
                      style: TextStyle(
                        color: amountColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  transactionCountLabel(row.transactionCount),
                  key: ValueKey('structure-row-count-$id'),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
