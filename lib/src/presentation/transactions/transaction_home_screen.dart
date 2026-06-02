import 'package:flutter/material.dart';

import '../shared/period/home_header.dart';
import '../shared/period/period_overview.dart';
import 'widgets/transaction_list.dart';

/// Transaction tab surface (default landing tab).
///
/// Hosts the shared balance/period header, the computed period overview, and
/// the date-grouped transaction list. The list filters by the shared active
/// period, groups by day with computed totals, orders newest-first, and surfaces
/// due recurring occurrences once per period.
class TransactionHomeScreen extends StatelessWidget {
  const TransactionHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeHeader(),
          SizedBox(height: 8),
          PeriodOverview(),
          SizedBox(height: 12),
          Expanded(child: TransactionList()),
        ],
      ),
    );
  }
}
