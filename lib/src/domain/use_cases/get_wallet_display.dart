import '../entities/wallet_display.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/wallet_repository.dart';

/// Provides the wallet name and its all-time current balance together for the
/// single-wallet display row (for example `Cash · Rp 1,000,000`).
class GetWalletDisplay {
  const GetWalletDisplay(this._walletRepository, this._transactionRepository);

  final WalletRepository _walletRepository;
  final TransactionRepository _transactionRepository;

  Future<WalletDisplay> call() async {
    final wallet = await _walletRepository.getWallet();
    final transactions = await _transactionRepository.getAll();
    final signedTotal = transactions.fold<int>(
      0,
      (sum, t) => sum + t.signedAmount,
    );
    return WalletDisplay(
      name: wallet.name,
      balance: wallet.balanceWith(signedTotal),
    );
  }
}
