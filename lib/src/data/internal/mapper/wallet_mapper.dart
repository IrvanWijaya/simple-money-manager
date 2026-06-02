import 'package:drift/drift.dart';

import '../../../domain/entities/default_wallet.dart';
import '../database/app_database.dart';

/// Maps between [WalletSettingRow] storage rows and the [DefaultWallet] domain
/// entity.
extension WalletRowMapper on WalletSettingRow {
  DefaultWallet toDomain() =>
      DefaultWallet(name: name, baseBalance: baseBalance);
}

extension WalletEntityMapper on DefaultWallet {
  WalletSettingsCompanion toCompanion() => WalletSettingsCompanion(
    id: const Value(0),
    name: Value(name),
    baseBalance: Value(baseBalance),
  );
}
