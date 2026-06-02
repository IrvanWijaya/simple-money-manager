import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/database_providers.dart';
import '../../core/theme/app_theme.dart';
import '../shell/main_shell.dart';

/// Root application widget.
///
/// Boots the dark theme and the main money-manager shell with bottom
/// navigation and a centered add action.
///
/// Watches [dataInitializationProvider] at the app root so the built-in
/// category seeds are initialized once at startup and are reliably available to
/// every surface (Add Transaction, Category Selection, statistics, etc.)
/// without each provider duplicating fragile setup. Surface-level reads still
/// await the same provider, which is idempotent, so direct widget tests keep
/// working in isolation.
class SimpleMoneyManagerApp extends ConsumerWidget {
  const SimpleMoneyManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(dataInitializationProvider);
    return MaterialApp(
      title: 'Simple Money Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainShell(),
    );
  }
}
