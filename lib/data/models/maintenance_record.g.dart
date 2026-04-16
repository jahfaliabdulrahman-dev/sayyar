// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMaintenanceRecordCollection on Isar {
  IsarCollection<MaintenanceRecord> get maintenanceRecords => this.collection();
}

const MaintenanceRecordSchema = CollectionSchema(
  name: r'MaintenanceRecord',
  id: 8394037719530270343,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'invoiceImagePath': PropertySchema(
      id: 1,
      name: r'invoiceImagePath',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 2,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'laborCostSar': PropertySchema(
      id: 3,
      name: r'laborCostSar',
      type: IsarType.double,
    ),
    r'notes': PropertySchema(
      id: 4,
      name: r'notes',
      type: IsarType.string,
    ),
    r'odometerKm': PropertySchema(
      id: 5,
      name: r'odometerKm',
      type: IsarType.long,
    ),
    r'partsCostSar': PropertySchema(
      id: 6,
      name: r'partsCostSar',
      type: IsarType.double,
    ),
    r'partsReplaced': PropertySchema(
      id: 7,
      name: r'partsReplaced',
      type: IsarType.stringList,
    ),
    r'providerName': PropertySchema(
      id: 8,
      name: r'providerName',
      type: IsarType.string,
    ),
    r'serviceDate': PropertySchema(
      id: 9,
      name: r'serviceDate',
      type: IsarType.dateTime,
    ),
    r'serviceType': PropertySchema(
      id: 10,
      name: r'serviceType',
      type: IsarType.string,
    ),
    r'taskKeys': PropertySchema(
      id: 11,
      name: r'taskKeys',
      type: IsarType.stringList,
    ),
    r'totalCostSar': PropertySchema(
      id: 12,
      name: r'totalCostSar',
      type: IsarType.double,
    ),
    r'vehicleId': PropertySchema(
      id: 13,
      name: r'vehicleId',
      type: IsarType.long,
    )
  },
  estimateSize: _maintenanceRecordEstimateSize,
  serialize: _maintenanceRecordSerialize,
  deserialize: _maintenanceRecordDeserialize,
  deserializeProp: _maintenanceRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'vehicleId': IndexSchema(
      id: 2011968157433523416,
      name: r'vehicleId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'vehicleId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _maintenanceRecordGetId,
  getLinks: _maintenanceRecordGetLinks,
  attach: _maintenanceRecordAttach,
  version: '3.1.0+1',
);

int _maintenanceRecordEstimateSize(
  MaintenanceRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.invoiceImagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.partsReplaced;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.providerName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.serviceType.length * 3;
  {
    final list = object.taskKeys;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  return bytesCount;
}

void _maintenanceRecordSerialize(
  MaintenanceRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.invoiceImagePath);
  writer.writeBool(offsets[2], object.isSynced);
  writer.writeDouble(offsets[3], object.laborCostSar);
  writer.writeString(offsets[4], object.notes);
  writer.writeLong(offsets[5], object.odometerKm);
  writer.writeDouble(offsets[6], object.partsCostSar);
  writer.writeStringList(offsets[7], object.partsReplaced);
  writer.writeString(offsets[8], object.providerName);
  writer.writeDateTime(offsets[9], object.serviceDate);
  writer.writeString(offsets[10], object.serviceType);
  writer.writeStringList(offsets[11], object.taskKeys);
  writer.writeDouble(offsets[12], object.totalCostSar);
  writer.writeLong(offsets[13], object.vehicleId);
}

MaintenanceRecord _maintenanceRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MaintenanceRecord(
    createdAt: reader.readDateTime(offsets[0]),
    id: id,
    invoiceImagePath: reader.readStringOrNull(offsets[1]),
    isSynced: reader.readBoolOrNull(offsets[2]) ?? false,
    laborCostSar: reader.readDoubleOrNull(offsets[3]) ?? 0.0,
    notes: reader.readStringOrNull(offsets[4]),
    odometerKm: reader.readLong(offsets[5]),
    partsCostSar: reader.readDoubleOrNull(offsets[6]) ?? 0.0,
    partsReplaced: reader.readStringList(offsets[7]),
    providerName: reader.readStringOrNull(offsets[8]),
    serviceDate: reader.readDateTime(offsets[9]),
    serviceType: reader.readString(offsets[10]),
    taskKeys: reader.readStringList(offsets[11]),
    totalCostSar: reader.readDouble(offsets[12]),
    vehicleId: reader.readLong(offsets[13]),
  );
  return object;
}

P _maintenanceRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 7:
      return (reader.readStringList(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringList(offset)) as P;
    case 12:
      return (reader.readDouble(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _maintenanceRecordGetId(MaintenanceRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _maintenanceRecordGetLinks(
    MaintenanceRecord object) {
  return [];
}

void _maintenanceRecordAttach(
    IsarCollection<dynamic> col, Id id, MaintenanceRecord object) {
  object.id = id;
}

extension MaintenanceRecordQueryWhereSort
    on QueryBuilder<MaintenanceRecord, MaintenanceRecord, QWhere> {
  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterWhere>
      anyVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'vehicleId'),
      );
    });
  }
}

extension MaintenanceRecordQueryWhere
    on QueryBuilder<MaintenanceRecord, MaintenanceRecord, QWhereClause> {
  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterWhereClause>
      vehicleIdEqualTo(int vehicleId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'vehicleId',
        value: [vehicleId],
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterWhereClause>
      vehicleIdNotEqualTo(int vehicleId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'vehicleId',
              lower: [],
              upper: [vehicleId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'vehicleId',
              lower: [vehicleId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'vehicleId',
              lower: [vehicleId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'vehicleId',
              lower: [],
              upper: [vehicleId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterWhereClause>
      vehicleIdGreaterThan(
    int vehicleId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'vehicleId',
        lower: [vehicleId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterWhereClause>
      vehicleIdLessThan(
    int vehicleId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'vehicleId',
        lower: [],
        upper: [vehicleId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterWhereClause>
      vehicleIdBetween(
    int lowerVehicleId,
    int upperVehicleId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'vehicleId',
        lower: [lowerVehicleId],
        includeLower: includeLower,
        upper: [upperVehicleId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MaintenanceRecordQueryFilter
    on QueryBuilder<MaintenanceRecord, MaintenanceRecord, QFilterCondition> {
  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      invoiceImagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'invoiceImagePath',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      invoiceImagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'invoiceImagePath',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      invoiceImagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'invoiceImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      invoiceImagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'invoiceImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      invoiceImagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'invoiceImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      invoiceImagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'invoiceImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      invoiceImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'invoiceImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      invoiceImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'invoiceImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      invoiceImagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'invoiceImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      invoiceImagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'invoiceImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      invoiceImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'invoiceImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      invoiceImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'invoiceImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      laborCostSarEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'laborCostSar',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      laborCostSarGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'laborCostSar',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      laborCostSarLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'laborCostSar',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      laborCostSarBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'laborCostSar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      odometerKmEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'odometerKm',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      odometerKmGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'odometerKm',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      odometerKmLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'odometerKm',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      odometerKmBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'odometerKm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsCostSarEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partsCostSar',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsCostSarGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'partsCostSar',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsCostSarLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'partsCostSar',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsCostSarBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'partsCostSar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'partsReplaced',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'partsReplaced',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partsReplaced',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'partsReplaced',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'partsReplaced',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'partsReplaced',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'partsReplaced',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'partsReplaced',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'partsReplaced',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'partsReplaced',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partsReplaced',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'partsReplaced',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'partsReplaced',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'partsReplaced',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'partsReplaced',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'partsReplaced',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'partsReplaced',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      partsReplacedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'partsReplaced',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      providerNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'providerName',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      providerNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'providerName',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      providerNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      providerNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      providerNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      providerNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'providerName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      providerNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      providerNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      providerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      providerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'providerName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      providerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerName',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      providerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'providerName',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      serviceDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serviceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      serviceDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serviceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      serviceDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serviceDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      serviceDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serviceDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      serviceTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serviceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      serviceTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serviceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      serviceTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serviceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      serviceTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serviceType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      serviceTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serviceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      serviceTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serviceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      serviceTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serviceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      serviceTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serviceType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      serviceTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serviceType',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      serviceTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serviceType',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'taskKeys',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'taskKeys',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskKeys',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'taskKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'taskKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'taskKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'taskKeys',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'taskKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'taskKeys',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'taskKeys',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'taskKeys',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'taskKeys',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'taskKeys',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      taskKeysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'taskKeys',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      totalCostSarEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCostSar',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      totalCostSarGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCostSar',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      totalCostSarLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCostSar',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      totalCostSarBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCostSar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      vehicleIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicleId',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      vehicleIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vehicleId',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      vehicleIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vehicleId',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterFilterCondition>
      vehicleIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vehicleId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MaintenanceRecordQueryObject
    on QueryBuilder<MaintenanceRecord, MaintenanceRecord, QFilterCondition> {}

extension MaintenanceRecordQueryLinks
    on QueryBuilder<MaintenanceRecord, MaintenanceRecord, QFilterCondition> {}

extension MaintenanceRecordQuerySortBy
    on QueryBuilder<MaintenanceRecord, MaintenanceRecord, QSortBy> {
  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByInvoiceImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'invoiceImagePath', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByInvoiceImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'invoiceImagePath', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByLaborCostSar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'laborCostSar', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByLaborCostSarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'laborCostSar', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByOdometerKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odometerKm', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByOdometerKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odometerKm', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByPartsCostSar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partsCostSar', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByPartsCostSarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partsCostSar', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByProviderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByProviderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDate', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByServiceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDate', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByServiceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceType', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByServiceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceType', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByTotalCostSar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCostSar', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByTotalCostSarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCostSar', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      sortByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }
}

extension MaintenanceRecordQuerySortThenBy
    on QueryBuilder<MaintenanceRecord, MaintenanceRecord, QSortThenBy> {
  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByInvoiceImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'invoiceImagePath', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByInvoiceImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'invoiceImagePath', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByLaborCostSar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'laborCostSar', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByLaborCostSarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'laborCostSar', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByOdometerKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odometerKm', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByOdometerKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'odometerKm', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByPartsCostSar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partsCostSar', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByPartsCostSarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partsCostSar', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByProviderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByProviderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDate', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByServiceDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDate', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByServiceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceType', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByServiceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceType', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByTotalCostSar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCostSar', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByTotalCostSarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCostSar', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QAfterSortBy>
      thenByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }
}

extension MaintenanceRecordQueryWhereDistinct
    on QueryBuilder<MaintenanceRecord, MaintenanceRecord, QDistinct> {
  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QDistinct>
      distinctByInvoiceImagePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'invoiceImagePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QDistinct>
      distinctByLaborCostSar() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'laborCostSar');
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QDistinct>
      distinctByOdometerKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'odometerKm');
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QDistinct>
      distinctByPartsCostSar() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'partsCostSar');
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QDistinct>
      distinctByPartsReplaced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'partsReplaced');
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QDistinct>
      distinctByProviderName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QDistinct>
      distinctByServiceDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceDate');
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QDistinct>
      distinctByServiceType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QDistinct>
      distinctByTaskKeys() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskKeys');
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QDistinct>
      distinctByTotalCostSar() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCostSar');
    });
  }

  QueryBuilder<MaintenanceRecord, MaintenanceRecord, QDistinct>
      distinctByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleId');
    });
  }
}

extension MaintenanceRecordQueryProperty
    on QueryBuilder<MaintenanceRecord, MaintenanceRecord, QQueryProperty> {
  QueryBuilder<MaintenanceRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MaintenanceRecord, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MaintenanceRecord, String?, QQueryOperations>
      invoiceImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'invoiceImagePath');
    });
  }

  QueryBuilder<MaintenanceRecord, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<MaintenanceRecord, double, QQueryOperations>
      laborCostSarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'laborCostSar');
    });
  }

  QueryBuilder<MaintenanceRecord, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<MaintenanceRecord, int, QQueryOperations> odometerKmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'odometerKm');
    });
  }

  QueryBuilder<MaintenanceRecord, double, QQueryOperations>
      partsCostSarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'partsCostSar');
    });
  }

  QueryBuilder<MaintenanceRecord, List<String>?, QQueryOperations>
      partsReplacedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'partsReplaced');
    });
  }

  QueryBuilder<MaintenanceRecord, String?, QQueryOperations>
      providerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerName');
    });
  }

  QueryBuilder<MaintenanceRecord, DateTime, QQueryOperations>
      serviceDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceDate');
    });
  }

  QueryBuilder<MaintenanceRecord, String, QQueryOperations>
      serviceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceType');
    });
  }

  QueryBuilder<MaintenanceRecord, List<String>?, QQueryOperations>
      taskKeysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskKeys');
    });
  }

  QueryBuilder<MaintenanceRecord, double, QQueryOperations>
      totalCostSarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCostSar');
    });
  }

  QueryBuilder<MaintenanceRecord, int, QQueryOperations> vehicleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleId');
    });
  }
}
