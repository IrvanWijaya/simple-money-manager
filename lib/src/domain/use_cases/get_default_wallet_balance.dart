import '../repositories/transaction_repository.dart';
import '../repositories/wallet_repository.dart';

/// Computes the all-time current balance of the single default wallet.
///
/// The balance is `baseBalance + sum of all signed transaction amounts` across
/// every transaction, independent of any selected timeframe or period. It is
/// never period-filtered, so changing the active period does not change it.
class GetDefaultWalletBalance {
  const GetDefaultWalletBalance(
    this._walletRepository,
    this._transactionRepository,
  );

  final WalletRepository _walletRepository;
  final TransactionRepository _transactionRepository;

  Future<int> call() async {
    final wallet = await _walletRepository.getWallet();
    final transactions = await _transactionRepository.getAll();
    final signedTotal = transactions.fold<int>(
      0,
      (sum, t) => sum + t.signedAmount,
    );
    return wallet.balanceWith(signedTotal);
  }
}
