import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/timeframe.dart';

/// Human-readable label for a [Timeframe] used in the selector and elsewhere.
String timeframeLabel(Timeframe timeframe) {
  switch (timeframe) {
    case Timeframe.daily:
      return 'Daily';
    case Timeframe.weekly:
      return 'Weekly';
    case Timeframe.monthly:
      return 'Monthly';
    case Timeframe.yearly:
      return 'Yearly';
  }
}

/// Bottom-sheet selector offering exactly Daily, Weekly, Monthly, and Yearly.
///
/// Opened from the header calendar/timeframe action. Returns the chosen
/// [Timeframe] via [Navigator.pop], or null when dismissed. The currently
/// active timeframe is highlighted with a trailing check.
class TimeframeSelector extends StatelessWidget {
  const TimeframeSelector({required this.selected, super.key});

  final Timeframe selected;

  /// Shows the selector as a modal bottom sheet and resolves to the chosen
  /// [Timeframe], or null if dismissed without a selection.
  static Future<Timeframe?> show(BuildContext context, Timeframe selected) {
    return showModalBottomSheet<Timeframe>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => TimeframeSelector(selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Timeframe',
              style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          for (final timeframe in Timeframe.values)
            ListTile(
              key: ValueKey('timeframe-option-${timeframe.name}'),
              title: Text(
                timeframeLabel(timeframe),
                style: const TextStyle(color: AppColors.onBackground),
              ),
              trailing: timeframe == selected
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(timeframe),
            ),
        ],
      ),
    );
  }
}
