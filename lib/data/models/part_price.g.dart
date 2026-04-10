// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part_price.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPartPriceCollection on Isar {
  IsarCollection<PartPrice> get partPrices => this.collection();
}

const PartPriceSchema = CollectionSchema(
  name: r'PartPrice',
  id: 7819396587551419847,
  properties: {
    r'installedAtKm': PropertySchema(
      id: 0,
      name: r'installedAtKm',
      type: IsarType.long,
    ),
    r'isSynced': PropertySchema(
      id: 1,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'partName': PropertySchema(
      id: 2,
      name: r'partName',
      type: IsarType.string,
    ),
    r'priceSar': PropertySchema(
      id: 3,
      name: r'priceSar',
      type: IsarType.double,
    ),
    r'providerName': PropertySchema(
      id: 4,
      name: r'providerName',
      type: IsarType.string,
    ),
    r'recordedAt': PropertySchema(
      id: 5,
      name: r'recordedAt',
      type: IsarType.dateTime,
    ),
    r'region': PropertySchema(
      id: 6,
      name: r'region',
      type: IsarType.string,
    ),
    r'source': PropertySchema(
      id: 7,
      name: r'source',
      type: IsarType.byte,
      enumMap: _PartPricesourceEnumValueMap,
    )
  },
  estimateSize: _partPriceEstimateSize,
  serialize: _partPriceSerialize,
  deserialize: _partPriceDeserialize,
  deserializeProp: _partPriceDeserializeProp,
  idName: r'id',
  indexes: {
    r'partName': IndexSchema(
      id: 3257575486934960022,
      name: r'partName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'partName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _partPriceGetId,
  getLinks: _partPriceGetLinks,
  attach: _partPriceAttach,
  version: '3.1.0+1',
);

int _partPriceEstimateSize(
  PartPrice object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.partName.length * 3;
  {
    final value = object.providerName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.region;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _partPriceSerialize(
  PartPrice object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.installedAtKm);
  writer.writeBool(offsets[1], object.isSynced);
  writer.writeString(offsets[2], object.partName);
  writer.writeDouble(offsets[3], object.priceSar);
  writer.writeString(offsets[4], object.providerName);
  writer.writeDateTime(offsets[5], object.recordedAt);
  writer.writeString(offsets[6], object.region);
  writer.writeByte(offsets[7], object.source.index);
}

PartPrice _partPriceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PartPrice(
    id: id,
    installedAtKm: reader.readLongOrNull(offsets[0]),
    isSynced: reader.readBoolOrNull(offsets[1]) ?? false,
    partName: reader.readString(offsets[2]),
    priceSar: reader.readDouble(offsets[3]),
    providerName: reader.readStringOrNull(offsets[4]),
    recordedAt: reader.readDateTime(offsets[5]),
    region: reader.readStringOrNull(offsets[6]),
    source: _PartPricesourceValueEnumMap[reader.readByteOrNull(offsets[7])] ??
        PriceSource.manual,
  );
  return object;
}

P _partPriceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (_PartPricesourceValueEnumMap[reader.readByteOrNull(offset)] ??
          PriceSource.manual) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PartPricesourceEnumValueMap = {
  'manual': 0,
  'telemetry': 1,
};
const _PartPricesourceValueEnumMap = {
  0: PriceSource.manual,
  1: PriceSource.telemetry,
};

Id _partPriceGetId(PartPrice object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _partPriceGetLinks(PartPrice object) {
  return [];
}

void _partPriceAttach(IsarCollection<dynamic> col, Id id, PartPrice object) {
  object.id = id;
}

extension PartPriceQueryWhereSort
    on QueryBuilder<PartPrice, PartPrice, QWhere> {
  QueryBuilder<PartPrice, PartPrice, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PartPriceQueryWhere
    on QueryBuilder<PartPrice, PartPrice, QWhereClause> {
  QueryBuilder<PartPrice, PartPrice, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PartPrice, PartPrice, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterWhereClause> idBetween(
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

  QueryBuilder<PartPrice, PartPrice, QAfterWhereClause> partNameEqualTo(
      String partName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'partName',
        value: [partName],
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterWhereClause> partNameNotEqualTo(
      String partName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'partName',
              lower: [],
              upper: [partName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'partName',
              lower: [partName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'partName',
              lower: [partName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'partName',
              lower: [],
              upper: [partName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PartPriceQueryFilter
    on QueryBuilder<PartPrice, PartPrice, QFilterCondition> {
  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
      installedAtKmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'installedAtKm',
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
      installedAtKmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'installedAtKm',
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
      installedAtKmEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'installedAtKm',
        value: value,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
      installedAtKmGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'installedAtKm',
        value: value,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
      installedAtKmLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'installedAtKm',
        value: value,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
      installedAtKmBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'installedAtKm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> isSyncedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> partNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> partNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'partName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> partNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'partName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> partNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'partName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> partNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'partName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> partNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'partName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> partNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'partName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> partNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'partName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> partNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partName',
        value: '',
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
      partNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'partName',
        value: '',
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> priceSarEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priceSar',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> priceSarGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priceSar',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> priceSarLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priceSar',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> priceSarBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priceSar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
      providerNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'providerName',
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
      providerNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'providerName',
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> providerNameEqualTo(
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

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
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

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
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

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> providerNameBetween(
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

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
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

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
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

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
      providerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'providerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> providerNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'providerName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
      providerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerName',
        value: '',
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
      providerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'providerName',
        value: '',
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> recordedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition>
      recordedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> recordedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> recordedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recordedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> regionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'region',
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> regionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'region',
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> regionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> regionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> regionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> regionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'region',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> regionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> regionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> regionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> regionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'region',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> regionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'region',
        value: '',
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> regionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'region',
        value: '',
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> sourceEqualTo(
      PriceSource value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> sourceGreaterThan(
    PriceSource value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> sourceLessThan(
    PriceSource value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
      ));
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterFilterCondition> sourceBetween(
    PriceSource lower,
    PriceSource upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PartPriceQueryObject
    on QueryBuilder<PartPrice, PartPrice, QFilterCondition> {}

extension PartPriceQueryLinks
    on QueryBuilder<PartPrice, PartPrice, QFilterCondition> {}

extension PartPriceQuerySortBy on QueryBuilder<PartPrice, PartPrice, QSortBy> {
  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> sortByInstalledAtKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installedAtKm', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> sortByInstalledAtKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installedAtKm', Sort.desc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> sortByPartName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partName', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> sortByPartNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partName', Sort.desc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> sortByPriceSar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceSar', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> sortByPriceSarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceSar', Sort.desc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> sortByProviderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> sortByProviderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.desc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> sortByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> sortByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> sortByRegion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'region', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> sortByRegionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'region', Sort.desc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }
}

extension PartPriceQuerySortThenBy
    on QueryBuilder<PartPrice, PartPrice, QSortThenBy> {
  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenByInstalledAtKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installedAtKm', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenByInstalledAtKmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'installedAtKm', Sort.desc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenByPartName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partName', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenByPartNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partName', Sort.desc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenByPriceSar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceSar', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenByPriceSarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priceSar', Sort.desc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenByProviderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenByProviderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerName', Sort.desc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenByRegion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'region', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenByRegionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'region', Sort.desc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }
}

extension PartPriceQueryWhereDistinct
    on QueryBuilder<PartPrice, PartPrice, QDistinct> {
  QueryBuilder<PartPrice, PartPrice, QDistinct> distinctByInstalledAtKm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'installedAtKm');
    });
  }

  QueryBuilder<PartPrice, PartPrice, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<PartPrice, PartPrice, QDistinct> distinctByPartName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'partName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QDistinct> distinctByPriceSar() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priceSar');
    });
  }

  QueryBuilder<PartPrice, PartPrice, QDistinct> distinctByProviderName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QDistinct> distinctByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordedAt');
    });
  }

  QueryBuilder<PartPrice, PartPrice, QDistinct> distinctByRegion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'region', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PartPrice, PartPrice, QDistinct> distinctBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source');
    });
  }
}

extension PartPriceQueryProperty
    on QueryBuilder<PartPrice, PartPrice, QQueryProperty> {
  QueryBuilder<PartPrice, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PartPrice, int?, QQueryOperations> installedAtKmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'installedAtKm');
    });
  }

  QueryBuilder<PartPrice, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<PartPrice, String, QQueryOperations> partNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'partName');
    });
  }

  QueryBuilder<PartPrice, double, QQueryOperations> priceSarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priceSar');
    });
  }

  QueryBuilder<PartPrice, String?, QQueryOperations> providerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerName');
    });
  }

  QueryBuilder<PartPrice, DateTime, QQueryOperations> recordedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordedAt');
    });
  }

  QueryBuilder<PartPrice, String?, QQueryOperations> regionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'region');
    });
  }

  QueryBuilder<PartPrice, PriceSource, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }
}
