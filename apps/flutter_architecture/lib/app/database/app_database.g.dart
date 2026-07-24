// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class AuthUser extends Table with TableInfo<AuthUser, AuthUserData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AuthUser(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY CHECK (slot = 1)',
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [slot, id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auth_user';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuthUserData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    }
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slot};
  @override
  AuthUserData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuthUserData(
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  AuthUser createAlias(String alias) {
    return AuthUser(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class AuthUserData extends DataClass implements Insertable<AuthUserData> {
  final int slot;
  final String id;
  final String name;
  const AuthUserData({
    required this.slot,
    required this.id,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slot'] = Variable<int>(slot);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  AuthUserCompanion toCompanion(bool nullToAbsent) {
    return AuthUserCompanion(
      slot: Value(slot),
      id: Value(id),
      name: Value(name),
    );
  }

  factory AuthUserData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuthUserData(
      slot: serializer.fromJson<int>(json['slot']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slot': serializer.toJson<int>(slot),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  AuthUserData copyWith({int? slot, String? id, String? name}) => AuthUserData(
    slot: slot ?? this.slot,
    id: id ?? this.id,
    name: name ?? this.name,
  );
  AuthUserData copyWithCompanion(AuthUserCompanion data) {
    return AuthUserData(
      slot: data.slot.present ? data.slot.value : this.slot,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuthUserData(')
          ..write('slot: $slot, ')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(slot, id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthUserData &&
          other.slot == this.slot &&
          other.id == this.id &&
          other.name == this.name);
}

class AuthUserCompanion extends UpdateCompanion<AuthUserData> {
  final Value<int> slot;
  final Value<String> id;
  final Value<String> name;
  const AuthUserCompanion({
    this.slot = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  AuthUserCompanion.insert({
    this.slot = const Value.absent(),
    required String id,
    required String name,
  }) : id = Value(id),
       name = Value(name);
  static Insertable<AuthUserData> custom({
    Expression<int>? slot,
    Expression<String>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (slot != null) 'slot': slot,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  AuthUserCompanion copyWith({
    Value<int>? slot,
    Value<String>? id,
    Value<String>? name,
  }) {
    return AuthUserCompanion(
      slot: slot ?? this.slot,
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthUserCompanion(')
          ..write('slot: $slot, ')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class CatalogCachePage extends Table
    with TableInfo<CatalogCachePage, CatalogCachePageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CatalogCachePage(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _requestCursorMeta = const VerificationMeta(
    'requestCursor',
  );
  late final GeneratedColumn<String> requestCursor = GeneratedColumn<String>(
    'request_cursor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _requestLimitMeta = const VerificationMeta(
    'requestLimit',
  );
  late final GeneratedColumn<int> requestLimit = GeneratedColumn<int>(
    'request_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _nextCursorMeta = const VerificationMeta(
    'nextCursor',
  );
  late final GeneratedColumn<String> nextCursor = GeneratedColumn<String>(
    'next_cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _chainRevisionMeta = const VerificationMeta(
    'chainRevision',
  );
  late final GeneratedColumn<int> chainRevision = GeneratedColumn<int>(
    'chain_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    query,
    requestCursor,
    requestLimit,
    nextCursor,
    updatedAt,
    chainRevision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_cache_page';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogCachePageData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('request_cursor')) {
      context.handle(
        _requestCursorMeta,
        requestCursor.isAcceptableOrUnknown(
          data['request_cursor']!,
          _requestCursorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestCursorMeta);
    }
    if (data.containsKey('request_limit')) {
      context.handle(
        _requestLimitMeta,
        requestLimit.isAcceptableOrUnknown(
          data['request_limit']!,
          _requestLimitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestLimitMeta);
    }
    if (data.containsKey('next_cursor')) {
      context.handle(
        _nextCursorMeta,
        nextCursor.isAcceptableOrUnknown(data['next_cursor']!, _nextCursorMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('chain_revision')) {
      context.handle(
        _chainRevisionMeta,
        chainRevision.isAcceptableOrUnknown(
          data['chain_revision']!,
          _chainRevisionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {query, requestCursor, requestLimit};
  @override
  CatalogCachePageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogCachePageData(
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      requestCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_cursor'],
      )!,
      requestLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}request_limit'],
      )!,
      nextCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_cursor'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      chainRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chain_revision'],
      )!,
    );
  }

  @override
  CatalogCachePage createAlias(String alias) {
    return CatalogCachePage(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY("query", request_cursor, request_limit)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class CatalogCachePageData extends DataClass
    implements Insertable<CatalogCachePageData> {
  final String query;
  final String requestCursor;
  final int requestLimit;
  final String? nextCursor;
  final int updatedAt;
  final int chainRevision;
  const CatalogCachePageData({
    required this.query,
    required this.requestCursor,
    required this.requestLimit,
    this.nextCursor,
    required this.updatedAt,
    required this.chainRevision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['query'] = Variable<String>(query);
    map['request_cursor'] = Variable<String>(requestCursor);
    map['request_limit'] = Variable<int>(requestLimit);
    if (!nullToAbsent || nextCursor != null) {
      map['next_cursor'] = Variable<String>(nextCursor);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    map['chain_revision'] = Variable<int>(chainRevision);
    return map;
  }

  CatalogCachePageCompanion toCompanion(bool nullToAbsent) {
    return CatalogCachePageCompanion(
      query: Value(query),
      requestCursor: Value(requestCursor),
      requestLimit: Value(requestLimit),
      nextCursor: nextCursor == null && nullToAbsent
          ? const Value.absent()
          : Value(nextCursor),
      updatedAt: Value(updatedAt),
      chainRevision: Value(chainRevision),
    );
  }

  factory CatalogCachePageData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogCachePageData(
      query: serializer.fromJson<String>(json['query']),
      requestCursor: serializer.fromJson<String>(json['request_cursor']),
      requestLimit: serializer.fromJson<int>(json['request_limit']),
      nextCursor: serializer.fromJson<String?>(json['next_cursor']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      chainRevision: serializer.fromJson<int>(json['chain_revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'query': serializer.toJson<String>(query),
      'request_cursor': serializer.toJson<String>(requestCursor),
      'request_limit': serializer.toJson<int>(requestLimit),
      'next_cursor': serializer.toJson<String?>(nextCursor),
      'updated_at': serializer.toJson<int>(updatedAt),
      'chain_revision': serializer.toJson<int>(chainRevision),
    };
  }

  CatalogCachePageData copyWith({
    String? query,
    String? requestCursor,
    int? requestLimit,
    Value<String?> nextCursor = const Value.absent(),
    int? updatedAt,
    int? chainRevision,
  }) => CatalogCachePageData(
    query: query ?? this.query,
    requestCursor: requestCursor ?? this.requestCursor,
    requestLimit: requestLimit ?? this.requestLimit,
    nextCursor: nextCursor.present ? nextCursor.value : this.nextCursor,
    updatedAt: updatedAt ?? this.updatedAt,
    chainRevision: chainRevision ?? this.chainRevision,
  );
  CatalogCachePageData copyWithCompanion(CatalogCachePageCompanion data) {
    return CatalogCachePageData(
      query: data.query.present ? data.query.value : this.query,
      requestCursor: data.requestCursor.present
          ? data.requestCursor.value
          : this.requestCursor,
      requestLimit: data.requestLimit.present
          ? data.requestLimit.value
          : this.requestLimit,
      nextCursor: data.nextCursor.present
          ? data.nextCursor.value
          : this.nextCursor,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      chainRevision: data.chainRevision.present
          ? data.chainRevision.value
          : this.chainRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogCachePageData(')
          ..write('query: $query, ')
          ..write('requestCursor: $requestCursor, ')
          ..write('requestLimit: $requestLimit, ')
          ..write('nextCursor: $nextCursor, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('chainRevision: $chainRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    query,
    requestCursor,
    requestLimit,
    nextCursor,
    updatedAt,
    chainRevision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogCachePageData &&
          other.query == this.query &&
          other.requestCursor == this.requestCursor &&
          other.requestLimit == this.requestLimit &&
          other.nextCursor == this.nextCursor &&
          other.updatedAt == this.updatedAt &&
          other.chainRevision == this.chainRevision);
}

class CatalogCachePageCompanion extends UpdateCompanion<CatalogCachePageData> {
  final Value<String> query;
  final Value<String> requestCursor;
  final Value<int> requestLimit;
  final Value<String?> nextCursor;
  final Value<int> updatedAt;
  final Value<int> chainRevision;
  final Value<int> rowid;
  const CatalogCachePageCompanion({
    this.query = const Value.absent(),
    this.requestCursor = const Value.absent(),
    this.requestLimit = const Value.absent(),
    this.nextCursor = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.chainRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogCachePageCompanion.insert({
    required String query,
    required String requestCursor,
    required int requestLimit,
    this.nextCursor = const Value.absent(),
    required int updatedAt,
    this.chainRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : query = Value(query),
       requestCursor = Value(requestCursor),
       requestLimit = Value(requestLimit),
       updatedAt = Value(updatedAt);
  static Insertable<CatalogCachePageData> custom({
    Expression<String>? query,
    Expression<String>? requestCursor,
    Expression<int>? requestLimit,
    Expression<String>? nextCursor,
    Expression<int>? updatedAt,
    Expression<int>? chainRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (query != null) 'query': query,
      if (requestCursor != null) 'request_cursor': requestCursor,
      if (requestLimit != null) 'request_limit': requestLimit,
      if (nextCursor != null) 'next_cursor': nextCursor,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (chainRevision != null) 'chain_revision': chainRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogCachePageCompanion copyWith({
    Value<String>? query,
    Value<String>? requestCursor,
    Value<int>? requestLimit,
    Value<String?>? nextCursor,
    Value<int>? updatedAt,
    Value<int>? chainRevision,
    Value<int>? rowid,
  }) {
    return CatalogCachePageCompanion(
      query: query ?? this.query,
      requestCursor: requestCursor ?? this.requestCursor,
      requestLimit: requestLimit ?? this.requestLimit,
      nextCursor: nextCursor ?? this.nextCursor,
      updatedAt: updatedAt ?? this.updatedAt,
      chainRevision: chainRevision ?? this.chainRevision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (requestCursor.present) {
      map['request_cursor'] = Variable<String>(requestCursor.value);
    }
    if (requestLimit.present) {
      map['request_limit'] = Variable<int>(requestLimit.value);
    }
    if (nextCursor.present) {
      map['next_cursor'] = Variable<String>(nextCursor.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (chainRevision.present) {
      map['chain_revision'] = Variable<int>(chainRevision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogCachePageCompanion(')
          ..write('query: $query, ')
          ..write('requestCursor: $requestCursor, ')
          ..write('requestLimit: $requestLimit, ')
          ..write('nextCursor: $nextCursor, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('chainRevision: $chainRevision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class CatalogCachePageItem extends Table
    with TableInfo<CatalogCachePageItem, CatalogCachePageItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CatalogCachePageItem(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _requestCursorMeta = const VerificationMeta(
    'requestCursor',
  );
  late final GeneratedColumn<String> requestCursor = GeneratedColumn<String>(
    'request_cursor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _requestLimitMeta = const VerificationMeta(
    'requestLimit',
  );
  late final GeneratedColumn<int> requestLimit = GeneratedColumn<int>(
    'request_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _itemPositionMeta = const VerificationMeta(
    'itemPosition',
  );
  late final GeneratedColumn<int> itemPosition = GeneratedColumn<int>(
    'item_position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _itemNameMeta = const VerificationMeta(
    'itemName',
  );
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
    'item_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _itemDescriptionMeta = const VerificationMeta(
    'itemDescription',
  );
  late final GeneratedColumn<String> itemDescription = GeneratedColumn<String>(
    'item_description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    query,
    requestCursor,
    requestLimit,
    itemId,
    itemPosition,
    itemName,
    itemDescription,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_cache_page_item';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogCachePageItemData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('request_cursor')) {
      context.handle(
        _requestCursorMeta,
        requestCursor.isAcceptableOrUnknown(
          data['request_cursor']!,
          _requestCursorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestCursorMeta);
    }
    if (data.containsKey('request_limit')) {
      context.handle(
        _requestLimitMeta,
        requestLimit.isAcceptableOrUnknown(
          data['request_limit']!,
          _requestLimitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestLimitMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('item_position')) {
      context.handle(
        _itemPositionMeta,
        itemPosition.isAcceptableOrUnknown(
          data['item_position']!,
          _itemPositionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_itemPositionMeta);
    }
    if (data.containsKey('item_name')) {
      context.handle(
        _itemNameMeta,
        itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta),
      );
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('item_description')) {
      context.handle(
        _itemDescriptionMeta,
        itemDescription.isAcceptableOrUnknown(
          data['item_description']!,
          _itemDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_itemDescriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    query,
    requestCursor,
    requestLimit,
    itemId,
  };
  @override
  CatalogCachePageItemData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogCachePageItemData(
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      requestCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_cursor'],
      )!,
      requestLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}request_limit'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      itemPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_position'],
      )!,
      itemName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_name'],
      )!,
      itemDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_description'],
      )!,
    );
  }

  @override
  CatalogCachePageItem createAlias(String alias) {
    return CatalogCachePageItem(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY("query", request_cursor, request_limit, item_id)',
    'FOREIGN KEY("query", request_cursor, request_limit)REFERENCES catalog_cache_page("query", request_cursor, request_limit)ON DELETE CASCADE',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class CatalogCachePageItemData extends DataClass
    implements Insertable<CatalogCachePageItemData> {
  final String query;
  final String requestCursor;
  final int requestLimit;
  final String itemId;
  final int itemPosition;
  final String itemName;
  final String itemDescription;
  const CatalogCachePageItemData({
    required this.query,
    required this.requestCursor,
    required this.requestLimit,
    required this.itemId,
    required this.itemPosition,
    required this.itemName,
    required this.itemDescription,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['query'] = Variable<String>(query);
    map['request_cursor'] = Variable<String>(requestCursor);
    map['request_limit'] = Variable<int>(requestLimit);
    map['item_id'] = Variable<String>(itemId);
    map['item_position'] = Variable<int>(itemPosition);
    map['item_name'] = Variable<String>(itemName);
    map['item_description'] = Variable<String>(itemDescription);
    return map;
  }

  CatalogCachePageItemCompanion toCompanion(bool nullToAbsent) {
    return CatalogCachePageItemCompanion(
      query: Value(query),
      requestCursor: Value(requestCursor),
      requestLimit: Value(requestLimit),
      itemId: Value(itemId),
      itemPosition: Value(itemPosition),
      itemName: Value(itemName),
      itemDescription: Value(itemDescription),
    );
  }

  factory CatalogCachePageItemData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogCachePageItemData(
      query: serializer.fromJson<String>(json['query']),
      requestCursor: serializer.fromJson<String>(json['request_cursor']),
      requestLimit: serializer.fromJson<int>(json['request_limit']),
      itemId: serializer.fromJson<String>(json['item_id']),
      itemPosition: serializer.fromJson<int>(json['item_position']),
      itemName: serializer.fromJson<String>(json['item_name']),
      itemDescription: serializer.fromJson<String>(json['item_description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'query': serializer.toJson<String>(query),
      'request_cursor': serializer.toJson<String>(requestCursor),
      'request_limit': serializer.toJson<int>(requestLimit),
      'item_id': serializer.toJson<String>(itemId),
      'item_position': serializer.toJson<int>(itemPosition),
      'item_name': serializer.toJson<String>(itemName),
      'item_description': serializer.toJson<String>(itemDescription),
    };
  }

  CatalogCachePageItemData copyWith({
    String? query,
    String? requestCursor,
    int? requestLimit,
    String? itemId,
    int? itemPosition,
    String? itemName,
    String? itemDescription,
  }) => CatalogCachePageItemData(
    query: query ?? this.query,
    requestCursor: requestCursor ?? this.requestCursor,
    requestLimit: requestLimit ?? this.requestLimit,
    itemId: itemId ?? this.itemId,
    itemPosition: itemPosition ?? this.itemPosition,
    itemName: itemName ?? this.itemName,
    itemDescription: itemDescription ?? this.itemDescription,
  );
  CatalogCachePageItemData copyWithCompanion(
    CatalogCachePageItemCompanion data,
  ) {
    return CatalogCachePageItemData(
      query: data.query.present ? data.query.value : this.query,
      requestCursor: data.requestCursor.present
          ? data.requestCursor.value
          : this.requestCursor,
      requestLimit: data.requestLimit.present
          ? data.requestLimit.value
          : this.requestLimit,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      itemPosition: data.itemPosition.present
          ? data.itemPosition.value
          : this.itemPosition,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      itemDescription: data.itemDescription.present
          ? data.itemDescription.value
          : this.itemDescription,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogCachePageItemData(')
          ..write('query: $query, ')
          ..write('requestCursor: $requestCursor, ')
          ..write('requestLimit: $requestLimit, ')
          ..write('itemId: $itemId, ')
          ..write('itemPosition: $itemPosition, ')
          ..write('itemName: $itemName, ')
          ..write('itemDescription: $itemDescription')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    query,
    requestCursor,
    requestLimit,
    itemId,
    itemPosition,
    itemName,
    itemDescription,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogCachePageItemData &&
          other.query == this.query &&
          other.requestCursor == this.requestCursor &&
          other.requestLimit == this.requestLimit &&
          other.itemId == this.itemId &&
          other.itemPosition == this.itemPosition &&
          other.itemName == this.itemName &&
          other.itemDescription == this.itemDescription);
}

class CatalogCachePageItemCompanion
    extends UpdateCompanion<CatalogCachePageItemData> {
  final Value<String> query;
  final Value<String> requestCursor;
  final Value<int> requestLimit;
  final Value<String> itemId;
  final Value<int> itemPosition;
  final Value<String> itemName;
  final Value<String> itemDescription;
  final Value<int> rowid;
  const CatalogCachePageItemCompanion({
    this.query = const Value.absent(),
    this.requestCursor = const Value.absent(),
    this.requestLimit = const Value.absent(),
    this.itemId = const Value.absent(),
    this.itemPosition = const Value.absent(),
    this.itemName = const Value.absent(),
    this.itemDescription = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogCachePageItemCompanion.insert({
    required String query,
    required String requestCursor,
    required int requestLimit,
    required String itemId,
    required int itemPosition,
    required String itemName,
    required String itemDescription,
    this.rowid = const Value.absent(),
  }) : query = Value(query),
       requestCursor = Value(requestCursor),
       requestLimit = Value(requestLimit),
       itemId = Value(itemId),
       itemPosition = Value(itemPosition),
       itemName = Value(itemName),
       itemDescription = Value(itemDescription);
  static Insertable<CatalogCachePageItemData> custom({
    Expression<String>? query,
    Expression<String>? requestCursor,
    Expression<int>? requestLimit,
    Expression<String>? itemId,
    Expression<int>? itemPosition,
    Expression<String>? itemName,
    Expression<String>? itemDescription,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (query != null) 'query': query,
      if (requestCursor != null) 'request_cursor': requestCursor,
      if (requestLimit != null) 'request_limit': requestLimit,
      if (itemId != null) 'item_id': itemId,
      if (itemPosition != null) 'item_position': itemPosition,
      if (itemName != null) 'item_name': itemName,
      if (itemDescription != null) 'item_description': itemDescription,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogCachePageItemCompanion copyWith({
    Value<String>? query,
    Value<String>? requestCursor,
    Value<int>? requestLimit,
    Value<String>? itemId,
    Value<int>? itemPosition,
    Value<String>? itemName,
    Value<String>? itemDescription,
    Value<int>? rowid,
  }) {
    return CatalogCachePageItemCompanion(
      query: query ?? this.query,
      requestCursor: requestCursor ?? this.requestCursor,
      requestLimit: requestLimit ?? this.requestLimit,
      itemId: itemId ?? this.itemId,
      itemPosition: itemPosition ?? this.itemPosition,
      itemName: itemName ?? this.itemName,
      itemDescription: itemDescription ?? this.itemDescription,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (requestCursor.present) {
      map['request_cursor'] = Variable<String>(requestCursor.value);
    }
    if (requestLimit.present) {
      map['request_limit'] = Variable<int>(requestLimit.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (itemPosition.present) {
      map['item_position'] = Variable<int>(itemPosition.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (itemDescription.present) {
      map['item_description'] = Variable<String>(itemDescription.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogCachePageItemCompanion(')
          ..write('query: $query, ')
          ..write('requestCursor: $requestCursor, ')
          ..write('requestLimit: $requestLimit, ')
          ..write('itemId: $itemId, ')
          ..write('itemPosition: $itemPosition, ')
          ..write('itemName: $itemName, ')
          ..write('itemDescription: $itemDescription, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final AuthUser authUser = AuthUser(this);
  late final CatalogCachePage catalogCachePage = CatalogCachePage(this);
  late final CatalogCachePageItem catalogCachePageItem = CatalogCachePageItem(
    this,
  );
  late final Index catalogCachePageItemPositionIdx = Index(
    'catalog_cache_page_item_position_idx',
    'CREATE UNIQUE INDEX catalog_cache_page_item_position_idx ON catalog_cache_page_item ("query", request_cursor, request_limit, item_position)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    authUser,
    catalogCachePage,
    catalogCachePageItem,
    catalogCachePageItemPositionIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'catalog_cache_page',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('catalog_cache_page_item', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $AuthUserCreateCompanionBuilder =
    AuthUserCompanion Function({
      Value<int> slot,
      required String id,
      required String name,
    });
typedef $AuthUserUpdateCompanionBuilder =
    AuthUserCompanion Function({
      Value<int> slot,
      Value<String> id,
      Value<String> name,
    });

class $AuthUserFilterComposer extends Composer<_$AppDatabase, AuthUser> {
  $AuthUserFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $AuthUserOrderingComposer extends Composer<_$AppDatabase, AuthUser> {
  $AuthUserOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $AuthUserAnnotationComposer extends Composer<_$AppDatabase, AuthUser> {
  $AuthUserAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $AuthUserTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          AuthUser,
          AuthUserData,
          $AuthUserFilterComposer,
          $AuthUserOrderingComposer,
          $AuthUserAnnotationComposer,
          $AuthUserCreateCompanionBuilder,
          $AuthUserUpdateCompanionBuilder,
          (AuthUserData, BaseReferences<_$AppDatabase, AuthUser, AuthUserData>),
          AuthUserData,
          PrefetchHooks Function()
        > {
  $AuthUserTableManager(_$AppDatabase db, AuthUser table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AuthUserFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AuthUserOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AuthUserAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> slot = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => AuthUserCompanion(slot: slot, id: id, name: name),
          createCompanionCallback:
              ({
                Value<int> slot = const Value.absent(),
                required String id,
                required String name,
              }) => AuthUserCompanion.insert(slot: slot, id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $AuthUserProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      AuthUser,
      AuthUserData,
      $AuthUserFilterComposer,
      $AuthUserOrderingComposer,
      $AuthUserAnnotationComposer,
      $AuthUserCreateCompanionBuilder,
      $AuthUserUpdateCompanionBuilder,
      (AuthUserData, BaseReferences<_$AppDatabase, AuthUser, AuthUserData>),
      AuthUserData,
      PrefetchHooks Function()
    >;
typedef $CatalogCachePageCreateCompanionBuilder =
    CatalogCachePageCompanion Function({
      required String query,
      required String requestCursor,
      required int requestLimit,
      Value<String?> nextCursor,
      required int updatedAt,
      Value<int> chainRevision,
      Value<int> rowid,
    });
typedef $CatalogCachePageUpdateCompanionBuilder =
    CatalogCachePageCompanion Function({
      Value<String> query,
      Value<String> requestCursor,
      Value<int> requestLimit,
      Value<String?> nextCursor,
      Value<int> updatedAt,
      Value<int> chainRevision,
      Value<int> rowid,
    });

class $CatalogCachePageFilterComposer
    extends Composer<_$AppDatabase, CatalogCachePage> {
  $CatalogCachePageFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestCursor => $composableBuilder(
    column: $table.requestCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestLimit => $composableBuilder(
    column: $table.requestLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextCursor => $composableBuilder(
    column: $table.nextCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chainRevision => $composableBuilder(
    column: $table.chainRevision,
    builder: (column) => ColumnFilters(column),
  );
}

class $CatalogCachePageOrderingComposer
    extends Composer<_$AppDatabase, CatalogCachePage> {
  $CatalogCachePageOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestCursor => $composableBuilder(
    column: $table.requestCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestLimit => $composableBuilder(
    column: $table.requestLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextCursor => $composableBuilder(
    column: $table.nextCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chainRevision => $composableBuilder(
    column: $table.chainRevision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $CatalogCachePageAnnotationComposer
    extends Composer<_$AppDatabase, CatalogCachePage> {
  $CatalogCachePageAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<String> get requestCursor => $composableBuilder(
    column: $table.requestCursor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestLimit => $composableBuilder(
    column: $table.requestLimit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextCursor => $composableBuilder(
    column: $table.nextCursor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get chainRevision => $composableBuilder(
    column: $table.chainRevision,
    builder: (column) => column,
  );
}

class $CatalogCachePageTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          CatalogCachePage,
          CatalogCachePageData,
          $CatalogCachePageFilterComposer,
          $CatalogCachePageOrderingComposer,
          $CatalogCachePageAnnotationComposer,
          $CatalogCachePageCreateCompanionBuilder,
          $CatalogCachePageUpdateCompanionBuilder,
          (
            CatalogCachePageData,
            BaseReferences<
              _$AppDatabase,
              CatalogCachePage,
              CatalogCachePageData
            >,
          ),
          CatalogCachePageData,
          PrefetchHooks Function()
        > {
  $CatalogCachePageTableManager(_$AppDatabase db, CatalogCachePage table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CatalogCachePageFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CatalogCachePageOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CatalogCachePageAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> query = const Value.absent(),
                Value<String> requestCursor = const Value.absent(),
                Value<int> requestLimit = const Value.absent(),
                Value<String?> nextCursor = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> chainRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogCachePageCompanion(
                query: query,
                requestCursor: requestCursor,
                requestLimit: requestLimit,
                nextCursor: nextCursor,
                updatedAt: updatedAt,
                chainRevision: chainRevision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String query,
                required String requestCursor,
                required int requestLimit,
                Value<String?> nextCursor = const Value.absent(),
                required int updatedAt,
                Value<int> chainRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogCachePageCompanion.insert(
                query: query,
                requestCursor: requestCursor,
                requestLimit: requestLimit,
                nextCursor: nextCursor,
                updatedAt: updatedAt,
                chainRevision: chainRevision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $CatalogCachePageProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      CatalogCachePage,
      CatalogCachePageData,
      $CatalogCachePageFilterComposer,
      $CatalogCachePageOrderingComposer,
      $CatalogCachePageAnnotationComposer,
      $CatalogCachePageCreateCompanionBuilder,
      $CatalogCachePageUpdateCompanionBuilder,
      (
        CatalogCachePageData,
        BaseReferences<_$AppDatabase, CatalogCachePage, CatalogCachePageData>,
      ),
      CatalogCachePageData,
      PrefetchHooks Function()
    >;
typedef $CatalogCachePageItemCreateCompanionBuilder =
    CatalogCachePageItemCompanion Function({
      required String query,
      required String requestCursor,
      required int requestLimit,
      required String itemId,
      required int itemPosition,
      required String itemName,
      required String itemDescription,
      Value<int> rowid,
    });
typedef $CatalogCachePageItemUpdateCompanionBuilder =
    CatalogCachePageItemCompanion Function({
      Value<String> query,
      Value<String> requestCursor,
      Value<int> requestLimit,
      Value<String> itemId,
      Value<int> itemPosition,
      Value<String> itemName,
      Value<String> itemDescription,
      Value<int> rowid,
    });

class $CatalogCachePageItemFilterComposer
    extends Composer<_$AppDatabase, CatalogCachePageItem> {
  $CatalogCachePageItemFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestCursor => $composableBuilder(
    column: $table.requestCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestLimit => $composableBuilder(
    column: $table.requestLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemPosition => $composableBuilder(
    column: $table.itemPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemDescription => $composableBuilder(
    column: $table.itemDescription,
    builder: (column) => ColumnFilters(column),
  );
}

class $CatalogCachePageItemOrderingComposer
    extends Composer<_$AppDatabase, CatalogCachePageItem> {
  $CatalogCachePageItemOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestCursor => $composableBuilder(
    column: $table.requestCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestLimit => $composableBuilder(
    column: $table.requestLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemPosition => $composableBuilder(
    column: $table.itemPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemDescription => $composableBuilder(
    column: $table.itemDescription,
    builder: (column) => ColumnOrderings(column),
  );
}

class $CatalogCachePageItemAnnotationComposer
    extends Composer<_$AppDatabase, CatalogCachePageItem> {
  $CatalogCachePageItemAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<String> get requestCursor => $composableBuilder(
    column: $table.requestCursor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestLimit => $composableBuilder(
    column: $table.requestLimit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get itemPosition => $composableBuilder(
    column: $table.itemPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<String> get itemDescription => $composableBuilder(
    column: $table.itemDescription,
    builder: (column) => column,
  );
}

class $CatalogCachePageItemTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          CatalogCachePageItem,
          CatalogCachePageItemData,
          $CatalogCachePageItemFilterComposer,
          $CatalogCachePageItemOrderingComposer,
          $CatalogCachePageItemAnnotationComposer,
          $CatalogCachePageItemCreateCompanionBuilder,
          $CatalogCachePageItemUpdateCompanionBuilder,
          (
            CatalogCachePageItemData,
            BaseReferences<
              _$AppDatabase,
              CatalogCachePageItem,
              CatalogCachePageItemData
            >,
          ),
          CatalogCachePageItemData,
          PrefetchHooks Function()
        > {
  $CatalogCachePageItemTableManager(
    _$AppDatabase db,
    CatalogCachePageItem table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CatalogCachePageItemFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CatalogCachePageItemOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CatalogCachePageItemAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> query = const Value.absent(),
                Value<String> requestCursor = const Value.absent(),
                Value<int> requestLimit = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<int> itemPosition = const Value.absent(),
                Value<String> itemName = const Value.absent(),
                Value<String> itemDescription = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogCachePageItemCompanion(
                query: query,
                requestCursor: requestCursor,
                requestLimit: requestLimit,
                itemId: itemId,
                itemPosition: itemPosition,
                itemName: itemName,
                itemDescription: itemDescription,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String query,
                required String requestCursor,
                required int requestLimit,
                required String itemId,
                required int itemPosition,
                required String itemName,
                required String itemDescription,
                Value<int> rowid = const Value.absent(),
              }) => CatalogCachePageItemCompanion.insert(
                query: query,
                requestCursor: requestCursor,
                requestLimit: requestLimit,
                itemId: itemId,
                itemPosition: itemPosition,
                itemName: itemName,
                itemDescription: itemDescription,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $CatalogCachePageItemProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      CatalogCachePageItem,
      CatalogCachePageItemData,
      $CatalogCachePageItemFilterComposer,
      $CatalogCachePageItemOrderingComposer,
      $CatalogCachePageItemAnnotationComposer,
      $CatalogCachePageItemCreateCompanionBuilder,
      $CatalogCachePageItemUpdateCompanionBuilder,
      (
        CatalogCachePageItemData,
        BaseReferences<
          _$AppDatabase,
          CatalogCachePageItem,
          CatalogCachePageItemData
        >,
      ),
      CatalogCachePageItemData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $AuthUserTableManager get authUser =>
      $AuthUserTableManager(_db, _db.authUser);
  $CatalogCachePageTableManager get catalogCachePage =>
      $CatalogCachePageTableManager(_db, _db.catalogCachePage);
  $CatalogCachePageItemTableManager get catalogCachePageItem =>
      $CatalogCachePageItemTableManager(_db, _db.catalogCachePageItem);
}
