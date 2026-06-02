import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/internal/database/app_database.dart';
import '../../data/repository/category_repository_impl.dart';
import '../../data/repository/recurring_repository_impl.dart';
import '../../data/repository/transaction_repository_impl.dart';
import '../../data/repository/wallet_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/recurring_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/wallet_repository.dart';

/// The single app-wide Drift database instance.
///
/// Overridden in tests with an in-memory [AppDatabase.forTesting] instance for
/// isolation. Disposed when the provider scope is torn down.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
    ref.watch(appDatabaseProvider).transactionDao,
  );
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(appDatabaseProvider).categoryDao);
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl(ref.watch(appDatabaseProvider).walletDao);
});

final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  return RecurringRepositoryImpl(ref.watch(appDatabaseProvider).recurringDao);
});

/// Runs idempotent startup initialization (currently: seed built-in
/// categories). Safe to await repeatedly; seeding never duplicates rows.
final dataInitializationProvider = FutureProvider<void>((ref) async {
  await ref.watch(categoryRepositoryProvider).ensureSeeded();
});
