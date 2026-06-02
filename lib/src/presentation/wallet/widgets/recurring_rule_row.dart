import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/recurring_rule.dart';
import '../../shared/category_visuals.dart';

/// A single saved recurring rule row in the Wallet surface.
///
/// Shows the category icon, a title (description when present, otherwise the
/// category name), the next occurrence in a readable weekday/date format, and
/// the correctly signed/colored amount (VAL-RECUI-006).
class RecurringRuleRow extends StatelessWidget {
  const RecurringRuleRow({
    super.key,
    required this.rule,
    required this.category,
    required this.nextOccurrence,
  });

  final RecurringRule rule;

  /// Resolved category for [rule], or `null` when unavailable; the row still
  /// renders with a generic icon and falls back to the description.
  final Category? category;

  /// The upcoming occurrence date, or `null` when the rule has already ended.
  final DateTime? nextOccurrence;

  static final DateFormat _date = DateFormat('EEEE dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final categoryName = category?.name ?? '';
    final hasDescription = rule.description.trim().isNotEmpty;
    final title = hasDescription
        ? rule.description.trim()
        : (categoryName.isNotEmpty ? categoryName : 'Recurring');

    final signed = rule.type.isExpense ? -rule.amount : rule.amount;
    final amountColor = rule.type.isExpense
        ? AppColors.expense
        : AppColors.income;

    final nextLabel = nextOccurrence != null
        ? _date.format(nextOccurrence!)
        : 'No upcoming occurrence';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surface,
            child: Icon(
              CategoryVisuals.iconForId(rule.categoryId, type: rule.type),
              size: 18,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  key: ValueKey('recurring-title-${rule.id}'),
                  style: const TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  nextLabel,
                  key: ValueKey('recurring-next-${rule.id}'),
                  style: const TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            MoneyFormatter.format(signed),
            key: ValueKey('recurring-amount-${rule.id}'),
            style: TextStyle(
              color: amountColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
