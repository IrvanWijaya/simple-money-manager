import '../../domain/entities/default_wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../internal/dao/wallet_dao.dart';
import '../internal/mapper/wallet_mapper.dart';

/// Drift-backed [WalletRepository] for the single default wallet settings.
class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(this._dao);

  final WalletDao _dao;

  @override
  Future<DefaultWallet> getWallet() async {
    final row = await _dao.getSettings();
    return row?.toDomain() ?? const DefaultWallet();
  }

  @override
  Future<void> saveWallet(DefaultWallet wallet) {
    return _dao.upsert(wallet.toCompanion());
  }
}
