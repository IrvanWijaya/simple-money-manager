import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/money_formatter.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/recurring_frequency.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/entities/wallet_display.dart';
import '../categories/category_selection_screen.dart';
import '../recurring/recurring_bottom_sheet.dart';
import '../recurring/recurring_selection.dart';
import '../shared/category_visuals.dart';
import 'add_transaction_draft.dart';
import 'add_transaction_providers.dart';

/// Add Transaction screen.
///
/// Opens in the Expense state with Income/Expense tabs (no Transfer), a visible
/// SAVE action, and the required form fields: date, time, recurring action,
/// amount, description, category, a display-only single wallet row, and memo.
/// SAVE persists a transaction only when a positive amount and a category are
/// present; the stored sign is derived from the selected type. A successful
/// save closes the form and refreshes the home surfaces; pressing back without
/// saving creates nothing.
class AddTransactionScreen extends ConsumerWidget {
  const AddTransactionScreen({
    super.key,
    this.initialRecurring = RecurringSelection.none,
  });

  /// Seeds the form's recurring configuration. The Wallet `+ Add Recurring`
  /// entry point passes a recurring default so the form opens already in
  /// recurring-creation mode (VAL-RECUI-008); the regular Add Transaction entry
  /// uses [RecurringSelection.none].
  final RecurringSelection initialRecurring;

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(addTransactionControllerProvider(initialRecurring));
    final controller = ref.read(
      addTransactionControllerProvider(initialRecurring).notifier,
    );
    final title = draft.type.isExpense ? 'Expense' : 'Income';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(title, key: const ValueKey('add-transaction-title')),
        actions: [
          TextButton(
            key: const ValueKey('add-transaction-save'),
            onPressed: () => _onSave(context, ref),
            child: const Text(
              'SAVE',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _TypeTabs(type: draft.type, onChanged: controller.setType),
            const SizedBox(height: 8),
            _DateTimeRow(
              date: draft.date,
              recurring: draft.recurring,
              dateFormat: _dateFormat,
              timeFormat: _timeFormat,
              onPickDate: () => _pickDate(context, ref),
              onPickTime: () => _pickTime(context, ref),
              onPickRecurring: () => _pickRecurring(context, ref),
            ),
            const Divider(height: 1, color: AppColors.surface),
            _AmountField(amount: draft.amount, onChanged: controller.setAmount),
            const Divider(height: 1, color: AppColors.surface),
            _DescriptionField(
              initialValue: draft.description,
              onChanged: controller.setDescription,
            ),
            const Divider(height: 1, color: AppColors.surface),
            _CategoryRow(
              category: draft.category,
              onTap: () => _pickCategory(context, ref),
            ),
            const Divider(height: 1, color: AppColors.surface),
            _WalletRow(
              walletAsync: ref.watch(addTransactionWalletDisplayProvider),
            ),
            const Divider(height: 1, color: AppColors.surface),
            _MemoField(initialValue: draft.memo, onChanged: controller.setMemo),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(
      addTransactionControllerProvider(initialRecurring).notifier,
    );
    final saved = await controller.save();
    if (!saved) {
      if (context.mounted) {
        _showValidationFeedback(
          context,
          ref.read(addTransactionControllerProvider(initialRecurring)),
        );
      }
      return;
    }
    refreshTransactionDerivedData(ref);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showValidationFeedback(
    BuildContext context,
    AddTransactionDraft draft,
  ) {
    final message = draft.amount <= 0
        ? 'Enter an amount greater than zero'
        : 'Select a category';
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          key: const ValueKey('add-transaction-validation'),
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(
      addTransactionControllerProvider(initialRecurring).notifier,
    );
    final current = ref
        .read(addTransactionControllerProvider(initialRecurring))
        .date;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    controller.setDate(
      DateTime(
        picked.year,
        picked.month,
        picked.day,
        current.hour,
        current.minute,
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(
      addTransactionControllerProvider(initialRecurring).notifier,
    );
    final current = ref
        .read(addTransactionControllerProvider(initialRecurring))
        .date;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked == null) return;
    controller.setDate(
      DateTime(
        current.year,
        current.month,
        current.day,
        picked.hour,
        picked.minute,
      ),
    );
  }

  Future<void> _pickCategory(BuildContext context, WidgetRef ref) async {
    final draft = ref.read(addTransactionControllerProvider(initialRecurring));
    final selected = await Navigator.of(context).push<Category>(
      MaterialPageRoute<Category>(
        builder: (_) => CategorySelectionScreen(
          initialType: draft.type,
          selectedCategoryId: draft.category?.id,
        ),
      ),
    );
    if (selected == null) return;
    ref
        .read(addTransactionControllerProvider(initialRecurring).notifier)
        .setCategory(selected);
  }

  /// Opens the Recurring bottom sheet over the dimmed form. On DONE the returned
  /// selection (which may be None) is applied to the draft; on CANCEL nothing
  /// changes (VAL-RECUI-001, -002, -003, -011).
  Future<void> _pickRecurring(BuildContext context, WidgetRef ref) async {
    final draft = ref.read(addTransactionControllerProvider(initialRecurring));
    final result = await showRecurringBottomSheet(
      context,
      initial: draft.recurring,
    );
    if (result == null) return;
    ref
        .read(addTransactionControllerProvider(initialRecurring).notifier)
        .setRecurring(result);
  }
}

/// Income/Expense segmented tabs. Expense is highlighted in red, Income in
/// green, matching the reference. No third (Transfer) option is offered.
class _TypeTabs extends StatelessWidget {
  const _TypeTabs({required this.type, required this.onChanged});

  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _TypeTabButton(
              key: const ValueKey('add-transaction-tab-income'),
              label: 'Income',
              selected: type.isIncome,
              color: AppColors.income,
              onTap: () => onChanged(TransactionType.income),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TypeTabButton(
              key: const ValueKey('add-transaction-tab-expense'),
              label: 'Expense',
              selected: type.isExpense,
              color: AppColors.expense,
              onTap: () => onChanged(TransactionType.expense),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeTabButton extends StatelessWidget {
  const _TypeTabButton({
    super.key,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({
    required this.date,
    required this.recurring,
    required this.dateFormat,
    required this.timeFormat,
    required this.onPickDate,
    required this.onPickTime,
    required this.onPickRecurring,
  });

  final DateTime date;
  final RecurringSelection recurring;
  final DateFormat dateFormat;
  final DateFormat timeFormat;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final VoidCallback onPickRecurring;

  static const Map<RecurringFrequency, String> _frequencyLabels = {
    RecurringFrequency.daily: 'Daily',
    RecurringFrequency.weekly: 'Weekly',
    RecurringFrequency.monthly: 'Monthly',
    RecurringFrequency.yearly: 'Yearly',
  };

  @override
  Widget build(BuildContext context) {
    final isRecurring = recurring.isRecurring;
    final recurringLabel = isRecurring
        ? (_frequencyLabels[recurring.frequency] ?? 'Recurring')
        : 'Recurring';
    final recurringColor = isRecurring
        ? AppColors.primary
        : AppColors.onBackground;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          TextButton.icon(
            key: const ValueKey('add-transaction-date'),
            onPressed: onPickDate,
            icon: const Icon(Icons.event, size: 18),
            label: Text(
              dateFormat.format(date),
              style: const TextStyle(color: AppColors.onBackground),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            key: const ValueKey('add-transaction-time'),
            onPressed: onPickTime,
            icon: const Icon(Icons.schedule, size: 18),
            label: Text(
              timeFormat.format(date),
              style: const TextStyle(color: AppColors.onBackground),
            ),
          ),
          const Spacer(),
          // Opens the Recurring bottom sheet; the label reflects the applied
          // frequency once a configuration has been chosen (VAL-RECUI-003).
          TextButton.icon(
            key: const ValueKey('add-transaction-recurring'),
            onPressed: onPickRecurring,
            icon: Icon(Icons.repeat, size: 18, color: recurringColor),
            label: Text(
              recurringLabel,
              key: const ValueKey('add-transaction-recurring-label'),
              style: TextStyle(color: recurringColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Amount entry. Displays the running Rupiah value and parses digits into a
/// non-negative integer magnitude; the sign is applied by the transaction type
/// at save, never by user punctuation (VAL-ADD-011).
class _AmountField extends StatefulWidget {
  const _AmountField({required this.amount, required this.onChanged});

  final int amount;
  final ValueChanged<int> onChanged;

  @override
  State<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<_AmountField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.amount == 0
          ? ''
          : MoneyFormatter.formatNumber(widget.amount),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChange(String raw) {
    final value = MoneyFormatter.parse(raw).abs();
    widget.onChanged(value);
    final formatted = value == 0 ? '' : MoneyFormatter.formatNumber(value);
    _controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Text(
            MoneyFormatter.symbol,
            style: TextStyle(color: AppColors.onBackground, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: const ValueKey('add-transaction-amount'),
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: _handleChange,
              style: const TextStyle(
                color: AppColors.onBackground,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: '0',
                hintStyle: TextStyle(color: Colors.white24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionField extends StatefulWidget {
  const _DescriptionField({
    required this.initialValue,
    required this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<_DescriptionField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        key: const ValueKey('add-transaction-description'),
        controller: _controller,
        onChanged: widget.onChanged,
        style: const TextStyle(color: AppColors.onBackground),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Short description',
          hintStyle: TextStyle(color: Colors.white24),
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.onTap});

  final Category? category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasCategory = category != null;
    return ListTile(
      key: const ValueKey('add-transaction-category'),
      onTap: onTap,
      leading: Icon(
        hasCategory
            ? CategoryVisuals.iconForId(category!.id, type: category!.type)
            : Icons.category_outlined,
        color: AppColors.onBackground,
      ),
      title: Text(
        hasCategory ? category!.name : 'Select Category',
        style: TextStyle(
          color: hasCategory ? AppColors.onBackground : Colors.white38,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.onBackground),
    );
  }
}

/// Display-only wallet row (`Cash · <balance>`). It is intentionally not
/// tappable: the app uses a single internal wallet and never exposes a wallet
/// picker or alternate wallet selection (VAL-ADD-004).
class _WalletRow extends StatelessWidget {
  const _WalletRow({required this.walletAsync});

  final AsyncValue<WalletDisplay> walletAsync;

  @override
  Widget build(BuildContext context) {
    final label = walletAsync.maybeWhen(
      data: (wallet) =>
          '${wallet.name} · ${MoneyFormatter.format(wallet.balance)}',
      orElse: () => 'Cash',
    );
    return ListTile(
      key: const ValueKey('add-transaction-wallet'),
      enabled: false,
      leading: const Icon(
        Icons.account_balance_wallet_outlined,
        color: AppColors.onBackground,
      ),
      title: Text(label, style: const TextStyle(color: AppColors.onBackground)),
    );
  }
}

class _MemoField extends StatefulWidget {
  const _MemoField({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_MemoField> createState() => _MemoFieldState();
}

class _MemoFieldState extends State<_MemoField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        key: const ValueKey('add-transaction-memo'),
        controller: _controller,
        onChanged: widget.onChanged,
        minLines: 1,
        maxLines: 3,
        style: const TextStyle(color: AppColors.onBackground),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Add a note...',
          hintStyle: TextStyle(color: Colors.white24),
        ),
      ),
    );
  }
}
