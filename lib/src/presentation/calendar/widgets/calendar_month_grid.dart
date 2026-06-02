import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../domain/entities/period_summary.dart';
import '../calendar_providers.dart';

/// Sunday-start month grid for the Calendar surface.
///
/// Renders the month anchored by [calendarGridMonthProvider] with weekday
/// labels starting on Sunday (Sunday shown in red, VAL-CAL-002). Leading and
/// trailing days from adjacent months complete the 7-column weeks and are
/// dimmed (VAL-CAL-004). The current date is highlighted when it falls in the
/// displayed month (VAL-CAL-003). Day cells show computed income/expense totals
/// from [calendarDayTotalsProvider] only for days that have transactions in the
/// active period (VAL-CAL-005, VAL-CAL-006).
class CalendarMonthGrid extends ConsumerWidget {
  const CalendarMonthGrid({super.key});

  static const List<String> _weekdayLabels = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(calendarGridMonthProvider);
    final today = ref.watch(todayProvider);
    final totals = ref
        .watch(calendarDayTotalsProvider)
        .maybeWhen(
          data: (value) => value,
          orElse: () => const <DateTime, PeriodSummary>{},
        );

    final cells = _buildCells(month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var i = 0; i < _weekdayLabels.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    _weekdayLabels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: i == 0
                          ? AppColors.expense
                          : AppColors.onBackground,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Expanded(
          child: Column(
            key: const ValueKey('calendar-grid'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var week = 0; week < cells.length ~/ 7; week++)
                Expanded(
                  child: Row(
                    children: [
                      for (var day = 0; day < 7; day++)
                        Expanded(
                          child: _buildCell(
                            cells[week * 7 + day],
                            today,
                            totals,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCell(
    _CalendarCell cell,
    DateTime today,
    Map<DateTime, PeriodSummary> totals,
  ) {
    final isToday =
        cell.inMonth &&
        cell.date.year == today.year &&
        cell.date.month == today.month &&
        cell.date.day == today.day;
    return _DayCell(
      date: cell.date,
      inMonth: cell.inMonth,
      isToday: isToday,
      summary: cell.inMonth ? totals[cell.date] : null,
    );
  }

  /// Builds the ordered list of grid cells: leading overflow days, the month's
  /// days, then trailing overflow days, completing whole Sunday-start weeks.
  List<_CalendarCell> _buildCells(DateTime month) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    // DateTime.weekday is Mon=1..Sun=7; `% 7` maps Sunday to 0 leading offset.
    final leading = firstOfMonth.weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final totalCells = ((leading + daysInMonth + 6) ~/ 7) * 7;

    return [
      for (var i = 0; i < totalCells; i++)
        _cellFor(firstOfMonth, i - leading, daysInMonth),
    ];
  }

  _CalendarCell _cellFor(
    DateTime firstOfMonth,
    int dayOffset,
    int daysInMonth,
  ) {
    final date = DateTime(firstOfMonth.year, firstOfMonth.month, 1 + dayOffset);
    final inMonth = dayOffset >= 0 && dayOffset < daysInMonth;
    return _CalendarCell(date: date, inMonth: inMonth);
  }
}

class _CalendarCell {
  const _CalendarCell({required this.date, required this.inMonth});

  final DateTime date;
  final bool inMonth;
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.inMonth,
    required this.isToday,
    required this.summary,
  });

  final DateTime date;
  final bool inMonth;
  final bool isToday;
  final PeriodSummary? summary;

  @override
  Widget build(BuildContext context) {
    final isSunday = date.weekday == DateTime.sunday;
    final dayColor = !inMonth
        ? AppColors.onBackground.withValues(alpha: 0.3)
        : isSunday
        ? AppColors.expense
        : AppColors.onBackground;

    final dayKey = inMonth
        ? ValueKey('calendar-day-${_iso(date)}')
        : ValueKey('calendar-overflow-${_iso(date)}');

    return Container(
      key: dayKey,
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        border: isToday
            ? Border.all(color: AppColors.primary, width: 1.5)
            : null,
        borderRadius: BorderRadius.circular(4),
        color: isToday ? AppColors.primary.withValues(alpha: 0.15) : null,
      ),
      child: Column(
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              color: dayColor,
              fontSize: 12,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          if (summary != null) ...[
            const SizedBox(height: 2),
            if (summary!.income > 0)
              Text(
                MoneyFormatter.formatNumber(summary!.income),
                key: ValueKey('calendar-income-${_iso(date)}'),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.income,
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (summary!.expense > 0)
              Text(
                '-${MoneyFormatter.formatNumber(summary!.expense)}',
                key: ValueKey('calendar-expense-${_iso(date)}'),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.expense,
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ],
      ),
    );
  }

  static String _iso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
