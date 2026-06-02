import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../calendar/calendar_home_screen.dart';
import '../statistics/statistic_home_screen.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transaction_home_screen.dart';
import '../wallet/wallet_home_screen.dart';
import 'shell_controller.dart';
import 'shell_tab.dart';

/// The main dark-themed app shell.
///
/// Hosts the four selectable surfaces (Transaction, Calendar, Statistic,
/// Wallet) behind a bottom navigation bar with a centered primary add action.
/// The add action opens Add Transaction from any tab and returns to the
/// originating tab, because the selected tab is held in [shellTabControllerProvider]
/// and never changed by the add flow.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(shellTabControllerProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedTab.index,
        children: const [
          TransactionHomeScreen(),
          CalendarHomeScreen(),
          StatisticHomeScreen(),
          WalletHomeScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'shell-add-transaction',
        tooltip: 'Add Transaction',
        backgroundColor: AppColors.primary,
        onPressed: () => _openAddTransaction(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _ShellBottomBar(
        selectedTab: selectedTab,
        onSelect: (tab) =>
            ref.read(shellTabControllerProvider.notifier).select(tab),
      ),
    );
  }

  Future<void> _openAddTransaction(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
  }
}

/// Bottom navigation bar with a notch for the centered add button.
///
/// Tabs are laid out as: Transaction, Calendar, [gap for center add],
/// Statistic, Wallet.
class _ShellBottomBar extends StatelessWidget {
  const _ShellBottomBar({required this.selectedTab, required this.onSelect});

  final ShellTab selectedTab;
  final ValueChanged<ShellTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            _ShellTabButton(
              tab: ShellTab.transaction,
              selected: selectedTab == ShellTab.transaction,
              onSelect: onSelect,
            ),
            _ShellTabButton(
              tab: ShellTab.calendar,
              selected: selectedTab == ShellTab.calendar,
              onSelect: onSelect,
            ),
            const Expanded(child: SizedBox.shrink()),
            _ShellTabButton(
              tab: ShellTab.statistic,
              selected: selectedTab == ShellTab.statistic,
              onSelect: onSelect,
            ),
            _ShellTabButton(
              tab: ShellTab.wallet,
              selected: selectedTab == ShellTab.wallet,
              onSelect: onSelect,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellTabButton extends StatelessWidget {
  const _ShellTabButton({
    required this.tab,
    required this.selected,
    required this.onSelect,
  });

  final ShellTab tab;
  final bool selected;
  final ValueChanged<ShellTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.onBackground;

    return Expanded(
      child: InkWell(
        onTap: () => onSelect(tab),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tab.icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(tab.label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
