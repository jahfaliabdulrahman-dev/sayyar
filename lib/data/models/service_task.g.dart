// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_task.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetServiceTaskCollection on Isar {
  IsarCollection<ServiceTask> get serviceTasks => this.collection();
}

const ServiceTaskSchema = CollectionSchema(
  name: r'ServiceTask',
  id: -3645774674843033527,
  properties: {
    r'displayNameAr': PropertySchema(
      id: 0,
      name: r'displayNameAr',
      type: IsarType.string,
    ),
    r'displayNameEn': PropertySchema(
      id: 1,
      name: r'displayNameEn',
      type: IsarType.string,
    ),
    r'intervalKm': PropertySchema(
      id: 2,
      name: r'intervalKm',
      type: IsarType.long,
    ),
    r'intervalMonths': PropertySchema(
      id: 3,
      name: r'intervalMonths',
      type: IsarType.long,
    ),
    r'lastDoneDate': PropertySchema(
      id: 4,
      name: r'lastDoneDate',
      type: IsarType.dateTime,
    ),
    r'lastDoneKm': PropertySchema(
      id: 5,
      name: r'lastDoneKm',
      type: IsarType.long,
    ),
    r'taskKey': PropertySchema(
      id: 6,
      name: r'taskKey',
      type: IsarType.string,
    ),
    r'vehicleId': PropertySchema(
      id: 7,
      name: r'vehicleId',
      type: IsarType.long,
    )
  },
  estimateSize: _serviceTaskEstimateSize,
  serialize: _serviceTaskSerialize,
  deserialize: _serviceTaskDeserialize,
  deserializeProp: _serviceTaskDeserializeProp,
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
    ),
    r'taskKey': IndexSchema(
      id: -6193150409904739859,
      name: r'taskKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'taskKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _serviceTaskGetId,
  getLinks: _serviceTaskGetLinks,
  attach: _serviceTaskAttach,
  version: '3.1.0+1',
);

int _serviceTaskEstimateSize(
  ServiceTask object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.displayNameAr.length * 3;
  bytesCount += 3 + object.displayNameEn.length * 3;
  bytesCount += 3 + object.taskKey.length * 3;
  return bytesCount;
}

void _serviceTaskSerialize(
  ServiceTask object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.displayNameAr);
  writer.writeString(offsets[1], object.displayNameEn);
  writer.writeLong(offsets[2], object.intervalKm);
  writer.writeLong(offsets[3], object.intervalMonths);
  writer.writeDateTime(offsets[4], object.lastDoneDate);
  writer.writeLong(offsets[5], object.lastDoneKm);
  writer.writeString(offsets[6], object.taskKey);
  writer.writeLong(offsets[7], object.vehicleId);
}

ServiceTask _serviceTaskDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ServiceTask(
    displayNameAr: reader.readString(offsets[0]),
    displayNameEn: reader.readString(offsets[1]),
    id: id,
    intervalKm: reader.readLongOrNull(offsets[2]),
    intervalMonths: reader.readLongOrNull(offsets[3]),
    lastDoneDate: reader.readDateTimeOrNull(offsets[4]),
    lastDoneKm: reader.readLongOrNull(offsets[5]),
    taskKey: reader.readString(offsets[6]),
    vehicleId: reader.readLong(offsets[7]),
  );
  return object;
}

P _serviceTaskDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _serviceTaskGetId(ServiceTask object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _serviceTaskGetLinks(ServiceTask object) {
  return [];
}

void _serviceTaskAttach(
    IsarCollection<dynamic> col, Id id, ServiceTask object) {
  object.id = id;
}

extension ServiceTaskQueryWhereSort
    on QueryBuilder<ServiceTask, ServiceTask, QWhere> {
  QueryBuilder<ServiceTask, ServiceTask, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterWhere> anyVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'vehicleId'),
      );
    });
  }
}

extension ServiceTaskQueryWhere
    on QueryBuilder<ServiceTask, ServiceTask, QWhereClause> {
  QueryBuilder<ServiceTask, ServiceTask, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<ServiceTask, ServiceTask, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterWhereClause> idBetween(
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

  QueryBuilder<ServiceTask, ServiceTask, QAfterWhereClause> vehicleIdEqualTo(
      int vehicleId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'vehicleId',
        value: [vehicleId],
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterWhereClause> vehicleIdNotEqualTo(
      int vehicleId) {
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

  QueryBuilder<ServiceTask, ServiceTask, QAfterWhereClause>
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

  QueryBuilder<ServiceTask, ServiceTask, QAfterWhereClause> vehicleIdLessThan(
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

  QueryBuilder<ServiceTask, ServiceTask, QAfterWhereClause> vehicleIdBetween(
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

  QueryBuilder<ServiceTask, ServiceTask, QAfterWhereClause> taskKeyEqualTo(
      String taskKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'taskKey',
        value: [taskKey],
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterWhereClause> taskKeyNotEqualTo(
      String taskKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskKey',
              lower: [],
              upper: [taskKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskKey',
              lower: [taskKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskKey',
              lower: [taskKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskKey',
              lower: [],
              upper: [taskKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ServiceTaskQueryFilter
    on QueryBuilder<ServiceTask, ServiceTask, QFilterCondition> {
  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameArEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayNameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameArGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayNameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameArLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayNameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameArBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayNameAr',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameArStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayNameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameArEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayNameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameArContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayNameAr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameArMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayNameAr',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameArIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayNameAr',
        value: '',
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameArIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayNameAr',
        value: '',
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameEnEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayNameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameEnGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayNameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameEnLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayNameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameEnBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayNameEn',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameEnStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayNameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameEnEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayNameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameEnContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayNameEn',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameEnMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayNameEn',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameEnIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayNameEn',
        value: '',
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      displayNameEnIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayNameEn',
        value: '',
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      intervalKmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'intervalKm',
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      intervalKmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'intervalKm',
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      intervalKmEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'intervalKm',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      intervalKmGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'intervalKm',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      intervalKmLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'intervalKm',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      intervalKmBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'intervalKm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      intervalMonthsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'intervalMonths',
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      intervalMonthsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'intervalMonths',
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      intervalMonthsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'intervalMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      intervalMonthsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'intervalMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      intervalMonthsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'intervalMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      intervalMonthsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'intervalMonths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      lastDoneDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastDoneDate',
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      lastDoneDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastDoneDate',
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      lastDoneDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastDoneDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      lastDoneDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastDoneDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      lastDoneDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastDoneDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      lastDoneDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastDoneDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      lastDoneKmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastDoneKm',
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      lastDoneKmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastDoneKm',
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      lastDoneKmEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastDoneKm',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      lastDoneKmGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastDoneKm',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      lastDoneKmLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastDoneKm',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      lastDoneKmBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastDoneKm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition> taskKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      taskKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition> taskKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition> taskKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      taskKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'taskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition> taskKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'taskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition> taskKeyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'taskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition> taskKeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'taskKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      taskKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      taskKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'taskKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
      vehicleIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicleId',
        value: value,
      ));
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
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

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
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

  QueryBuilder<ServiceTask, ServiceTask, QAfterFilterCondition>
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

extension ServiceTaskQueryObject
    on QueryBuilder<ServiceTask, ServiceTask, QFilterCondition> {}

extension ServiceTaskQueryLinks
    on QueryBuilder<ServiceTask, ServiceTask, QFilterCondition> {}

extension ServiceTaskQuerySortBy
    on QueryBuilder<ServiceTask, ServiceTask, QSortBy> {
  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> sortByDisplayNameAr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayNameAr', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy>
      sortByDisplayNameArDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayNameAr', Sort.desc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> sortByDisplayNameEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayNameEn', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy>
      sortByDisplayNameEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayNameEn', Sort.desc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> sortByIntervalKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalKm', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> sortByIntervalKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalKm', Sort.desc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> sortByIntervalMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalMonths', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy>
      sortByIntervalMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalMonths', Sort.desc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> sortByLastDoneDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDoneDate', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy>
      sortByLastDoneDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDoneDate', Sort.desc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> sortByLastDoneKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDoneKm', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> sortByLastDoneKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDoneKm', Sort.desc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> sortByTaskKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskKey', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> sortByTaskKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskKey', Sort.desc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> sortByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> sortByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }
}

extension ServiceTaskQuerySortThenBy
    on QueryBuilder<ServiceTask, ServiceTask, QSortThenBy> {
  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> thenByDisplayNameAr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayNameAr', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy>
      thenByDisplayNameArDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayNameAr', Sort.desc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> thenByDisplayNameEn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayNameEn', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy>
      thenByDisplayNameEnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayNameEn', Sort.desc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> thenByIntervalKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalKm', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> thenByIntervalKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalKm', Sort.desc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> thenByIntervalMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalMonths', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy>
      thenByIntervalMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intervalMonths', Sort.desc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> thenByLastDoneDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDoneDate', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy>
      thenByLastDoneDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDoneDate', Sort.desc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> thenByLastDoneKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDoneKm', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> thenByLastDoneKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastDoneKm', Sort.desc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> thenByTaskKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskKey', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> thenByTaskKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskKey', Sort.desc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> thenByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.asc);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QAfterSortBy> thenByVehicleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleId', Sort.desc);
    });
  }
}

extension ServiceTaskQueryWhereDistinct
    on QueryBuilder<ServiceTask, ServiceTask, QDistinct> {
  QueryBuilder<ServiceTask, ServiceTask, QDistinct> distinctByDisplayNameAr(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayNameAr',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QDistinct> distinctByDisplayNameEn(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayNameEn',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QDistinct> distinctByIntervalKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'intervalKm');
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QDistinct> distinctByIntervalMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'intervalMonths');
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QDistinct> distinctByLastDoneDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastDoneDate');
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QDistinct> distinctByLastDoneKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastDoneKm');
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QDistinct> distinctByTaskKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ServiceTask, ServiceTask, QDistinct> distinctByVehicleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleId');
    });
  }
}

extension ServiceTaskQueryProperty
    on QueryBuilder<ServiceTask, ServiceTask, QQueryProperty> {
  QueryBuilder<ServiceTask, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ServiceTask, String, QQueryOperations> displayNameArProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayNameAr');
    });
  }

  QueryBuilder<ServiceTask, String, QQueryOperations> displayNameEnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayNameEn');
    });
  }

  QueryBuilder<ServiceTask, int?, QQueryOperations> intervalKmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'intervalKm');
    });
  }

  QueryBuilder<ServiceTask, int?, QQueryOperations> intervalMonthsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'intervalMonths');
    });
  }

  QueryBuilder<ServiceTask, DateTime?, QQueryOperations>
      lastDoneDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastDoneDate');
    });
  }

  QueryBuilder<ServiceTask, int?, QQueryOperations> lastDoneKmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastDoneKm');
    });
  }

  QueryBuilder<ServiceTask, String, QQueryOperations> taskKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskKey');
    });
  }

  QueryBuilder<ServiceTask, int, QQueryOperations> vehicleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleId');
    });
  }
}
