import '../entities/default_wallet.dart';

/// Persistence boundary for the single default wallet settings.
///
/// The app exposes exactly one wallet. Only its configurable settings (display
/// name and base balance) are persisted; the current balance is computed
/// dynamically from transactions and is never stored.
abstract interface class WalletRepository {
  /// The persisted wallet settings, or sensible defaults when none are stored.
  Future<DefaultWallet> getWallet();

  /// Persists the wallet settings.
  Future<void> saveWallet(DefaultWallet wallet);
}
