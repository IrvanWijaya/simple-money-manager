import '../entities/category.dart';
import '../entities/transaction_type.dart';

/// Persistence boundary for transaction categories.
///
/// Implementations return domain [Category] entities only; storage rows never
/// cross this interface. The built-in category set is seeded idempotently via
/// [ensureSeeded].
abstract interface class CategoryRepository {
  /// Inserts the canonical built-in category seeds if they are not already
  /// present. Safe to call repeatedly: existing categories are never
  /// duplicated and seed labels are not altered.
  Future<void> ensureSeeded();

  /// All categories ordered by type then deterministic seed order.
  Future<List<Category>> getAll();

  /// Categories for [type] ordered by deterministic seed order.
  Future<List<Category>> getByType(TransactionType type);

  /// The category with [id], or `null` when none exists.
  Future<Category?> getById(String id);
}
