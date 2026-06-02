// Bootstrap smoke test for the Simple Money Manager app.
//
// Verifies the app boots through Riverpod's ProviderScope with the dark theme
// and lands on the main money-manager shell (not the default counter template).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_money_manager/src/core/di/database_providers.dart';
import 'package:simple_money_manager/src/presentation/app/app.dart';
import 'package:simple_money_manager/src/presentation/shell/main_shell.dart';

import 'data/helpers/test_database.dart';

void main() {
  testWidgets('App boots through Riverpod with dark theme and main shell', (
    WidgetTester tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const SimpleMoneyManagerApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Dark theme applied at the MaterialApp level.
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.brightness, Brightness.dark);

    // Main shell renders as the landing surface.
    expect(find.byType(MainShell), findsOneWidget);
  });
}
