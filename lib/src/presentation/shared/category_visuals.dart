import 'package:flutter/material.dart';

import '../../domain/entities/transaction_type.dart';

/// Maps category ids/names to suitable Material icons for list rows.
///
/// Icons are illustrative only; exact icon matching to the reference screens is
/// not required by the mission. Lookups fall back to a sensible default per
/// transaction type so any seeded or future category still renders an icon.
class CategoryVisuals {
  CategoryVisuals._();

  static const Map<String, IconData> _byId = <String, IconData>{
    // Income
    'income_allowance': Icons.volunteer_activism,
    'income_award': Icons.emoji_events,
    'income_bonus': Icons.card_giftcard,
    'income_dividend': Icons.account_balance,
    'income_investment': Icons.trending_up,
    'income_lottery': Icons.confirmation_number,
    'income_salary': Icons.payments,
    'income_tips': Icons.attach_money,
    'income_others': Icons.more_horiz,
    'income_freelance': Icons.work_outline,
    // Expense
    'expense_bills': Icons.receipt_long,
    'expense_clothing': Icons.checkroom,
    'expense_education': Icons.school,
    'expense_entertainment': Icons.celebration,
    'expense_fitness': Icons.fitness_center,
    'expense_food': Icons.restaurant,
    'expense_gifts': Icons.redeem,
    'expense_health': Icons.favorite,
    'expense_furniture': Icons.chair,
    'expense_pet': Icons.pets,
    'expense_shopping': Icons.shopping_bag,
    'expense_transportation': Icons.directions_bus,
    'expense_travel': Icons.flight,
    'expense_others': Icons.more_horiz,
    'expense_movie': Icons.movie,
    'expense_game': Icons.sports_esports,
    'expense_wishlist': Icons.star_border,
    'expense_self_care': Icons.spa,
    'expense_dating': Icons.favorite_border,
    'expense_device': Icons.devices,
  };

  /// Returns an icon for the category [id], falling back by [type] when the id
  /// is unknown (for example a category added in a future build).
  static IconData iconForId(String id, {TransactionType? type}) {
    final icon = _byId[id];
    if (icon != null) return icon;
    if (type != null && type.isIncome) return Icons.attach_money;
    return Icons.category_outlined;
  }

  /// Palette used for the bright circular category backgrounds. Colors are
  /// illustrative only; exact matching to the reference is not required.
  static const List<Color> _palette = <Color>[
    Color(0xFFE57373),
    Color(0xFF64B5F6),
    Color(0xFF81C784),
    Color(0xFFFFB74D),
    Color(0xFFBA68C8),
    Color(0xFF4DB6AC),
    Color(0xFFF06292),
    Color(0xFF9575CD),
    Color(0xFF4FC3F7),
    Color(0xFFAED581),
    Color(0xFFFF8A65),
    Color(0xFF7986CB),
  ];

  /// Returns a stable, bright background color for the category [id]'s circular
  /// icon. The same id always maps to the same color across screens.
  static Color colorForId(String id) {
    var hash = 0;
    for (final unit in id.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return _palette[hash % _palette.length];
  }
}
