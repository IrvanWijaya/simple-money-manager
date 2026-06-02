import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/tables.dart';

part 'wallet_dao.g.dart';

/// Data access for the single-row [WalletSettings] table.
@DriftAccessor(tables: [WalletSettings])
class WalletDao extends DatabaseAccessor<AppDatabase> with _$WalletDaoMixin {
  WalletDao(super.db);

  /// The single wallet settings row, or `null` when not yet saved.
  Future<WalletSettingRow?> getSettings() {
    return (select(
      walletSettings,
    )..where((t) => t.id.equals(0))).getSingleOrNull();
  }

  /// Persists the single wallet settings row (id fixed at 0).
  Future<void> upsert(WalletSettingsCompanion row) {
    return into(
      walletSettings,
    ).insertOnConflictUpdate(row.copyWith(id: const Value(0)));
  }
}
