/// The single default wallet used internally by the app.
///
/// The app does not expose multiple-wallet selection. The wallet has a base
/// balance (a starting amount independent of recorded transactions) and a
/// display name shown in the Add Transaction wallet row (for example `Cash`).
///
/// The current balance is computed dynamically as `baseBalance + sum of signed
/// transaction amounts` and is therefore not stored on the wallet itself.
class DefaultWallet {
  const DefaultWallet({this.name = 'Cash', this.baseBalance = 0});

  /// Display name for the wallet (for example `Cash`).
  final String name;

  /// Starting balance in whole Rupiah, independent of recorded transactions.
  final int baseBalance;

  /// The all-time balance given the net signed total of all transactions.
  ///
  /// [signedTransactionTotal] is the sum of every transaction's signed amount
  /// (income positive, expense negative).
  int balanceWith(int signedTransactionTotal) =>
      baseBalance + signedTransactionTotal;

  DefaultWallet copyWith({String? name, int? baseBalance}) {
    return DefaultWallet(
      name: name ?? this.name,
      baseBalance: baseBalance ?? this.baseBalance,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DefaultWallet &&
      other.name == name &&
      other.baseBalance == baseBalance;

  @override
  int get hashCode => Object.hash(name, baseBalance);

  @override
  String toString() => 'DefaultWallet($name, base: $baseBalance)';
}
