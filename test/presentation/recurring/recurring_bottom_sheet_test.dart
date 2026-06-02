// Widget tests for the Recurring bottom sheet.
//
// Covers VAL-RECUI-001 (titled Recurring with None/Daily/Weekly/Monthly/Yearly),
// VAL-RECUI-002 (CANCEL discards), VAL-RECUI-003 (DONE applies), VAL-RECUI-004
// (weekly/monthly/yearly reveal interval/repeat/end), VAL-RECUI-010 (daily
// exposes interval/end but no repeat position), VAL-RECUI-011 (None clears),
// VAL-RECUI-013 (reopen restores applied config), and VAL-RECUI-014 (end
// conditions selectable).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_money_manager/src/domain/entities/recurring_end_condition.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_frequency.dart';
import 'package:simple_money_manager/src/domain/entities/recurring_repeat_position.dart';
import 'package:simple_money_manager/src/presentation/recurring/recurring_bottom_sheet.dart';
import 'package:simple_money_manager/src/presentation/recurring/recurring_selection.dart';

/// Mounts a button that opens the sheet and records the returned selection.
Widget _host({
  required RecurringSelection initial,
  required void Function(RecurringSelection?) onResult,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            key: const ValueKey('open-sheet'),
            onPressed: () async {
              final result = await showRecurringBottomSheet(
                context,
                initial: initial,
              );
              onResult(result);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('open-sheet')));
  await tester.pumpAndSettle();
}

/// Scrolls [finder] into view (sheet content can exceed the viewport) then taps.
Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('opens titled Recurring with all five frequency options', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(initial: RecurringSelection.none, onResult: (_) {}),
    );
    await _openSheet(tester);

    expect(find.byKey(const ValueKey('recurring-sheet-title')), findsOneWidget);
    for (final f in RecurringFrequency.values) {
      expect(
        find.byKey(ValueKey('recurring-option-${f.name}')),
        findsOneWidget,
        reason: 'expected option for ${f.name}',
      );
    }
    expect(find.text('None'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);
  });

  testWidgets('None hides interval/repeat/end controls', (tester) async {
    await tester.pumpWidget(
      _host(initial: RecurringSelection.none, onResult: (_) {}),
    );
    await _openSheet(tester);

    expect(
      find.byKey(const ValueKey('recurring-interval-label')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('recurring-repeat-sameDay')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('recurring-end-forever')), findsNothing);
  });

  testWidgets('Daily exposes interval and end but not repeat position', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(initial: RecurringSelection.none, onResult: (_) {}),
    );
    await _openSheet(tester);

    await tester.tap(find.byKey(const ValueKey('recurring-option-daily')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recurring-interval-label')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('recurring-end-forever')), findsOneWidget);
    // No repeat-position section for daily.
    expect(
      find.byKey(const ValueKey('recurring-repeat-sameDay')),
      findsNothing,
    );
  });

  testWidgets('Monthly reveals interval, repeat position, and end controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(initial: RecurringSelection.none, onResult: (_) {}),
    );
    await _openSheet(tester);

    await tester.tap(find.byKey(const ValueKey('recurring-option-monthly')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('recurring-interval-label')),
      findsOneWidget,
    );
    for (final p in RecurringRepeatPosition.values) {
      expect(
        find.byKey(ValueKey('recurring-repeat-${p.name}')),
        findsOneWidget,
      );
    }
    expect(find.byKey(const ValueKey('recurring-end-forever')), findsOneWidget);
  });

  testWidgets('DONE applies the selected configuration (VAL-RECUI-003)', (
    tester,
  ) async {
    RecurringSelection? result;
    await tester.pumpWidget(
      _host(
        initial: RecurringSelection.none,
        onResult: (value) => result = value,
      ),
    );
    await _openSheet(tester);

    await tester.tap(find.byKey(const ValueKey('recurring-option-monthly')));
    await tester.pumpAndSettle();
    await _tapVisible(
      tester,
      find.byKey(const ValueKey('recurring-interval-increment')),
    );
    await _tapVisible(tester, find.byKey(const ValueKey('recurring-done')));

    expect(result, isNotNull);
    expect(result!.frequency, RecurringFrequency.monthly);
    expect(result!.interval, 2);
  });

  testWidgets('CANCEL discards changes and returns null (VAL-RECUI-002)', (
    tester,
  ) async {
    var called = false;
    RecurringSelection? result;
    await tester.pumpWidget(
      _host(
        initial: RecurringSelection.none,
        onResult: (value) {
          called = true;
          result = value;
        },
      ),
    );
    await _openSheet(tester);

    await tester.tap(find.byKey(const ValueKey('recurring-option-weekly')));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.byKey(const ValueKey('recurring-cancel')));

    expect(called, isTrue);
    expect(result, isNull);
  });

  testWidgets('None then DONE clears configuration (VAL-RECUI-011)', (
    tester,
  ) async {
    RecurringSelection? result;
    await tester.pumpWidget(
      _host(
        initial: const RecurringSelection(
          frequency: RecurringFrequency.monthly,
        ),
        onResult: (value) => result = value,
      ),
    );
    await _openSheet(tester);

    await tester.tap(find.byKey(const ValueKey('recurring-option-none')));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.byKey(const ValueKey('recurring-done')));

    expect(result, RecurringSelection.none);
    expect(result!.isRecurring, isFalse);
  });

  testWidgets('reopening shows the applied configuration (VAL-RECUI-013)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        initial: const RecurringSelection(
          frequency: RecurringFrequency.monthly,
          interval: 3,
          repeatPosition: RecurringRepeatPosition.endOfPeriod,
          endCondition: RecurringEndCondition.count,
          endCount: 4,
        ),
        onResult: (_) {},
      ),
    );
    await _openSheet(tester);

    // Monthly is checked.
    final monthlyRadio = tester.widget<Icon>(
      find.byKey(const ValueKey('recurring-option-radio-monthly')),
    );
    expect(monthlyRadio.icon, Icons.radio_button_checked);
    // Interval reflects 3.
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('recurring-interval-value')))
          .data,
      '3',
    );
    // The count end-condition field is shown.
    expect(
      find.byKey(const ValueKey('recurring-end-count-field')),
      findsOneWidget,
    );
  });

  testWidgets('end conditions are selectable and applied (VAL-RECUI-014)', (
    tester,
  ) async {
    RecurringSelection? result;
    await tester.pumpWidget(
      _host(
        initial: const RecurringSelection(frequency: RecurringFrequency.daily),
        onResult: (value) => result = value,
      ),
    );
    await _openSheet(tester);

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('recurring-end-count')),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('recurring-end-count-field')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('recurring-end-count-field')),
      '7',
    );
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.byKey(const ValueKey('recurring-done')));

    expect(result!.endCondition, RecurringEndCondition.count);
    expect(result!.endCount, 7);
  });
}
