import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A simple dark-themed placeholder surface for a main shell tab.
///
/// Foundation feature: each main tab renders an identifiable placeholder while
/// the full home surfaces (headers, lists, charts) are implemented in later
/// home-surface features. The visible title lets validation distinguish tabs.
class PlaceholderSurface extends StatelessWidget {
  const PlaceholderSurface({
    required this.title,
    required this.icon,
    super.key,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.onBackground),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.onBackground,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
