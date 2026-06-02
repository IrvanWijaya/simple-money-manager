import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/recurring_end_condition.dart';
import '../../domain/entities/recurring_frequency.dart';
import '../../domain/entities/recurring_repeat_position.dart';
import 'recurring_selection.dart';

/// Opens the Recurring bottom sheet over the (dimmed) current screen.
///
/// The sheet starts from [initial] so reopening it after applying a
/// configuration restores the same frequency, interval, repeat position, and
/// end condition (VAL-RECUI-013). Returns the applied [RecurringSelection] when
/// the user taps DONE, or `null` when they tap CANCEL / dismiss the sheet,
/// leaving the caller's prior selection untouched (VAL-RECUI-002).
Future<RecurringSelection?> showRecurringBottomSheet(
  BuildContext context, {
  RecurringSelection initial = RecurringSelection.none,
}) {
  return showModalBottomSheet<RecurringSelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    barrierColor: Colors.black54,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => RecurringBottomSheet(initial: initial),
  );
}

/// Bottom sheet body for configuring a recurring rule.
///
/// Frequency choices are None/Daily/Weekly/Monthly/Yearly. Daily exposes an
/// interval and an end condition only; Weekly/Monthly/Yearly additionally
/// expose a repeat-position choice (VAL-RECUI-004, -010). None hides all detail
/// controls and clears the configuration on DONE (VAL-RECUI-011). CANCEL
/// discards changes; DONE applies them (VAL-RECUI-002, -003).
class RecurringBottomSheet extends StatefulWidget {
  const RecurringBottomSheet({
    super.key,
    this.initial = RecurringSelection.none,
  });

  final RecurringSelection initial;

  @override
  State<RecurringBottomSheet> createState() => _RecurringBottomSheetState();
}

class _RecurringBottomSheetState extends State<RecurringBottomSheet> {
  late RecurringSelection _selection;

  @override
  void initState() {
    super.initState();
    _selection = widget.initial;
  }

  void _setFrequency(RecurringFrequency frequency) {
    setState(() => _selection = _selection.copyWith(frequency: frequency));
  }

  void _changeInterval(int delta) {
    final next = (_selection.interval + delta).clamp(1, 999);
    setState(() => _selection = _selection.copyWith(interval: next));
  }

  void _setRepeatPosition(RecurringRepeatPosition position) {
    setState(() => _selection = _selection.copyWith(repeatPosition: position));
  }

  void _setEndCondition(RecurringEndCondition condition) {
    setState(() {
      switch (condition) {
        case RecurringEndCondition.forever:
          _selection = _selection.copyWith(
            endCondition: condition,
            clearEndCount: true,
            clearEndDate: true,
          );
        case RecurringEndCondition.count:
          _selection = _selection.copyWith(
            endCondition: condition,
            endCount: _selection.endCount ?? 1,
            clearEndDate: true,
          );
        case RecurringEndCondition.endDate:
          _selection = _selection.copyWith(
            endCondition: condition,
            endDate: _selection.endDate ?? _defaultEndDate(),
            clearEndCount: true,
          );
      }
    });
  }

  DateTime _defaultEndDate() {
    final now = DateTime.now();
    return DateTime(now.year + 1, now.month, now.day);
  }

  void _setEndCount(int count) {
    setState(
      () => _selection = _selection.copyWith(endCount: count < 1 ? 1 : count),
    );
  }

  Future<void> _pickEndDate() async {
    final current = _selection.endDate ?? _defaultEndDate();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _selection = _selection.copyWith(endDate: picked));
  }

  @override
  Widget build(BuildContext context) {
    final showDetails = _selection.isRecurring;
    final showPosition = _selection.supportsRepeatPosition;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Recurring',
                  key: ValueKey('recurring-sheet-title'),
                  style: TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.background),
              for (final frequency in RecurringFrequency.values)
                _FrequencyOption(
                  frequency: frequency,
                  selected: _selection.frequency == frequency,
                  onTap: () => _setFrequency(frequency),
                ),
              if (showDetails) ...[
                const Divider(height: 1, color: AppColors.background),
                _IntervalRow(
                  frequency: _selection.frequency,
                  interval: _selection.interval,
                  onDecrement: () => _changeInterval(-1),
                  onIncrement: () => _changeInterval(1),
                ),
              ],
              if (showPosition) ...[
                const Divider(height: 1, color: AppColors.background),
                _RepeatPositionSection(
                  frequency: _selection.frequency,
                  selected: _selection.repeatPosition,
                  onChanged: _setRepeatPosition,
                ),
              ],
              if (showDetails) ...[
                const Divider(height: 1, color: AppColors.background),
                _EndConditionSection(
                  endCondition: _selection.endCondition,
                  endCount: _selection.endCount,
                  endDate: _selection.endDate,
                  onChanged: _setEndCondition,
                  onCountChanged: _setEndCount,
                  onPickDate: _pickEndDate,
                ),
              ],
              const Divider(height: 1, color: AppColors.background),
              _SheetActions(
                onCancel: () => Navigator.of(context).pop(),
                onDone: () => Navigator.of(context).pop(
                  _selection.isRecurring ? _selection : RecurringSelection.none,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _FrequencyOption extends StatelessWidget {
  const _FrequencyOption({
    required this.frequency,
    required this.selected,
    required this.onTap,
  });

  final RecurringFrequency frequency;
  final bool selected;
  final VoidCallback onTap;

  static const Map<RecurringFrequency, String> _labels = {
    RecurringFrequency.none: 'None',
    RecurringFrequency.daily: 'Daily',
    RecurringFrequency.weekly: 'Weekly',
    RecurringFrequency.monthly: 'Monthly',
    RecurringFrequency.yearly: 'Yearly',
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey('recurring-option-${frequency.name}'),
      onTap: onTap,
      title: Text(
        _labels[frequency]!,
        style: const TextStyle(color: AppColors.onBackground),
      ),
      trailing: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        key: ValueKey('recurring-option-radio-${frequency.name}'),
        color: selected ? AppColors.primary : Colors.white38,
      ),
    );
  }
}

class _IntervalRow extends StatelessWidget {
  const _IntervalRow({
    required this.frequency,
    required this.interval,
    required this.onDecrement,
    required this.onIncrement,
  });

  final RecurringFrequency frequency;
  final int interval;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  static const Map<RecurringFrequency, String> _units = {
    RecurringFrequency.daily: 'Day',
    RecurringFrequency.weekly: 'Week',
    RecurringFrequency.monthly: 'Month',
    RecurringFrequency.yearly: 'Year',
  };

  @override
  Widget build(BuildContext context) {
    final unit = _units[frequency] ?? 'Day';
    final plural = interval > 1 ? '${unit}s' : unit;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Every $interval $plural',
              key: const ValueKey('recurring-interval-label'),
              style: const TextStyle(color: AppColors.onBackground),
            ),
          ),
          IconButton(
            key: const ValueKey('recurring-interval-decrement'),
            tooltip: 'Decrease interval',
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.onBackground,
            onPressed: interval > 1 ? onDecrement : null,
          ),
          Text(
            '$interval',
            key: const ValueKey('recurring-interval-value'),
            style: const TextStyle(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            key: const ValueKey('recurring-interval-increment'),
            tooltip: 'Increase interval',
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.onBackground,
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _RepeatPositionSection extends StatelessWidget {
  const _RepeatPositionSection({
    required this.frequency,
    required this.selected,
    required this.onChanged,
  });

  final RecurringFrequency frequency;
  final RecurringRepeatPosition selected;
  final ValueChanged<RecurringRepeatPosition> onChanged;

  String _label(RecurringRepeatPosition position) {
    switch (position) {
      case RecurringRepeatPosition.sameDay:
        switch (frequency) {
          case RecurringFrequency.weekly:
            return 'Same day each week';
          case RecurringFrequency.monthly:
            return 'Same day each month';
          case RecurringFrequency.yearly:
            return 'Same day each year';
          default:
            return 'Same day';
        }
      case RecurringRepeatPosition.startOfPeriod:
        switch (frequency) {
          case RecurringFrequency.weekly:
            return 'Start of week';
          case RecurringFrequency.monthly:
            return 'Start of month';
          case RecurringFrequency.yearly:
            return 'Start of year';
          default:
            return 'Start of period';
        }
      case RecurringRepeatPosition.endOfPeriod:
        switch (frequency) {
          case RecurringFrequency.weekly:
            return 'End of week';
          case RecurringFrequency.monthly:
            return 'End of month';
          case RecurringFrequency.yearly:
            return 'End of year';
          default:
            return 'End of period';
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Repeat',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        for (final position in RecurringRepeatPosition.values)
          ListTile(
            key: ValueKey('recurring-repeat-${position.name}'),
            onTap: () => onChanged(position),
            title: Text(
              _label(position),
              style: const TextStyle(color: AppColors.onBackground),
            ),
            trailing: Icon(
              selected == position
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected == position ? AppColors.primary : Colors.white38,
            ),
          ),
      ],
    );
  }
}

class _EndConditionSection extends StatelessWidget {
  const _EndConditionSection({
    required this.endCondition,
    required this.endCount,
    required this.endDate,
    required this.onChanged,
    required this.onCountChanged,
    required this.onPickDate,
  });

  final RecurringEndCondition endCondition;
  final int? endCount;
  final DateTime? endDate;
  final ValueChanged<RecurringEndCondition> onChanged;
  final ValueChanged<int> onCountChanged;
  final VoidCallback onPickDate;

  static const Map<RecurringEndCondition, String> _labels = {
    RecurringEndCondition.forever: 'Forever',
    RecurringEndCondition.count: 'After a number of times',
    RecurringEndCondition.endDate: 'On a date',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Ends',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        for (final condition in RecurringEndCondition.values)
          ListTile(
            key: ValueKey('recurring-end-${condition.name}'),
            onTap: () => onChanged(condition),
            title: Text(
              _labels[condition]!,
              style: const TextStyle(color: AppColors.onBackground),
            ),
            trailing: Icon(
              endCondition == condition
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: endCondition == condition
                  ? AppColors.primary
                  : Colors.white38,
            ),
          ),
        if (endCondition == RecurringEndCondition.count)
          _CountField(count: endCount ?? 1, onChanged: onCountChanged),
        if (endCondition == RecurringEndCondition.endDate)
          ListTile(
            key: const ValueKey('recurring-end-date-value'),
            onTap: onPickDate,
            leading: const Icon(Icons.event, color: AppColors.onBackground),
            title: Text(
              endDate != null
                  ? '${endDate!.day.toString().padLeft(2, '0')}/'
                        '${endDate!.month.toString().padLeft(2, '0')}/'
                        '${endDate!.year}'
                  : 'Select end date',
              style: const TextStyle(color: AppColors.onBackground),
            ),
          ),
      ],
    );
  }
}

class _CountField extends StatefulWidget {
  const _CountField({required this.count, required this.onChanged});

  final int count;
  final ValueChanged<int> onChanged;

  @override
  State<_CountField> createState() => _CountFieldState();
}

class _CountFieldState extends State<_CountField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.count}');
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
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Number of times',
              style: TextStyle(color: AppColors.onBackground),
            ),
          ),
          SizedBox(
            width: 72,
            child: TextField(
              key: const ValueKey('recurring-end-count-field'),
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              style: const TextStyle(color: AppColors.onBackground),
              decoration: const InputDecoration(isDense: true, hintText: '1'),
              onChanged: (raw) {
                final value = int.tryParse(raw.trim());
                if (value != null && value >= 1) {
                  widget.onChanged(value);
                } else if (raw.trim().isEmpty) {
                  widget.onChanged(1);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetActions extends StatelessWidget {
  const _SheetActions({required this.onCancel, required this.onDone});

  final VoidCallback onCancel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              key: const ValueKey('recurring-cancel'),
              onPressed: onCancel,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: AppColors.onBackground),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextButton(
              key: const ValueKey('recurring-done'),
              onPressed: onDone,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'DONE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
