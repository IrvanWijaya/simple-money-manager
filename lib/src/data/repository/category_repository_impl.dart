import '../../core/seed/category_seeds.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/repositories/category_repository.dart';
import '../internal/dao/category_dao.dart';
import '../internal/mapper/category_mapper.dart';

/// Drift-backed [CategoryRepository].
///
/// Seeds the canonical built-in categories idempotently and exposes only
/// domain [Category] entities.
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dao);

  final CategoryDao _dao;

  @override
  Future<void> ensureSeeded() async {
    final seeds = CategorySeeds.all().map((c) => c.toCompanion());
    await _dao.insertSeedsIfAbsent(seeds);
  }

  @override
  Future<List<Category>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<List<Category>> getByType(TransactionType type) async {
    final rows = await _dao.getByType(type.index);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Category?> getById(String id) async {
    final row = await _dao.getById(id);
    return row?.toDomain();
  }
}
