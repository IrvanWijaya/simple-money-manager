import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/money_transaction.dart';
import '../../shared/category_visuals.dart';

/// A single transaction list row.
///
/// Shows the category icon, a title (description when present, otherwise the
/// category name) with category context as subtitle, the correctly
/// signed/colored amount, and the transaction time. Wallet selection is
/// intentionally never shown (VAL-TXNHOME-004, VAL-TXNHOME-005).
class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.transaction,
    required this.category,
  });

  final MoneyTransaction transaction;

  /// Resolved category for [transaction], or `null` when unavailable; the row
  /// still renders with a generic icon and falls back to the description.
  final Category? category;

  static final DateFormat _time = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final categoryName = category?.name ?? '';
    final hasDescription = transaction.description.trim().isNotEmpty;
    final title = hasDescription
        ? transaction.description.trim()
        : (categoryName.isNotEmpty ? categoryName : 'Transaction');
    // Subtitle gives category context; never a wallet chooser.
    final subtitle = hasDescription && categoryName.isNotEmpty
        ? categoryName
        : null;

    final signed = transaction.signedAmount;
    final amountColor = transaction.type.isExpense
        ? AppColors.expense
        : AppColors.income;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surface,
            child: Icon(
              CategoryVisuals.iconForId(
                transaction.categoryId,
                type: transaction.type,
              ),
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
                  key: ValueKey('transaction-title-${transaction.id}'),
                  style: const TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.onBackground,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                MoneyFormatter.format(signed),
                key: ValueKey('transaction-amount-${transaction.id}'),
                style: TextStyle(
                  color: amountColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _time.format(transaction.date),
                key: ValueKey('transaction-time-${transaction.id}'),
                style: const TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
