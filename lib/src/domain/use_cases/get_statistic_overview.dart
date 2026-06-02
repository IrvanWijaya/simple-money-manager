import '../entities/period_range.dart';
import '../entities/statistic_overview.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/wallet_repository.dart';

/// Computes the Statistic [StatisticOverview] for a [PeriodRange].
///
/// The opening balance is the wallet base balance plus the signed total of
/// every transaction strictly before [PeriodRange.start]. The period
/// income/expense/total come from transactions within the inclusive range, and
/// the ending balance is opening plus the period total. All values are computed
/// dynamically and never persisted; changing the period recomputes everything.
class GetStatisticOverview {
  const GetStatisticOverview(
    this._walletRepository,
    this._transactionRepository,
  );

  final WalletRepository _walletRepository;
  final TransactionRepository _transactionRepository;

  Future<StatisticOverview> call(PeriodRange range) async {
    final wallet = await _walletRepository.getWallet();
    final all = await _transactionRepository.getAll();

    var beforeSignedTotal = 0;
    var income = 0;
    var expense = 0;
    for (final t in all) {
      if (t.date.isBefore(range.start)) {
        beforeSignedTotal += t.signedAmount;
      } else if (!t.date.isAfter(range.end)) {
        if (t.type.isIncome) {
          income += t.amount;
        } else {
          expense += t.amount;
        }
      }
    }

    final openingBalance = wallet.balanceWith(beforeSignedTotal);
    return StatisticOverview(
      openingBalance: openingBalance,
      income: income,
      expense: expense,
    );
  }
}
