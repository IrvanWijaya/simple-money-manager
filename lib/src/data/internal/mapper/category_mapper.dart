import 'package:drift/drift.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/transaction_type.dart';
import '../database/app_database.dart';

/// Maps between [CategoryRow] storage rows and the [Category] domain entity.
extension CategoryRowMapper on CategoryRow {
  Category toDomain() => Category(
    id: id,
    name: name,
    type: TransactionType.values[type],
    seedOrder: seedOrder,
  );
}

extension CategoryEntityMapper on Category {
  CategoriesCompanion toCompanion() => CategoriesCompanion(
    id: Value(id),
    name: Value(name),
    type: Value(type.index),
    seedOrder: Value(seedOrder),
  );
}
