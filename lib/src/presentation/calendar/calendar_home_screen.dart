import 'package:flutter/material.dart';

import '../shared/period/home_header.dart';
import '../shared/period/period_overview.dart';
import 'widgets/calendar_month_grid.dart';

/// Calendar tab surface.
///
/// Hosts the shared balance/period header, the computed period overview (which
/// matches the Transaction summary for the same period, VAL-CAL-001), and a
/// Sunday-start month grid with current-date highlight, dimmed overflow days,
/// and computed daily income/expense totals. Period navigation in the shared
/// header updates both the summary and the grid (VAL-CAL-006).
class CalendarHomeScreen extends StatelessWidget {
  const CalendarHomeScreen({super.key});

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
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: CalendarMonthGrid(),
            ),
          ),
        ],
      ),
    );
  }
}
