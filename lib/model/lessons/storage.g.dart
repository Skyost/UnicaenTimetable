// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage.dart';

// ignore_for_file: type=lint
class $LessonsTable extends Lessons
    with TableInfo<$LessonsTable, _DriftLesson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<DateTime> start = GeneratedColumn<DateTime>(
      'start', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endMeta = const VerificationMeta('end');
  @override
  late final GeneratedColumn<DateTime> end = GeneratedColumn<DateTime>(
      'end', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [name, description, location, start, end];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lessons';
  @override
  VerificationContext validateIntegrity(Insertable<_DriftLesson> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('start')) {
      context.handle(
          _startMeta, start.isAcceptableOrUnknown(data['start']!, _startMeta));
    } else if (isInserting) {
      context.missing(_startMeta);
    }
    if (data.containsKey('end')) {
      context.handle(
          _endMeta, end.isAcceptableOrUnknown(data['end']!, _endMeta));
    } else if (isInserting) {
      context.missing(_endMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  _DriftLesson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return _DriftLesson(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      start: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start'])!,
      end: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end'])!,
    );
  }

  @override
  $LessonsTable createAlias(String alias) {
    return $LessonsTable(attachedDatabase, alias);
  }
}

class _DriftLesson extends DataClass implements Insertable<_DriftLesson> {
  /// Maps to [Lesson.name].
  final String name;

  /// Maps to [Lesson.description].
  final String? description;

  /// Maps to [Lesson.location].
  final String location;

  /// Maps to [Lesson.start].
  final DateTime start;

  /// Maps to [Lesson.end].
  final DateTime end;
  const _DriftLesson(
      {required this.name,
      this.description,
      required this.location,
      required this.start,
      required this.end});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['location'] = Variable<String>(location);
    map['start'] = Variable<DateTime>(start);
    map['end'] = Variable<DateTime>(end);
    return map;
  }

  LessonsCompanion toCompanion(bool nullToAbsent) {
    return LessonsCompanion(
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      location: Value(location),
      start: Value(start),
      end: Value(end),
    );
  }

  factory _DriftLesson.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return _DriftLesson(
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      location: serializer.fromJson<String>(json['location']),
      start: serializer.fromJson<DateTime>(json['start']),
      end: serializer.fromJson<DateTime>(json['end']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'location': serializer.toJson<String>(location),
      'start': serializer.toJson<DateTime>(start),
      'end': serializer.toJson<DateTime>(end),
    };
  }

  _DriftLesson copyWith(
          {String? name,
          Value<String?> description = const Value.absent(),
          String? location,
          DateTime? start,
          DateTime? end}) =>
      _DriftLesson(
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        location: location ?? this.location,
        start: start ?? this.start,
        end: end ?? this.end,
      );
  _DriftLesson copyWithCompanion(LessonsCompanion data) {
    return _DriftLesson(
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      location: data.location.present ? data.location.value : this.location,
      start: data.start.present ? data.start.value : this.start,
      end: data.end.present ? data.end.value : this.end,
    );
  }

  @override
  String toString() {
    return (StringBuffer('_DriftLesson(')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('location: $location, ')
          ..write('start: $start, ')
          ..write('end: $end')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, description, location, start, end);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _DriftLesson &&
          other.name == this.name &&
          other.description == this.description &&
          other.location == this.location &&
          other.start == this.start &&
          other.end == this.end);
}

class LessonsCompanion extends UpdateCompanion<_DriftLesson> {
  final Value<String> name;
  final Value<String?> description;
  final Value<String> location;
  final Value<DateTime> start;
  final Value<DateTime> end;
  final Value<int> rowid;
  const LessonsCompanion({
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.location = const Value.absent(),
    this.start = const Value.absent(),
    this.end = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonsCompanion.insert({
    required String name,
    this.description = const Value.absent(),
    required String location,
    required DateTime start,
    required DateTime end,
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        location = Value(location),
        start = Value(start),
        end = Value(end);
  static Insertable<_DriftLesson> custom({
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? location,
    Expression<DateTime>? start,
    Expression<DateTime>? end,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (start != null) 'start': start,
      if (end != null) 'end': end,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonsCompanion copyWith(
      {Value<String>? name,
      Value<String?>? description,
      Value<String>? location,
      Value<DateTime>? start,
      Value<DateTime>? end,
      Value<int>? rowid}) {
    return LessonsCompanion(
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      start: start ?? this.start,
      end: end ?? this.end,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (start.present) {
      map['start'] = Variable<DateTime>(start.value);
    }
    if (end.present) {
      map['end'] = Variable<DateTime>(end.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonsCompanion(')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('location: $location, ')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalStorage extends GeneratedDatabase {
  _$LocalStorage(QueryExecutor e) : super(e);
  $LocalStorageManager get managers => $LocalStorageManager(this);
  late final $LessonsTable lessons = $LessonsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [lessons];
}

typedef $$LessonsTableCreateCompanionBuilder = LessonsCompanion Function({
  required String name,
  Value<String?> description,
  required String location,
  required DateTime start,
  required DateTime end,
  Value<int> rowid,
});
typedef $$LessonsTableUpdateCompanionBuilder = LessonsCompanion Function({
  Value<String> name,
  Value<String?> description,
  Value<String> location,
  Value<DateTime> start,
  Value<DateTime> end,
  Value<int> rowid,
});

class $$LessonsTableFilterComposer
    extends Composer<_$LocalStorage, $LessonsTable> {
  $$LessonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get start => $composableBuilder(
      column: $table.start, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get end => $composableBuilder(
      column: $table.end, builder: (column) => ColumnFilters(column));
}

class $$LessonsTableOrderingComposer
    extends Composer<_$LocalStorage, $LessonsTable> {
  $$LessonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get start => $composableBuilder(
      column: $table.start, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get end => $composableBuilder(
      column: $table.end, builder: (column) => ColumnOrderings(column));
}

class $$LessonsTableAnnotationComposer
    extends Composer<_$LocalStorage, $LessonsTable> {
  $$LessonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get start =>
      $composableBuilder(column: $table.start, builder: (column) => column);

  GeneratedColumn<DateTime> get end =>
      $composableBuilder(column: $table.end, builder: (column) => column);
}

class $$LessonsTableTableManager extends RootTableManager<
    _$LocalStorage,
    $LessonsTable,
    _DriftLesson,
    $$LessonsTableFilterComposer,
    $$LessonsTableOrderingComposer,
    $$LessonsTableAnnotationComposer,
    $$LessonsTableCreateCompanionBuilder,
    $$LessonsTableUpdateCompanionBuilder,
    (_DriftLesson, BaseReferences<_$LocalStorage, $LessonsTable, _DriftLesson>),
    _DriftLesson,
    PrefetchHooks Function()> {
  $$LessonsTableTableManager(_$LocalStorage db, $LessonsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<DateTime> start = const Value.absent(),
            Value<DateTime> end = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LessonsCompanion(
            name: name,
            description: description,
            location: location,
            start: start,
            end: end,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String name,
            Value<String?> description = const Value.absent(),
            required String location,
            required DateTime start,
            required DateTime end,
            Value<int> rowid = const Value.absent(),
          }) =>
              LessonsCompanion.insert(
            name: name,
            description: description,
            location: location,
            start: start,
            end: end,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LessonsTableProcessedTableManager = ProcessedTableManager<
    _$LocalStorage,
    $LessonsTable,
    _DriftLesson,
    $$LessonsTableFilterComposer,
    $$LessonsTableOrderingComposer,
    $$LessonsTableAnnotationComposer,
    $$LessonsTableCreateCompanionBuilder,
    $$LessonsTableUpdateCompanionBuilder,
    (_DriftLesson, BaseReferences<_$LocalStorage, $LessonsTable, _DriftLesson>),
    _DriftLesson,
    PrefetchHooks Function()>;

class $LocalStorageManager {
  final _$LocalStorage _db;
  $LocalStorageManager(this._db);
  $$LessonsTableTableManager get lessons =>
      $$LessonsTableTableManager(_db, _db.lessons);
}
