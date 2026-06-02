import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/tables.dart';

part 'category_dao.g.dart';

/// Data access for the [Categories] table.
@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  /// All categories ordered by type then seed order then id.
  Future<List<CategoryRow>> getAll() {
    return (select(categories)..orderBy([
          (t) => OrderingTerm(expression: t.type),
          (t) => OrderingTerm(expression: t.seedOrder),
          (t) => OrderingTerm(expression: t.id),
        ]))
        .get();
  }

  /// Categories for the given [type] index, ordered by seed order then id.
  Future<List<CategoryRow>> getByType(int type) {
    return (select(categories)
          ..where((t) => t.type.equals(type))
          ..orderBy([
            (t) => OrderingTerm(expression: t.seedOrder),
            (t) => OrderingTerm(expression: t.id),
          ]))
        .get();
  }

  Future<CategoryRow?> getById(String id) {
    return (select(
      categories,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> count() async {
    final countExp = categories.id.count();
    final query = selectOnly(categories)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  /// Inserts seeds, ignoring any whose id already exists. This keeps repeated
  /// initialization idempotent without overwriting user-visible labels.
  Future<void> insertSeedsIfAbsent(Iterable<CategoriesCompanion> seeds) async {
    await batch((batch) {
      batch.insertAll(
        categories,
        seeds.toList(),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }
}
