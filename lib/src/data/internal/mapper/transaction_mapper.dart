import 'package:drift/drift.dart';

import '../../../domain/entities/money_transaction.dart';
import '../../../domain/entities/transaction_type.dart';
import '../database/app_database.dart';

/// Maps between [TransactionRow] storage rows and the [MoneyTransaction]
/// domain entity.
extension TransactionRowMapper on TransactionRow {
  MoneyTransaction toDomain() => MoneyTransaction(
    id: id,
    type: TransactionType.values[type],
    amount: amount,
    date: date,
    categoryId: categoryId,
    description: description,
    memo: memo,
    recurringRuleId: recurringRuleId,
    occurrenceKey: occurrenceKey,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension TransactionEntityMapper on MoneyTransaction {
  TransactionsCompanion toCompanion() => TransactionsCompanion(
    id: Value(id),
    type: Value(type.index),
    amount: Value(amount),
    date: Value(date),
    categoryId: Value(categoryId),
    description: Value(description),
    memo: Value(memo),
    recurringRuleId: Value(recurringRuleId),
    occurrenceKey: Value(occurrenceKey),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );
}
