// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seedOrderMeta = const VerificationMeta(
    'seedOrder',
  );
  @override
  late final GeneratedColumn<int> seedOrder = GeneratedColumn<int>(
    'seed_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, type, seedOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('seed_order')) {
      context.handle(
        _seedOrderMeta,
        seedOrder.isAcceptableOrUnknown(data['seed_order']!, _seedOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      seedOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  final int type;
  final int seedOrder;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.type,
    required this.seedOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<int>(type);
    map['seed_order'] = Variable<int>(seedOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      seedOrder: Value(seedOrder),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<int>(json['type']),
      seedOrder: serializer.fromJson<int>(json['seedOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<int>(type),
      'seedOrder': serializer.toJson<int>(seedOrder),
    };
  }

  CategoryRow copyWith({String? id, String? name, int? type, int? seedOrder}) =>
      CategoryRow(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        seedOrder: seedOrder ?? this.seedOrder,
      );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      seedOrder: data.seedOrder.present ? data.seedOrder.value : this.seedOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('seedOrder: $seedOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, seedOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.seedOrder == this.seedOrder);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> type;
  final Value<int> seedOrder;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.seedOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required int type,
    this.seedOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? type,
    Expression<int>? seedOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (seedOrder != null) 'seed_order': seedOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? type,
    Value<int>? seedOrder,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      seedOrder: seedOrder ?? this.seedOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (seedOrder.present) {
      map['seed_order'] = Variable<int>(seedOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('seedOrder: $seedOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _recurringRuleIdMeta = const VerificationMeta(
    'recurringRuleId',
  );
  @override
  late final GeneratedColumn<String> recurringRuleId = GeneratedColumn<String>(
    'recurring_rule_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurrenceKeyMeta = const VerificationMeta(
    'occurrenceKey',
  );
  @override
  late final GeneratedColumn<String> occurrenceKey = GeneratedColumn<String>(
    'occurrence_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    amount,
    date,
    categoryId,
    description,
    memo,
    recurringRuleId,
    occurrenceKey,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('recurring_rule_id')) {
      context.handle(
        _recurringRuleIdMeta,
        recurringRuleId.isAcceptableOrUnknown(
          data['recurring_rule_id']!,
          _recurringRuleIdMeta,
        ),
      );
    }
    if (data.containsKey('occurrence_key')) {
      context.handle(
        _occurrenceKeyMeta,
        occurrenceKey.isAcceptableOrUnknown(
          data['occurrence_key']!,
          _occurrenceKeyMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      )!,
      recurringRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_rule_id'],
      ),
      occurrenceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_key'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final String id;
  final int type;
  final int amount;
  final DateTime date;
  final String categoryId;
  final String description;
  final String memo;
  final String? recurringRuleId;
  final String? occurrenceKey;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const TransactionRow({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.description,
    required this.memo,
    this.recurringRuleId,
    this.occurrenceKey,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<int>(type);
    map['amount'] = Variable<int>(amount);
    map['date'] = Variable<DateTime>(date);
    map['category_id'] = Variable<String>(categoryId);
    map['description'] = Variable<String>(description);
    map['memo'] = Variable<String>(memo);
    if (!nullToAbsent || recurringRuleId != null) {
      map['recurring_rule_id'] = Variable<String>(recurringRuleId);
    }
    if (!nullToAbsent || occurrenceKey != null) {
      map['occurrence_key'] = Variable<String>(occurrenceKey);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      date: Value(date),
      categoryId: Value(categoryId),
      description: Value(description),
      memo: Value(memo),
      recurringRuleId: recurringRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringRuleId),
      occurrenceKey: occurrenceKey == null && nullToAbsent
          ? const Value.absent()
          : Value(occurrenceKey),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<int>(json['type']),
      amount: serializer.fromJson<int>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      description: serializer.fromJson<String>(json['description']),
      memo: serializer.fromJson<String>(json['memo']),
      recurringRuleId: serializer.fromJson<String?>(json['recurringRuleId']),
      occurrenceKey: serializer.fromJson<String?>(json['occurrenceKey']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<int>(type),
      'amount': serializer.toJson<int>(amount),
      'date': serializer.toJson<DateTime>(date),
      'categoryId': serializer.toJson<String>(categoryId),
      'description': serializer.toJson<String>(description),
      'memo': serializer.toJson<String>(memo),
      'recurringRuleId': serializer.toJson<String?>(recurringRuleId),
      'occurrenceKey': serializer.toJson<String?>(occurrenceKey),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  TransactionRow copyWith({
    String? id,
    int? type,
    int? amount,
    DateTime? date,
    String? categoryId,
    String? description,
    String? memo,
    Value<String?> recurringRuleId = const Value.absent(),
    Value<String?> occurrenceKey = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => TransactionRow(
    id: id ?? this.id,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    categoryId: categoryId ?? this.categoryId,
    description: description ?? this.description,
    memo: memo ?? this.memo,
    recurringRuleId: recurringRuleId.present
        ? recurringRuleId.value
        : this.recurringRuleId,
    occurrenceKey: occurrenceKey.present
        ? occurrenceKey.value
        : this.occurrenceKey,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      description: data.description.present
          ? data.description.value
          : this.description,
      memo: data.memo.present ? data.memo.value : this.memo,
      recurringRuleId: data.recurringRuleId.present
          ? data.recurringRuleId.value
          : this.recurringRuleId,
      occurrenceKey: data.occurrenceKey.present
          ? data.occurrenceKey.value
          : this.occurrenceKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('categoryId: $categoryId, ')
          ..write('description: $description, ')
          ..write('memo: $memo, ')
          ..write('recurringRuleId: $recurringRuleId, ')
          ..write('occurrenceKey: $occurrenceKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    amount,
    date,
    categoryId,
    description,
    memo,
    recurringRuleId,
    occurrenceKey,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.categoryId == this.categoryId &&
          other.description == this.description &&
          other.memo == this.memo &&
          other.recurringRuleId == this.recurringRuleId &&
          other.occurrenceKey == this.occurrenceKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<String> id;
  final Value<int> type;
  final Value<int> amount;
  final Value<DateTime> date;
  final Value<String> categoryId;
  final Value<String> description;
  final Value<String> memo;
  final Value<String?> recurringRuleId;
  final Value<String?> occurrenceKey;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.description = const Value.absent(),
    this.memo = const Value.absent(),
    this.recurringRuleId = const Value.absent(),
    this.occurrenceKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required int type,
    required int amount,
    required DateTime date,
    required String categoryId,
    this.description = const Value.absent(),
    this.memo = const Value.absent(),
    this.recurringRuleId = const Value.absent(),
    this.occurrenceKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       amount = Value(amount),
       date = Value(date),
       categoryId = Value(categoryId);
  static Insertable<TransactionRow> custom({
    Expression<String>? id,
    Expression<int>? type,
    Expression<int>? amount,
    Expression<DateTime>? date,
    Expression<String>? categoryId,
    Expression<String>? description,
    Expression<String>? memo,
    Expression<String>? recurringRuleId,
    Expression<String>? occurrenceKey,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (categoryId != null) 'category_id': categoryId,
      if (description != null) 'description': description,
      if (memo != null) 'memo': memo,
      if (recurringRuleId != null) 'recurring_rule_id': recurringRuleId,
      if (occurrenceKey != null) 'occurrence_key': occurrenceKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<int>? type,
    Value<int>? amount,
    Value<DateTime>? date,
    Value<String>? categoryId,
    Value<String>? description,
    Value<String>? memo,
    Value<String?>? recurringRuleId,
    Value<String?>? occurrenceKey,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      memo: memo ?? this.memo,
      recurringRuleId: recurringRuleId ?? this.recurringRuleId,
      occurrenceKey: occurrenceKey ?? this.occurrenceKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (recurringRuleId.present) {
      map['recurring_rule_id'] = Variable<String>(recurringRuleId.value);
    }
    if (occurrenceKey.present) {
      map['occurrence_key'] = Variable<String>(occurrenceKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('categoryId: $categoryId, ')
          ..write('description: $description, ')
          ..write('memo: $memo, ')
          ..write('recurringRuleId: $recurringRuleId, ')
          ..write('occurrenceKey: $occurrenceKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringRulesTable extends RecurringRules
    with TableInfo<$RecurringRulesTable, RecurringRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalMeta = const VerificationMeta(
    'interval',
  );
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
    'interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _repeatPositionMeta = const VerificationMeta(
    'repeatPosition',
  );
  @override
  late final GeneratedColumn<int> repeatPosition = GeneratedColumn<int>(
    'repeat_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endConditionMeta = const VerificationMeta(
    'endCondition',
  );
  @override
  late final GeneratedColumn<int> endCondition = GeneratedColumn<int>(
    'end_condition',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endCountMeta = const VerificationMeta(
    'endCount',
  );
  @override
  late final GeneratedColumn<int> endCount = GeneratedColumn<int>(
    'end_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    amount,
    categoryId,
    description,
    memo,
    frequency,
    interval,
    repeatPosition,
    endCondition,
    endCount,
    endDate,
    startDate,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('interval')) {
      context.handle(
        _intervalMeta,
        interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta),
      );
    }
    if (data.containsKey('repeat_position')) {
      context.handle(
        _repeatPositionMeta,
        repeatPosition.isAcceptableOrUnknown(
          data['repeat_position']!,
          _repeatPositionMeta,
        ),
      );
    }
    if (data.containsKey('end_condition')) {
      context.handle(
        _endConditionMeta,
        endCondition.isAcceptableOrUnknown(
          data['end_condition']!,
          _endConditionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endConditionMeta);
    }
    if (data.containsKey('end_count')) {
      context.handle(
        _endCountMeta,
        endCount.isAcceptableOrUnknown(data['end_count']!, _endCountMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frequency'],
      )!,
      interval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval'],
      )!,
      repeatPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_position'],
      ),
      endCondition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_condition'],
      )!,
      endCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_count'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $RecurringRulesTable createAlias(String alias) {
    return $RecurringRulesTable(attachedDatabase, alias);
  }
}

class RecurringRuleRow extends DataClass
    implements Insertable<RecurringRuleRow> {
  final String id;
  final int type;
  final int amount;
  final String categoryId;
  final String description;
  final String memo;
  final int frequency;
  final int interval;
  final int? repeatPosition;
  final int endCondition;
  final int? endCount;
  final DateTime? endDate;
  final DateTime startDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const RecurringRuleRow({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.description,
    required this.memo,
    required this.frequency,
    required this.interval,
    this.repeatPosition,
    required this.endCondition,
    this.endCount,
    this.endDate,
    required this.startDate,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<int>(type);
    map['amount'] = Variable<int>(amount);
    map['category_id'] = Variable<String>(categoryId);
    map['description'] = Variable<String>(description);
    map['memo'] = Variable<String>(memo);
    map['frequency'] = Variable<int>(frequency);
    map['interval'] = Variable<int>(interval);
    if (!nullToAbsent || repeatPosition != null) {
      map['repeat_position'] = Variable<int>(repeatPosition);
    }
    map['end_condition'] = Variable<int>(endCondition);
    if (!nullToAbsent || endCount != null) {
      map['end_count'] = Variable<int>(endCount);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  RecurringRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurringRulesCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      categoryId: Value(categoryId),
      description: Value(description),
      memo: Value(memo),
      frequency: Value(frequency),
      interval: Value(interval),
      repeatPosition: repeatPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(repeatPosition),
      endCondition: Value(endCondition),
      endCount: endCount == null && nullToAbsent
          ? const Value.absent()
          : Value(endCount),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      startDate: Value(startDate),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory RecurringRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringRuleRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<int>(json['type']),
      amount: serializer.fromJson<int>(json['amount']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      description: serializer.fromJson<String>(json['description']),
      memo: serializer.fromJson<String>(json['memo']),
      frequency: serializer.fromJson<int>(json['frequency']),
      interval: serializer.fromJson<int>(json['interval']),
      repeatPosition: serializer.fromJson<int?>(json['repeatPosition']),
      endCondition: serializer.fromJson<int>(json['endCondition']),
      endCount: serializer.fromJson<int?>(json['endCount']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<int>(type),
      'amount': serializer.toJson<int>(amount),
      'categoryId': serializer.toJson<String>(categoryId),
      'description': serializer.toJson<String>(description),
      'memo': serializer.toJson<String>(memo),
      'frequency': serializer.toJson<int>(frequency),
      'interval': serializer.toJson<int>(interval),
      'repeatPosition': serializer.toJson<int?>(repeatPosition),
      'endCondition': serializer.toJson<int>(endCondition),
      'endCount': serializer.toJson<int?>(endCount),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'startDate': serializer.toJson<DateTime>(startDate),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  RecurringRuleRow copyWith({
    String? id,
    int? type,
    int? amount,
    String? categoryId,
    String? description,
    String? memo,
    int? frequency,
    int? interval,
    Value<int?> repeatPosition = const Value.absent(),
    int? endCondition,
    Value<int?> endCount = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    DateTime? startDate,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => RecurringRuleRow(
    id: id ?? this.id,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    categoryId: categoryId ?? this.categoryId,
    description: description ?? this.description,
    memo: memo ?? this.memo,
    frequency: frequency ?? this.frequency,
    interval: interval ?? this.interval,
    repeatPosition: repeatPosition.present
        ? repeatPosition.value
        : this.repeatPosition,
    endCondition: endCondition ?? this.endCondition,
    endCount: endCount.present ? endCount.value : this.endCount,
    endDate: endDate.present ? endDate.value : this.endDate,
    startDate: startDate ?? this.startDate,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  RecurringRuleRow copyWithCompanion(RecurringRulesCompanion data) {
    return RecurringRuleRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      description: data.description.present
          ? data.description.value
          : this.description,
      memo: data.memo.present ? data.memo.value : this.memo,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      interval: data.interval.present ? data.interval.value : this.interval,
      repeatPosition: data.repeatPosition.present
          ? data.repeatPosition.value
          : this.repeatPosition,
      endCondition: data.endCondition.present
          ? data.endCondition.value
          : this.endCondition,
      endCount: data.endCount.present ? data.endCount.value : this.endCount,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRuleRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('description: $description, ')
          ..write('memo: $memo, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('repeatPosition: $repeatPosition, ')
          ..write('endCondition: $endCondition, ')
          ..write('endCount: $endCount, ')
          ..write('endDate: $endDate, ')
          ..write('startDate: $startDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    amount,
    categoryId,
    description,
    memo,
    frequency,
    interval,
    repeatPosition,
    endCondition,
    endCount,
    endDate,
    startDate,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringRuleRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.description == this.description &&
          other.memo == this.memo &&
          other.frequency == this.frequency &&
          other.interval == this.interval &&
          other.repeatPosition == this.repeatPosition &&
          other.endCondition == this.endCondition &&
          other.endCount == this.endCount &&
          other.endDate == this.endDate &&
          other.startDate == this.startDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RecurringRulesCompanion extends UpdateCompanion<RecurringRuleRow> {
  final Value<String> id;
  final Value<int> type;
  final Value<int> amount;
  final Value<String> categoryId;
  final Value<String> description;
  final Value<String> memo;
  final Value<int> frequency;
  final Value<int> interval;
  final Value<int?> repeatPosition;
  final Value<int> endCondition;
  final Value<int?> endCount;
  final Value<DateTime?> endDate;
  final Value<DateTime> startDate;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const RecurringRulesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.description = const Value.absent(),
    this.memo = const Value.absent(),
    this.frequency = const Value.absent(),
    this.interval = const Value.absent(),
    this.repeatPosition = const Value.absent(),
    this.endCondition = const Value.absent(),
    this.endCount = const Value.absent(),
    this.endDate = const Value.absent(),
    this.startDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringRulesCompanion.insert({
    required String id,
    required int type,
    required int amount,
    required String categoryId,
    this.description = const Value.absent(),
    this.memo = const Value.absent(),
    required int frequency,
    this.interval = const Value.absent(),
    this.repeatPosition = const Value.absent(),
    required int endCondition,
    this.endCount = const Value.absent(),
    this.endDate = const Value.absent(),
    required DateTime startDate,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       amount = Value(amount),
       categoryId = Value(categoryId),
       frequency = Value(frequency),
       endCondition = Value(endCondition),
       startDate = Value(startDate);
  static Insertable<RecurringRuleRow> custom({
    Expression<String>? id,
    Expression<int>? type,
    Expression<int>? amount,
    Expression<String>? categoryId,
    Expression<String>? description,
    Expression<String>? memo,
    Expression<int>? frequency,
    Expression<int>? interval,
    Expression<int>? repeatPosition,
    Expression<int>? endCondition,
    Expression<int>? endCount,
    Expression<DateTime>? endDate,
    Expression<DateTime>? startDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (description != null) 'description': description,
      if (memo != null) 'memo': memo,
      if (frequency != null) 'frequency': frequency,
      if (interval != null) 'interval': interval,
      if (repeatPosition != null) 'repeat_position': repeatPosition,
      if (endCondition != null) 'end_condition': endCondition,
      if (endCount != null) 'end_count': endCount,
      if (endDate != null) 'end_date': endDate,
      if (startDate != null) 'start_date': startDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringRulesCompanion copyWith({
    Value<String>? id,
    Value<int>? type,
    Value<int>? amount,
    Value<String>? categoryId,
    Value<String>? description,
    Value<String>? memo,
    Value<int>? frequency,
    Value<int>? interval,
    Value<int?>? repeatPosition,
    Value<int>? endCondition,
    Value<int?>? endCount,
    Value<DateTime?>? endDate,
    Value<DateTime>? startDate,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return RecurringRulesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      memo: memo ?? this.memo,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      repeatPosition: repeatPosition ?? this.repeatPosition,
      endCondition: endCondition ?? this.endCondition,
      endCount: endCount ?? this.endCount,
      endDate: endDate ?? this.endDate,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(frequency.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (repeatPosition.present) {
      map['repeat_position'] = Variable<int>(repeatPosition.value);
    }
    if (endCondition.present) {
      map['end_condition'] = Variable<int>(endCondition.value);
    }
    if (endCount.present) {
      map['end_count'] = Variable<int>(endCount.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRulesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('description: $description, ')
          ..write('memo: $memo, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('repeatPosition: $repeatPosition, ')
          ..write('endCondition: $endCondition, ')
          ..write('endCount: $endCount, ')
          ..write('endDate: $endDate, ')
          ..write('startDate: $startDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringOccurrencesTable extends RecurringOccurrences
    with TableInfo<$RecurringOccurrencesTable, RecurringOccurrenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurrenceKeyMeta = const VerificationMeta(
    'occurrenceKey',
  );
  @override
  late final GeneratedColumn<String> occurrenceKey = GeneratedColumn<String>(
    'occurrence_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurrenceDateMeta = const VerificationMeta(
    'occurrenceDate',
  );
  @override
  late final GeneratedColumn<DateTime> occurrenceDate =
      GeneratedColumn<DateTime>(
        'occurrence_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ruleId,
    occurrenceKey,
    transactionId,
    occurrenceDate,
    generatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringOccurrenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('occurrence_key')) {
      context.handle(
        _occurrenceKeyMeta,
        occurrenceKey.isAcceptableOrUnknown(
          data['occurrence_key']!,
          _occurrenceKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurrenceKeyMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('occurrence_date')) {
      context.handle(
        _occurrenceDateMeta,
        occurrenceDate.isAcceptableOrUnknown(
          data['occurrence_date']!,
          _occurrenceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurrenceDateMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ruleId, occurrenceKey};
  @override
  RecurringOccurrenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringOccurrenceRow(
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_id'],
      )!,
      occurrenceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_key'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      occurrenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurrence_date'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      ),
    );
  }

  @override
  $RecurringOccurrencesTable createAlias(String alias) {
    return $RecurringOccurrencesTable(attachedDatabase, alias);
  }
}

class RecurringOccurrenceRow extends DataClass
    implements Insertable<RecurringOccurrenceRow> {
  final String ruleId;
  final String occurrenceKey;
  final String transactionId;
  final DateTime occurrenceDate;
  final DateTime? generatedAt;
  const RecurringOccurrenceRow({
    required this.ruleId,
    required this.occurrenceKey,
    required this.transactionId,
    required this.occurrenceDate,
    this.generatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['rule_id'] = Variable<String>(ruleId);
    map['occurrence_key'] = Variable<String>(occurrenceKey);
    map['transaction_id'] = Variable<String>(transactionId);
    map['occurrence_date'] = Variable<DateTime>(occurrenceDate);
    if (!nullToAbsent || generatedAt != null) {
      map['generated_at'] = Variable<DateTime>(generatedAt);
    }
    return map;
  }

  RecurringOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return RecurringOccurrencesCompanion(
      ruleId: Value(ruleId),
      occurrenceKey: Value(occurrenceKey),
      transactionId: Value(transactionId),
      occurrenceDate: Value(occurrenceDate),
      generatedAt: generatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(generatedAt),
    );
  }

  factory RecurringOccurrenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringOccurrenceRow(
      ruleId: serializer.fromJson<String>(json['ruleId']),
      occurrenceKey: serializer.fromJson<String>(json['occurrenceKey']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      occurrenceDate: serializer.fromJson<DateTime>(json['occurrenceDate']),
      generatedAt: serializer.fromJson<DateTime?>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ruleId': serializer.toJson<String>(ruleId),
      'occurrenceKey': serializer.toJson<String>(occurrenceKey),
      'transactionId': serializer.toJson<String>(transactionId),
      'occurrenceDate': serializer.toJson<DateTime>(occurrenceDate),
      'generatedAt': serializer.toJson<DateTime?>(generatedAt),
    };
  }

  RecurringOccurrenceRow copyWith({
    String? ruleId,
    String? occurrenceKey,
    String? transactionId,
    DateTime? occurrenceDate,
    Value<DateTime?> generatedAt = const Value.absent(),
  }) => RecurringOccurrenceRow(
    ruleId: ruleId ?? this.ruleId,
    occurrenceKey: occurrenceKey ?? this.occurrenceKey,
    transactionId: transactionId ?? this.transactionId,
    occurrenceDate: occurrenceDate ?? this.occurrenceDate,
    generatedAt: generatedAt.present ? generatedAt.value : this.generatedAt,
  );
  RecurringOccurrenceRow copyWithCompanion(RecurringOccurrencesCompanion data) {
    return RecurringOccurrenceRow(
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      occurrenceKey: data.occurrenceKey.present
          ? data.occurrenceKey.value
          : this.occurrenceKey,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      occurrenceDate: data.occurrenceDate.present
          ? data.occurrenceDate.value
          : this.occurrenceDate,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringOccurrenceRow(')
          ..write('ruleId: $ruleId, ')
          ..write('occurrenceKey: $occurrenceKey, ')
          ..write('transactionId: $transactionId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ruleId,
    occurrenceKey,
    transactionId,
    occurrenceDate,
    generatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringOccurrenceRow &&
          other.ruleId == this.ruleId &&
          other.occurrenceKey == this.occurrenceKey &&
          other.transactionId == this.transactionId &&
          other.occurrenceDate == this.occurrenceDate &&
          other.generatedAt == this.generatedAt);
}

class RecurringOccurrencesCompanion
    extends UpdateCompanion<RecurringOccurrenceRow> {
  final Value<String> ruleId;
  final Value<String> occurrenceKey;
  final Value<String> transactionId;
  final Value<DateTime> occurrenceDate;
  final Value<DateTime?> generatedAt;
  final Value<int> rowid;
  const RecurringOccurrencesCompanion({
    this.ruleId = const Value.absent(),
    this.occurrenceKey = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringOccurrencesCompanion.insert({
    required String ruleId,
    required String occurrenceKey,
    required String transactionId,
    required DateTime occurrenceDate,
    this.generatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ruleId = Value(ruleId),
       occurrenceKey = Value(occurrenceKey),
       transactionId = Value(transactionId),
       occurrenceDate = Value(occurrenceDate);
  static Insertable<RecurringOccurrenceRow> custom({
    Expression<String>? ruleId,
    Expression<String>? occurrenceKey,
    Expression<String>? transactionId,
    Expression<DateTime>? occurrenceDate,
    Expression<DateTime>? generatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ruleId != null) 'rule_id': ruleId,
      if (occurrenceKey != null) 'occurrence_key': occurrenceKey,
      if (transactionId != null) 'transaction_id': transactionId,
      if (occurrenceDate != null) 'occurrence_date': occurrenceDate,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringOccurrencesCompanion copyWith({
    Value<String>? ruleId,
    Value<String>? occurrenceKey,
    Value<String>? transactionId,
    Value<DateTime>? occurrenceDate,
    Value<DateTime?>? generatedAt,
    Value<int>? rowid,
  }) {
    return RecurringOccurrencesCompanion(
      ruleId: ruleId ?? this.ruleId,
      occurrenceKey: occurrenceKey ?? this.occurrenceKey,
      transactionId: transactionId ?? this.transactionId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      generatedAt: generatedAt ?? this.generatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (occurrenceKey.present) {
      map['occurrence_key'] = Variable<String>(occurrenceKey.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (occurrenceDate.present) {
      map['occurrence_date'] = Variable<DateTime>(occurrenceDate.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringOccurrencesCompanion(')
          ..write('ruleId: $ruleId, ')
          ..write('occurrenceKey: $occurrenceKey, ')
          ..write('transactionId: $transactionId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletSettingsTable extends WalletSettings
    with TableInfo<$WalletSettingsTable, WalletSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Cash'),
  );
  static const VerificationMeta _baseBalanceMeta = const VerificationMeta(
    'baseBalance',
  );
  @override
  late final GeneratedColumn<int> baseBalance = GeneratedColumn<int>(
    'base_balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, baseBalance];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('base_balance')) {
      context.handle(
        _baseBalanceMeta,
        baseBalance.isAcceptableOrUnknown(
          data['base_balance']!,
          _baseBalanceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalletSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletSettingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      baseBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_balance'],
      )!,
    );
  }

  @override
  $WalletSettingsTable createAlias(String alias) {
    return $WalletSettingsTable(attachedDatabase, alias);
  }
}

class WalletSettingRow extends DataClass
    implements Insertable<WalletSettingRow> {
  final int id;
  final String name;
  final int baseBalance;
  const WalletSettingRow({
    required this.id,
    required this.name,
    required this.baseBalance,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['base_balance'] = Variable<int>(baseBalance);
    return map;
  }

  WalletSettingsCompanion toCompanion(bool nullToAbsent) {
    return WalletSettingsCompanion(
      id: Value(id),
      name: Value(name),
      baseBalance: Value(baseBalance),
    );
  }

  factory WalletSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletSettingRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      baseBalance: serializer.fromJson<int>(json['baseBalance']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'baseBalance': serializer.toJson<int>(baseBalance),
    };
  }

  WalletSettingRow copyWith({int? id, String? name, int? baseBalance}) =>
      WalletSettingRow(
        id: id ?? this.id,
        name: name ?? this.name,
        baseBalance: baseBalance ?? this.baseBalance,
      );
  WalletSettingRow copyWithCompanion(WalletSettingsCompanion data) {
    return WalletSettingRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      baseBalance: data.baseBalance.present
          ? data.baseBalance.value
          : this.baseBalance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletSettingRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('baseBalance: $baseBalance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, baseBalance);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletSettingRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.baseBalance == this.baseBalance);
}

class WalletSettingsCompanion extends UpdateCompanion<WalletSettingRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> baseBalance;
  const WalletSettingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.baseBalance = const Value.absent(),
  });
  WalletSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.baseBalance = const Value.absent(),
  });
  static Insertable<WalletSettingRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? baseBalance,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (baseBalance != null) 'base_balance': baseBalance,
    });
  }

  WalletSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? baseBalance,
  }) {
    return WalletSettingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      baseBalance: baseBalance ?? this.baseBalance,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (baseBalance.present) {
      map['base_balance'] = Variable<int>(baseBalance.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletSettingsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('baseBalance: $baseBalance')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $RecurringRulesTable recurringRules = $RecurringRulesTable(this);
  late final $RecurringOccurrencesTable recurringOccurrences =
      $RecurringOccurrencesTable(this);
  late final $WalletSettingsTable walletSettings = $WalletSettingsTable(this);
  late final CategoryDao categoryDao = CategoryDao(this as AppDatabase);
  late final TransactionDao transactionDao = TransactionDao(
    this as AppDatabase,
  );
  late final RecurringDao recurringDao = RecurringDao(this as AppDatabase);
  late final WalletDao walletDao = WalletDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    transactions,
    recurringRules,
    recurringOccurrences,
    walletSettings,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required int type,
      Value<int> seedOrder,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> type,
      Value<int> seedOrder,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seedOrder => $composableBuilder(
    column: $table.seedOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seedOrder => $composableBuilder(
    column: $table.seedOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get seedOrder =>
      $composableBuilder(column: $table.seedOrder, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<int> seedOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                type: type,
                seedOrder: seedOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int type,
                Value<int> seedOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                type: type,
                seedOrder: seedOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required int type,
      required int amount,
      required DateTime date,
      required String categoryId,
      Value<String> description,
      Value<String> memo,
      Value<String?> recurringRuleId,
      Value<String?> occurrenceKey,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<int> type,
      Value<int> amount,
      Value<DateTime> date,
      Value<String> categoryId,
      Value<String> description,
      Value<String> memo,
      Value<String?> recurringRuleId,
      Value<String?> occurrenceKey,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurringRuleId => $composableBuilder(
    column: $table.recurringRuleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurrenceKey => $composableBuilder(
    column: $table.occurrenceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurringRuleId => $composableBuilder(
    column: $table.recurringRuleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurrenceKey => $composableBuilder(
    column: $table.occurrenceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get recurringRuleId => $composableBuilder(
    column: $table.recurringRuleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get occurrenceKey => $composableBuilder(
    column: $table.occurrenceKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionRow,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            TransactionRow,
            BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>,
          ),
          TransactionRow,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> memo = const Value.absent(),
                Value<String?> recurringRuleId = const Value.absent(),
                Value<String?> occurrenceKey = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                type: type,
                amount: amount,
                date: date,
                categoryId: categoryId,
                description: description,
                memo: memo,
                recurringRuleId: recurringRuleId,
                occurrenceKey: occurrenceKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int type,
                required int amount,
                required DateTime date,
                required String categoryId,
                Value<String> description = const Value.absent(),
                Value<String> memo = const Value.absent(),
                Value<String?> recurringRuleId = const Value.absent(),
                Value<String?> occurrenceKey = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                type: type,
                amount: amount,
                date: date,
                categoryId: categoryId,
                description: description,
                memo: memo,
                recurringRuleId: recurringRuleId,
                occurrenceKey: occurrenceKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionRow,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        TransactionRow,
        BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>,
      ),
      TransactionRow,
      PrefetchHooks Function()
    >;
typedef $$RecurringRulesTableCreateCompanionBuilder =
    RecurringRulesCompanion Function({
      required String id,
      required int type,
      required int amount,
      required String categoryId,
      Value<String> description,
      Value<String> memo,
      required int frequency,
      Value<int> interval,
      Value<int?> repeatPosition,
      required int endCondition,
      Value<int?> endCount,
      Value<DateTime?> endDate,
      required DateTime startDate,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$RecurringRulesTableUpdateCompanionBuilder =
    RecurringRulesCompanion Function({
      Value<String> id,
      Value<int> type,
      Value<int> amount,
      Value<String> categoryId,
      Value<String> description,
      Value<String> memo,
      Value<int> frequency,
      Value<int> interval,
      Value<int?> repeatPosition,
      Value<int> endCondition,
      Value<int?> endCount,
      Value<DateTime?> endDate,
      Value<DateTime> startDate,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$RecurringRulesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatPosition => $composableBuilder(
    column: $table.repeatPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endCondition => $composableBuilder(
    column: $table.endCondition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endCount => $composableBuilder(
    column: $table.endCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatPosition => $composableBuilder(
    column: $table.repeatPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endCondition => $composableBuilder(
    column: $table.endCondition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endCount => $composableBuilder(
    column: $table.endCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringRulesTable> {
  $$RecurringRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<int> get repeatPosition => $composableBuilder(
    column: $table.repeatPosition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endCondition => $composableBuilder(
    column: $table.endCondition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endCount =>
      $composableBuilder(column: $table.endCount, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RecurringRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringRulesTable,
          RecurringRuleRow,
          $$RecurringRulesTableFilterComposer,
          $$RecurringRulesTableOrderingComposer,
          $$RecurringRulesTableAnnotationComposer,
          $$RecurringRulesTableCreateCompanionBuilder,
          $$RecurringRulesTableUpdateCompanionBuilder,
          (
            RecurringRuleRow,
            BaseReferences<
              _$AppDatabase,
              $RecurringRulesTable,
              RecurringRuleRow
            >,
          ),
          RecurringRuleRow,
          PrefetchHooks Function()
        > {
  $$RecurringRulesTableTableManager(
    _$AppDatabase db,
    $RecurringRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> memo = const Value.absent(),
                Value<int> frequency = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<int?> repeatPosition = const Value.absent(),
                Value<int> endCondition = const Value.absent(),
                Value<int?> endCount = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRulesCompanion(
                id: id,
                type: type,
                amount: amount,
                categoryId: categoryId,
                description: description,
                memo: memo,
                frequency: frequency,
                interval: interval,
                repeatPosition: repeatPosition,
                endCondition: endCondition,
                endCount: endCount,
                endDate: endDate,
                startDate: startDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int type,
                required int amount,
                required String categoryId,
                Value<String> description = const Value.absent(),
                Value<String> memo = const Value.absent(),
                required int frequency,
                Value<int> interval = const Value.absent(),
                Value<int?> repeatPosition = const Value.absent(),
                required int endCondition,
                Value<int?> endCount = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                required DateTime startDate,
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRulesCompanion.insert(
                id: id,
                type: type,
                amount: amount,
                categoryId: categoryId,
                description: description,
                memo: memo,
                frequency: frequency,
                interval: interval,
                repeatPosition: repeatPosition,
                endCondition: endCondition,
                endCount: endCount,
                endDate: endDate,
                startDate: startDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringRulesTable,
      RecurringRuleRow,
      $$RecurringRulesTableFilterComposer,
      $$RecurringRulesTableOrderingComposer,
      $$RecurringRulesTableAnnotationComposer,
      $$RecurringRulesTableCreateCompanionBuilder,
      $$RecurringRulesTableUpdateCompanionBuilder,
      (
        RecurringRuleRow,
        BaseReferences<_$AppDatabase, $RecurringRulesTable, RecurringRuleRow>,
      ),
      RecurringRuleRow,
      PrefetchHooks Function()
    >;
typedef $$RecurringOccurrencesTableCreateCompanionBuilder =
    RecurringOccurrencesCompanion Function({
      required String ruleId,
      required String occurrenceKey,
      required String transactionId,
      required DateTime occurrenceDate,
      Value<DateTime?> generatedAt,
      Value<int> rowid,
    });
typedef $$RecurringOccurrencesTableUpdateCompanionBuilder =
    RecurringOccurrencesCompanion Function({
      Value<String> ruleId,
      Value<String> occurrenceKey,
      Value<String> transactionId,
      Value<DateTime> occurrenceDate,
      Value<DateTime?> generatedAt,
      Value<int> rowid,
    });

class $$RecurringOccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringOccurrencesTable> {
  $$RecurringOccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurrenceKey => $composableBuilder(
    column: $table.occurrenceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringOccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringOccurrencesTable> {
  $$RecurringOccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurrenceKey => $composableBuilder(
    column: $table.occurrenceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringOccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringOccurrencesTable> {
  $$RecurringOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<String> get occurrenceKey => $composableBuilder(
    column: $table.occurrenceKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );
}

class $$RecurringOccurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringOccurrencesTable,
          RecurringOccurrenceRow,
          $$RecurringOccurrencesTableFilterComposer,
          $$RecurringOccurrencesTableOrderingComposer,
          $$RecurringOccurrencesTableAnnotationComposer,
          $$RecurringOccurrencesTableCreateCompanionBuilder,
          $$RecurringOccurrencesTableUpdateCompanionBuilder,
          (
            RecurringOccurrenceRow,
            BaseReferences<
              _$AppDatabase,
              $RecurringOccurrencesTable,
              RecurringOccurrenceRow
            >,
          ),
          RecurringOccurrenceRow,
          PrefetchHooks Function()
        > {
  $$RecurringOccurrencesTableTableManager(
    _$AppDatabase db,
    $RecurringOccurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringOccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringOccurrencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurringOccurrencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> ruleId = const Value.absent(),
                Value<String> occurrenceKey = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<DateTime> occurrenceDate = const Value.absent(),
                Value<DateTime?> generatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringOccurrencesCompanion(
                ruleId: ruleId,
                occurrenceKey: occurrenceKey,
                transactionId: transactionId,
                occurrenceDate: occurrenceDate,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ruleId,
                required String occurrenceKey,
                required String transactionId,
                required DateTime occurrenceDate,
                Value<DateTime?> generatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringOccurrencesCompanion.insert(
                ruleId: ruleId,
                occurrenceKey: occurrenceKey,
                transactionId: transactionId,
                occurrenceDate: occurrenceDate,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringOccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringOccurrencesTable,
      RecurringOccurrenceRow,
      $$RecurringOccurrencesTableFilterComposer,
      $$RecurringOccurrencesTableOrderingComposer,
      $$RecurringOccurrencesTableAnnotationComposer,
      $$RecurringOccurrencesTableCreateCompanionBuilder,
      $$RecurringOccurrencesTableUpdateCompanionBuilder,
      (
        RecurringOccurrenceRow,
        BaseReferences<
          _$AppDatabase,
          $RecurringOccurrencesTable,
          RecurringOccurrenceRow
        >,
      ),
      RecurringOccurrenceRow,
      PrefetchHooks Function()
    >;
typedef $$WalletSettingsTableCreateCompanionBuilder =
    WalletSettingsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> baseBalance,
    });
typedef $$WalletSettingsTableUpdateCompanionBuilder =
    WalletSettingsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> baseBalance,
    });

class $$WalletSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $WalletSettingsTable> {
  $$WalletSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseBalance => $composableBuilder(
    column: $table.baseBalance,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalletSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletSettingsTable> {
  $$WalletSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseBalance => $composableBuilder(
    column: $table.baseBalance,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletSettingsTable> {
  $$WalletSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get baseBalance => $composableBuilder(
    column: $table.baseBalance,
    builder: (column) => column,
  );
}

class $$WalletSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletSettingsTable,
          WalletSettingRow,
          $$WalletSettingsTableFilterComposer,
          $$WalletSettingsTableOrderingComposer,
          $$WalletSettingsTableAnnotationComposer,
          $$WalletSettingsTableCreateCompanionBuilder,
          $$WalletSettingsTableUpdateCompanionBuilder,
          (
            WalletSettingRow,
            BaseReferences<
              _$AppDatabase,
              $WalletSettingsTable,
              WalletSettingRow
            >,
          ),
          WalletSettingRow,
          PrefetchHooks Function()
        > {
  $$WalletSettingsTableTableManager(
    _$AppDatabase db,
    $WalletSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> baseBalance = const Value.absent(),
              }) => WalletSettingsCompanion(
                id: id,
                name: name,
                baseBalance: baseBalance,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> baseBalance = const Value.absent(),
              }) => WalletSettingsCompanion.insert(
                id: id,
                name: name,
                baseBalance: baseBalance,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalletSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletSettingsTable,
      WalletSettingRow,
      $$WalletSettingsTableFilterComposer,
      $$WalletSettingsTableOrderingComposer,
      $$WalletSettingsTableAnnotationComposer,
      $$WalletSettingsTableCreateCompanionBuilder,
      $$WalletSettingsTableUpdateCompanionBuilder,
      (
        WalletSettingRow,
        BaseReferences<_$AppDatabase, $WalletSettingsTable, WalletSettingRow>,
      ),
      WalletSettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(_db, _db.recurringRules);
  $$RecurringOccurrencesTableTableManager get recurringOccurrences =>
      $$RecurringOccurrencesTableTableManager(_db, _db.recurringOccurrences);
  $$WalletSettingsTableTableManager get walletSettings =>
      $$WalletSettingsTableTableManager(_db, _db.walletSettings);
}
