import 'package:flutter/material.dart';

/// The four selectable destinations in the main app shell.
///
/// The centered add action is intentionally NOT a tab here: it is a distinct
/// primary action that opens Add Transaction rather than swapping shell content.
enum ShellTab {
  transaction(label: 'Transaction', icon: Icons.receipt_long_outlined),
  calendar(label: 'Calendar', icon: Icons.calendar_today_outlined),
  statistic(label: 'Statistic', icon: Icons.pie_chart_outline),
  wallet(label: 'Wallet', icon: Icons.account_balance_wallet_outlined);

  const ShellTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
