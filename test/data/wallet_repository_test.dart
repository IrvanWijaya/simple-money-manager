import 'package:flutter_test/flutter_test.dart';
import 'package:simple_money_manager/src/data/internal/database/app_database.dart';
import 'package:simple_money_manager/src/data/repository/wallet_repository_impl.dart';
import 'package:simple_money_manager/src/domain/entities/default_wallet.dart';

import 'helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late WalletRepositoryImpl repository;

  setUp(() {
    db = createTestDatabase();
    repository = WalletRepositoryImpl(db.walletDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('returns default wallet when none saved', () async {
    final wallet = await repository.getWallet();
    expect(wallet, const DefaultWallet());
    expect(wallet.name, 'Cash');
    expect(wallet.baseBalance, 0);
  });

  test('saves and reloads wallet settings', () async {
    await repository.saveWallet(
      const DefaultWallet(name: 'Cash', baseBalance: 500000),
    );
    final wallet = await repository.getWallet();
    expect(wallet.baseBalance, 500000);
  });

  test('saving twice keeps a single wallet row (single wallet)', () async {
    await repository.saveWallet(const DefaultWallet(baseBalance: 100));
    await repository.saveWallet(const DefaultWallet(baseBalance: 200));

    final row = await db.walletDao.getSettings();
    expect(row, isNotNull);
    expect(row!.id, 0);
    expect(row.baseBalance, 200);
  });
}
