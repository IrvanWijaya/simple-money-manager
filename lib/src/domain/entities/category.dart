import 'transaction_type.dart';

/// A transaction category such as `Food` or `Salary`.
///
/// Categories are seeded with exact names from the reference screens. Each
/// category belongs to a single [TransactionType]; income and expense category
/// sets do not overlap by identity.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.seedOrder = 0,
  });

  /// Stable identifier (seed id for built-in categories).
  final String id;

  /// Display name; must match reference screens exactly for seeds.
  final String name;

  /// Whether this category applies to income or expense transactions.
  final TransactionType type;

  /// Deterministic ordering index used as a stable tie-breaker in statistics
  /// and list rendering. Lower values sort first.
  final int seedOrder;

  Category copyWith({
    String? id,
    String? name,
    TransactionType? type,
    int? seedOrder,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      seedOrder: seedOrder ?? this.seedOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Category &&
      other.id == id &&
      other.name == name &&
      other.type == type &&
      other.seedOrder == seedOrder;

  @override
  int get hashCode => Object.hash(id, name, type, seedOrder);

  @override
  String toString() => 'Category($id, $name, $type)';
}
