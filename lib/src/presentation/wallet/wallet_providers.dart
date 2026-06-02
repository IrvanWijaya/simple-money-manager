import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/use_case_providers.dart';
import '../../domain/use_cases/get_recurring_rule_views.dart';

/// Reference instant used to compute each recurring rule's next occurrence.
///
/// Exposed as a provider so widget tests can pin it deterministically; in the
/// app it resolves to the real wall clock.
final recurringReferenceProvider = Provider<DateTime>((ref) => DateTime.now());

/// All saved recurring rules with their next occurrence, for the Wallet surface.
///
/// Watches [getRecurringRuleViewsProvider] and the [recurringReferenceProvider]
/// so entries refresh when rules change. Order is the repository's deterministic
/// display order (VAL-RECUI-006, VAL-RECUI-007, VAL-RECUI-012).
final recurringRuleViewsProvider = FutureProvider<List<RecurringRuleView>>((
  ref,
) async {
  final reference = ref.watch(recurringReferenceProvider);
  return ref.watch(getRecurringRuleViewsProvider).call(asOf: reference);
});
