import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// `Show more` row that opens the Statistic Structure detail.
///
/// Tapping invokes [onTap], which navigates to Structure detail while the
/// shared period controller keeps the active period/timeframe context
/// (VAL-STAT-005).
class ShowMoreRow extends StatelessWidget {
  const ShowMoreRow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const ValueKey('stat-show-more'),
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Show more',
                style: TextStyle(color: AppColors.onBackground, fontSize: 14),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.onBackground),
          ],
        ),
      ),
    );
  }
}
