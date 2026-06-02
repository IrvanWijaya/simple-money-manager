import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/database_providers.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction_type.dart';

/// Categories for [type], seeded and in canonical order.
///
/// Awaits [dataInitializationProvider] so the built-in category seeds exist
/// before the list is read. The app root also watches
/// [dataInitializationProvider] at startup, so seeding is reliably available to
/// every surface without each one duplicating fragile setup; the await here is
/// idempotent and keeps the provider safe to use in isolation (for example in
/// widget tests that mount the screen directly).
final categoriesByTypeProvider =
    FutureProvider.family<List<Category>, TransactionType>((ref, type) async {
      await ref.watch(dataInitializationProvider.future);
      return ref.watch(categoryRepositoryProvider).getByType(type);
    });
