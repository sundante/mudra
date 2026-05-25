// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_platform.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInvestmentPlatformCollection on Isar {
  IsarCollection<InvestmentPlatform> get investmentPlatforms =>
      this.collection();
}

const InvestmentPlatformSchema = CollectionSchema(
  name: r'InvestmentPlatform',
  id: 6690291655780326067,
  properties: {
    r'assetType': PropertySchema(
      id: 0,
      name: r'assetType',
      type: IsarType.byte,
      enumMap: _InvestmentPlatformassetTypeEnumValueMap,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'currentValue': PropertySchema(
      id: 2,
      name: r'currentValue',
      type: IsarType.double,
    ),
    r'investedAmount': PropertySchema(
      id: 3,
      name: r'investedAmount',
      type: IsarType.double,
    ),
    r'isDeleted': PropertySchema(
      id: 4,
      name: r'isDeleted',
      type: IsarType.bool,
    ),
    r'platformName': PropertySchema(
      id: 5,
      name: r'platformName',
      type: IsarType.string,
    ),
    r'uid': PropertySchema(
      id: 6,
      name: r'uid',
      type: IsarType.string,
    ),
    r'valueUpdatedAt': PropertySchema(
      id: 7,
      name: r'valueUpdatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _investmentPlatformEstimateSize,
  serialize: _investmentPlatformSerialize,
  deserialize: _investmentPlatformDeserialize,
  deserializeProp: _investmentPlatformDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _investmentPlatformGetId,
  getLinks: _investmentPlatformGetLinks,
  attach: _investmentPlatformAttach,
  version: '3.1.0+1',
);

int _investmentPlatformEstimateSize(
  InvestmentPlatform object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.platformName.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _investmentPlatformSerialize(
  InvestmentPlatform object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.assetType.index);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDouble(offsets[2], object.currentValue);
  writer.writeDouble(offsets[3], object.investedAmount);
  writer.writeBool(offsets[4], object.isDeleted);
  writer.writeString(offsets[5], object.platformName);
  writer.writeString(offsets[6], object.uid);
  writer.writeDateTime(offsets[7], object.valueUpdatedAt);
}

InvestmentPlatform _investmentPlatformDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InvestmentPlatform();
  object.assetType = _InvestmentPlatformassetTypeValueEnumMap[
          reader.readByteOrNull(offsets[0])] ??
      AssetType.indianStocks;
  object.createdAt = reader.readDateTime(offsets[1]);
  object.currentValue = reader.readDouble(offsets[2]);
  object.id = id;
  object.investedAmount = reader.readDouble(offsets[3]);
  object.isDeleted = reader.readBool(offsets[4]);
  object.platformName = reader.readString(offsets[5]);
  object.uid = reader.readString(offsets[6]);
  object.valueUpdatedAt = reader.readDateTimeOrNull(offsets[7]);
  return object;
}

P _investmentPlatformDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_InvestmentPlatformassetTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          AssetType.indianStocks) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _InvestmentPlatformassetTypeEnumValueMap = {
  'indianStocks': 0,
  'usStocks': 1,
  'mutualFund': 2,
  'ppf': 3,
  'epf': 4,
  'nps': 5,
  'gold': 6,
  'other': 7,
};
const _InvestmentPlatformassetTypeValueEnumMap = {
  0: AssetType.indianStocks,
  1: AssetType.usStocks,
  2: AssetType.mutualFund,
  3: AssetType.ppf,
  4: AssetType.epf,
  5: AssetType.nps,
  6: AssetType.gold,
  7: AssetType.other,
};

Id _investmentPlatformGetId(InvestmentPlatform object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _investmentPlatformGetLinks(
    InvestmentPlatform object) {
  return [];
}

void _investmentPlatformAttach(
    IsarCollection<dynamic> col, Id id, InvestmentPlatform object) {
  object.id = id;
}

extension InvestmentPlatformQueryWhereSort
    on QueryBuilder<InvestmentPlatform, InvestmentPlatform, QWhere> {
  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InvestmentPlatformQueryWhere
    on QueryBuilder<InvestmentPlatform, InvestmentPlatform, QWhereClause> {
  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterWhereClause>
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

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterWhereClause>
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
}

extension InvestmentPlatformQueryFilter
    on QueryBuilder<InvestmentPlatform, InvestmentPlatform, QFilterCondition> {
  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      assetTypeEqualTo(AssetType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetType',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      assetTypeGreaterThan(
    AssetType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assetType',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      assetTypeLessThan(
    AssetType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assetType',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      assetTypeBetween(
    AssetType lower,
    AssetType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assetType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
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

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
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

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
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

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      currentValueEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      currentValueGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      currentValueLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      currentValueBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
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

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
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

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
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

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      investedAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'investedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      investedAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'investedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      investedAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'investedAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      investedAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'investedAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      isDeletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDeleted',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      platformNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'platformName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      platformNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'platformName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      platformNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'platformName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      platformNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'platformName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      platformNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'platformName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      platformNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'platformName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      platformNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'platformName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      platformNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'platformName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      platformNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'platformName',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      platformNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'platformName',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      uidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      uidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      valueUpdatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'valueUpdatedAt',
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      valueUpdatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'valueUpdatedAt',
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      valueUpdatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'valueUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      valueUpdatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'valueUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      valueUpdatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'valueUpdatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterFilterCondition>
      valueUpdatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'valueUpdatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension InvestmentPlatformQueryObject
    on QueryBuilder<InvestmentPlatform, InvestmentPlatform, QFilterCondition> {}

extension InvestmentPlatformQueryLinks
    on QueryBuilder<InvestmentPlatform, InvestmentPlatform, QFilterCondition> {}

extension InvestmentPlatformQuerySortBy
    on QueryBuilder<InvestmentPlatform, InvestmentPlatform, QSortBy> {
  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      sortByAssetType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetType', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      sortByAssetTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetType', Sort.desc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      sortByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      sortByCurrentValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.desc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      sortByInvestedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedAmount', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      sortByInvestedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedAmount', Sort.desc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      sortByPlatformName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platformName', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      sortByPlatformNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platformName', Sort.desc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      sortByValueUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valueUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      sortByValueUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valueUpdatedAt', Sort.desc);
    });
  }
}

extension InvestmentPlatformQuerySortThenBy
    on QueryBuilder<InvestmentPlatform, InvestmentPlatform, QSortThenBy> {
  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByAssetType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetType', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByAssetTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetType', Sort.desc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByCurrentValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.desc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByInvestedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedAmount', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByInvestedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedAmount', Sort.desc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDeleted', Sort.desc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByPlatformName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platformName', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByPlatformNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platformName', Sort.desc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByValueUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valueUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QAfterSortBy>
      thenByValueUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valueUpdatedAt', Sort.desc);
    });
  }
}

extension InvestmentPlatformQueryWhereDistinct
    on QueryBuilder<InvestmentPlatform, InvestmentPlatform, QDistinct> {
  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QDistinct>
      distinctByAssetType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetType');
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QDistinct>
      distinctByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentValue');
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QDistinct>
      distinctByInvestedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'investedAmount');
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDeleted');
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QDistinct>
      distinctByPlatformName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'platformName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InvestmentPlatform, InvestmentPlatform, QDistinct>
      distinctByValueUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'valueUpdatedAt');
    });
  }
}

extension InvestmentPlatformQueryProperty
    on QueryBuilder<InvestmentPlatform, InvestmentPlatform, QQueryProperty> {
  QueryBuilder<InvestmentPlatform, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InvestmentPlatform, AssetType, QQueryOperations>
      assetTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetType');
    });
  }

  QueryBuilder<InvestmentPlatform, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<InvestmentPlatform, double, QQueryOperations>
      currentValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentValue');
    });
  }

  QueryBuilder<InvestmentPlatform, double, QQueryOperations>
      investedAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'investedAmount');
    });
  }

  QueryBuilder<InvestmentPlatform, bool, QQueryOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDeleted');
    });
  }

  QueryBuilder<InvestmentPlatform, String, QQueryOperations>
      platformNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'platformName');
    });
  }

  QueryBuilder<InvestmentPlatform, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<InvestmentPlatform, DateTime?, QQueryOperations>
      valueUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'valueUpdatedAt');
    });
  }
}
