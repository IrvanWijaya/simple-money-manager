/// The wallet name plus its computed all-time balance, for display in the
/// Add Transaction wallet row (for example `Cash · Rp 1,000,000`).
///
/// Derived value object combining the persisted wallet name with the
/// dynamically computed current balance; never persisted.
class WalletDisplay {
  const WalletDisplay({required this.name, required this.balance});

  /// Display name of the wallet (for example `Cash`).
  final String name;

  /// All-time current balance in whole Rupiah.
  final int balance;

  @override
  bool operator ==(Object other) =>
      other is WalletDisplay && other.name == name && other.balance == balance;

  @override
  int get hashCode => Object.hash(name, balance);

  @override
  String toString() => 'WalletDisplay($name, balance: $balance)';
}
