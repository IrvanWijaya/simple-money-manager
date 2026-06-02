// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_dao.dart';

// ignore_for_file: type=lint
mixin _$WalletDaoMixin on DatabaseAccessor<AppDatabase> {
  $WalletSettingsTable get walletSettings => attachedDatabase.walletSettings;
  WalletDaoManager get managers => WalletDaoManager(this);
}

class WalletDaoManager {
  final _$WalletDaoMixin _db;
  WalletDaoManager(this._db);
  $$WalletSettingsTableTableManager get walletSettings =>
      $$WalletSettingsTableTableManager(
        _db.attachedDatabase,
        _db.walletSettings,
      );
}
