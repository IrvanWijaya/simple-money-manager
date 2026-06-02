import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction_type.dart';
import '../shared/category_visuals.dart';
import 'category_providers.dart';

/// Category Selection screen, opened from Add Transaction.
///
/// Shows a back button, the title `Select Category`, a settings icon, and
/// Income/Expense tabs. The tabs never mix types: each tab lists only its own
/// seeded categories, with the exact reference names. The initial tab matches
/// the transaction type the form was on. Each row shows a colored circular
/// icon, the category name, and a radio selector reflecting the currently
/// selected category. Tapping a row pops the screen and returns the chosen
/// [Category]; pressing back returns nothing so the form keeps its prior
/// selection. The settings icon does not expose custom category creation.
class CategorySelectionScreen extends ConsumerStatefulWidget {
  const CategorySelectionScreen({
    super.key,
    required this.initialType,
    this.selectedCategoryId,
  });

  /// The transaction type the form is on; selects the initial tab and the type
  /// of category that can be returned.
  final TransactionType initialType;

  /// Id of the category currently chosen on the form, if any, so the matching
  /// row shows its radio selected when the screen opens or is reopened.
  final String? selectedCategoryId;

  @override
  ConsumerState<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState
    extends ConsumerState<CategorySelectionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const List<TransactionType> _tabs = <TransactionType>[
    TransactionType.income,
    TransactionType.expense,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: _tabs.indexOf(widget.initialType),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _select(Category category) {
    Navigator.of(context).pop(category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const ValueKey('category-selection-back'),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Select Category',
          key: ValueKey('category-selection-title'),
        ),
        actions: [
          IconButton(
            key: const ValueKey('category-selection-settings'),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => _showSettings(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.onBackground,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(key: ValueKey('category-selection-tab-income'), text: 'Income'),
            Tab(
              key: ValueKey('category-selection-tab-expense'),
              text: 'Expense',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          for (final type in _tabs)
            _CategoryList(
              type: type,
              selectedCategoryId: widget.selectedCategoryId,
              onSelect: _select,
            ),
        ],
      ),
    );
  }

  /// Settings affordance. The fixed category lists cannot be edited and there
  /// is no custom category creation in scope (VAL-CATSEL-010); this simply
  /// surfaces that the lists are built in.
  void _showSettings(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const ValueKey('category-selection-settings-dialog'),
        backgroundColor: AppColors.surface,
        title: const Text('Categories'),
        content: const Text('Categories are built in and cannot be edited.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  const _CategoryList({
    required this.type,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  final TransactionType type;
  final String? selectedCategoryId;
  final ValueChanged<Category> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesByTypeProvider(type));
    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(
        child: Text(
          'Could not load categories',
          style: TextStyle(color: AppColors.onBackground),
        ),
      ),
      data: (categories) => ListView.builder(
        key: ValueKey('category-selection-list-${type.name}'),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category.id == selectedCategoryId;
          return _CategoryRow(
            category: category,
            selected: selected,
            onTap: () => onSelect(category),
          );
        },
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey('category-row-${category.id}'),
      onTap: onTap,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: CategoryVisuals.colorForId(category.id),
        child: Icon(
          CategoryVisuals.iconForId(category.id, type: category.type),
          size: 18,
          color: Colors.white,
        ),
      ),
      title: Text(
        category.name,
        style: const TextStyle(color: AppColors.onBackground),
      ),
      trailing: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        key: ValueKey('category-radio-${category.id}'),
        color: selected ? AppColors.primary : Colors.white38,
      ),
    );
  }
}
