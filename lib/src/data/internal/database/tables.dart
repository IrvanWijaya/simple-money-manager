import 'package:drift/drift.dart';

/// Persisted transaction categories (built-in seeds and any future custom
/// categories). `type` stores the [TransactionType] index.
@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get type => integer()();
  IntColumn get seedOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Persisted money transactions. Amount is a non-negative magnitude in whole
/// Rupiah; the sign is derived from `type` at the domain layer.
@DataClassName('TransactionRow')
class Transactions extends Table {
  TextColumn get id => text()();
  IntColumn get type => integer()();
  IntColumn get amount => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get categoryId => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get memo => text().withDefault(const Constant(''))();
  TextColumn get recurringRuleId => text().nullable()();
  TextColumn get occurrenceKey => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Persisted recurring rules. Structured columns are stored generically so the
/// recurring engine feature can interpret them without a schema migration.
/// `frequency`, `repeatPosition`, and `endCondition` store enum indices.
@DataClassName('RecurringRuleRow')
class RecurringRules extends Table {
  TextColumn get id => text()();
  IntColumn get type => integer()();
  IntColumn get amount => integer()();
  TextColumn get categoryId => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get memo => text().withDefault(const Constant(''))();
  IntColumn get frequency => integer()();
  IntColumn get interval => integer().withDefault(const Constant(1))();
  IntColumn get repeatPosition => integer().nullable()();
  IntColumn get endCondition => integer()();
  IntColumn get endCount => integer().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Idempotency metadata for generated recurring occurrences. A row exists for
/// every (ruleId, occurrenceKey) that has already produced a transaction, so
/// re-running generation never creates duplicates.
@DataClassName('RecurringOccurrenceRow')
class RecurringOccurrences extends Table {
  TextColumn get ruleId => text()();
  TextColumn get occurrenceKey => text()();
  TextColumn get transactionId => text()();
  DateTimeColumn get occurrenceDate => dateTime()();
  DateTimeColumn get generatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {ruleId, occurrenceKey};
}

/// Single-row table holding the default wallet settings. `id` is always 0.
@DataClassName('WalletSettingRow')
class WalletSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get name => text().withDefault(const Constant('Cash'))();
  IntColumn get baseBalance => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
