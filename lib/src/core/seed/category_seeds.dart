import '../../domain/entities/category.dart';
import '../../domain/entities/transaction_type.dart';

/// Canonical, single source of truth for the built-in category seed data.
///
/// Names must match the reference screens exactly. Order is significant: it
/// defines the deterministic display order and the stable tie-breaker used in
/// statistics. Seed ids are derived from the name so repeated initialization is
/// idempotent (no duplicate categories).
class CategorySeeds {
  CategorySeeds._();

  /// Exact income category names, in display order.
  static const List<String> incomeNames = <String>[
    'Allowance',
    'Award',
    'Bonus',
    'Dividend',
    'Investment',
    'Lottery',
    'Salary',
    'Tips',
    'Others',
    'Freelance',
  ];

  /// Exact expense category names, in display order.
  static const List<String> expenseNames = <String>[
    'Bills',
    'Clothing',
    'Education',
    'Entertainment',
    'Fitness',
    'Food',
    'Gifts',
    'Health',
    'Furniture',
    'Pet',
    'Shopping',
    'Transportation',
    'Travel',
    'Others',
    'Movie',
    'Game',
    'Wishlist',
    'Self Care',
    'Dating',
    'Device',
  ];

  /// Stable seed id for a category given its [type] and [name].
  ///
  /// `income`/`expense` is included so the income `Others` and expense `Others`
  /// categories never collide.
  static String idFor(TransactionType type, String name) {
    final slug = name.toLowerCase().replaceAll(' ', '_');
    return '${type.name}_$slug';
  }

  /// Seeded income categories in canonical order.
  static List<Category> income() => _build(TransactionType.income, incomeNames);

  /// Seeded expense categories in canonical order.
  static List<Category> expense() =>
      _build(TransactionType.expense, expenseNames);

  /// All seeded categories (income first, then expense), in canonical order.
  static List<Category> all() => <Category>[...income(), ...expense()];

  static List<Category> _build(TransactionType type, List<String> names) {
    return <Category>[
      for (var i = 0; i < names.length; i++)
        Category(
          id: idFor(type, names[i]),
          name: names[i],
          type: type,
          seedOrder: i,
        ),
    ];
  }
}
