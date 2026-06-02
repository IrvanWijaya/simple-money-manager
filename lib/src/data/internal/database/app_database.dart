import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../dao/category_dao.dart';
import '../dao/recurring_dao.dart';
import '../dao/transaction_dao.dart';
import '../dao/wallet_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// The app's local Drift/SQLite database.
///
/// Owns all persisted source tables (transactions, categories, recurring rules,
/// recurring occurrence idempotency metadata, and the single wallet settings
/// row). Summaries, statistics, and date-group totals are NOT persisted; they
/// are computed by domain use cases from these tables.
@DriftDatabase(
  tables: [
    Categories,
    Transactions,
    RecurringRules,
    RecurringOccurrences,
    WalletSettings,
  ],
  daos: [CategoryDao, TransactionDao, RecurringDao, WalletDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// In-memory database for tests; each instance is fully isolated.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'simple_money_manager');
  }
}
