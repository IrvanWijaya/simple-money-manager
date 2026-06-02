import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../domain/entities/transaction_date_group.dart';

/// Header for a transaction date group: the date on the left and the computed
/// signed group total on the right (VAL-TXNHOME-003).
class TransactionDateGroupHeader extends StatelessWidget {
  const TransactionDateGroupHeader({super.key, required this.group});

  final TransactionDateGroup group;

  static final DateFormat _date = DateFormat('EEE, dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final total = group.signedTotal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _date.format(group.date),
              key: ValueKey(
                'date-group-${group.date.toIso8601String().split('T').first}',
              ),
              style: const TextStyle(
                color: AppColors.onBackground,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            MoneyFormatter.format(total),
            key: ValueKey(
              'date-group-total-${group.date.toIso8601String().split('T').first}',
            ),
            style: const TextStyle(
              color: AppColors.onBackground,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
