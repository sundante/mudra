// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_holding.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInvestmentHoldingCollection on Isar {
  IsarCollection<InvestmentHolding> get investmentHoldings => this.collection();
}

const InvestmentHoldingSchema = CollectionSchema(
  name: r'InvestmentHolding',
  id: -1064032041583848995,
  properties: {
    r'assetType': PropertySchema(
      id: 0,
      name: r'assetType',
      type: IsarType.byte,
      enumMap: _InvestmentHoldingassetTypeEnumValueMap,
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
    r'platformId': PropertySchema(
      id: 4,
      name: r'platformId',
      type: IsarType.long,
    ),
    r'schemeName': PropertySchema(
      id: 5,
      name: r'schemeName',
      type: IsarType.string,
    ),
    r'uid': PropertySchema(
      id: 6,
      name: r'uid',
      type: IsarType.string,
    ),
    r'units': PropertySchema(
      id: 7,
      name: r'units',
      type: IsarType.double,
    )
  },
  estimateSize: _investmentHoldingEstimateSize,
  serialize: _investmentHoldingSerialize,
  deserialize: _investmentHoldingDeserialize,
  deserializeProp: _investmentHoldingDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _investmentHoldingGetId,
  getLinks: _investmentHoldingGetLinks,
  attach: _investmentHoldingAttach,
  version: '3.1.0+1',
);

int _investmentHoldingEstimateSize(
  InvestmentHolding object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.schemeName.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _investmentHoldingSerialize(
  InvestmentHolding object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.assetType.index);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDouble(offsets[2], object.currentValue);
  writer.writeDouble(offsets[3], object.investedAmount);
  writer.writeLong(offsets[4], object.platformId);
  writer.writeString(offsets[5], object.schemeName);
  writer.writeString(offsets[6], object.uid);
  writer.writeDouble(offsets[7], object.units);
}

InvestmentHolding _investmentHoldingDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InvestmentHolding();
  object.assetType = _InvestmentHoldingassetTypeValueEnumMap[
          reader.readByteOrNull(offsets[0])] ??
      AssetType.indianStocks;
  object.createdAt = reader.readDateTime(offsets[1]);
  object.currentValue = reader.readDouble(offsets[2]);
  object.id = id;
  object.investedAmount = reader.readDouble(offsets[3]);
  object.platformId = reader.readLong(offsets[4]);
  object.schemeName = reader.readString(offsets[5]);
  object.uid = reader.readString(offsets[6]);
  object.units = reader.readDouble(offsets[7]);
  return object;
}

P _investmentHoldingDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_InvestmentHoldingassetTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          AssetType.indianStocks) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _InvestmentHoldingassetTypeEnumValueMap = {
  'indianStocks': 0,
  'usStocks': 1,
  'mutualFund': 2,
  'ppf': 3,
  'epf': 4,
  'nps': 5,
  'gold': 6,
  'other': 7,
};
const _InvestmentHoldingassetTypeValueEnumMap = {
  0: AssetType.indianStocks,
  1: AssetType.usStocks,
  2: AssetType.mutualFund,
  3: AssetType.ppf,
  4: AssetType.epf,
  5: AssetType.nps,
  6: AssetType.gold,
  7: AssetType.other,
};

Id _investmentHoldingGetId(InvestmentHolding object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _investmentHoldingGetLinks(
    InvestmentHolding object) {
  return [];
}

void _investmentHoldingAttach(
    IsarCollection<dynamic> col, Id id, InvestmentHolding object) {
  object.id = id;
}

extension InvestmentHoldingQueryWhereSort
    on QueryBuilder<InvestmentHolding, InvestmentHolding, QWhere> {
  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InvestmentHoldingQueryWhere
    on QueryBuilder<InvestmentHolding, InvestmentHolding, QWhereClause> {
  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterWhereClause>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterWhereClause>
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

extension InvestmentHoldingQueryFilter
    on QueryBuilder<InvestmentHolding, InvestmentHolding, QFilterCondition> {
  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      assetTypeEqualTo(AssetType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetType',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      platformIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'platformId',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      platformIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'platformId',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      platformIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'platformId',
        value: value,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      platformIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'platformId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      schemeNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      schemeNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schemeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      schemeNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schemeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      schemeNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schemeName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      schemeNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'schemeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      schemeNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'schemeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      schemeNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schemeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      schemeNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schemeName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      schemeNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemeName',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      schemeNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schemeName',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
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

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      uidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      uidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      unitsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'units',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      unitsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'units',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      unitsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'units',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterFilterCondition>
      unitsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'units',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension InvestmentHoldingQueryObject
    on QueryBuilder<InvestmentHolding, InvestmentHolding, QFilterCondition> {}

extension InvestmentHoldingQueryLinks
    on QueryBuilder<InvestmentHolding, InvestmentHolding, QFilterCondition> {}

extension InvestmentHoldingQuerySortBy
    on QueryBuilder<InvestmentHolding, InvestmentHolding, QSortBy> {
  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      sortByAssetType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetType', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      sortByAssetTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetType', Sort.desc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      sortByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      sortByCurrentValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.desc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      sortByInvestedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedAmount', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      sortByInvestedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedAmount', Sort.desc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      sortByPlatformId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platformId', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      sortByPlatformIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platformId', Sort.desc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      sortBySchemeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemeName', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      sortBySchemeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemeName', Sort.desc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      sortByUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'units', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      sortByUnitsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'units', Sort.desc);
    });
  }
}

extension InvestmentHoldingQuerySortThenBy
    on QueryBuilder<InvestmentHolding, InvestmentHolding, QSortThenBy> {
  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      thenByAssetType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetType', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      thenByAssetTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetType', Sort.desc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      thenByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      thenByCurrentValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentValue', Sort.desc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      thenByInvestedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedAmount', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      thenByInvestedAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'investedAmount', Sort.desc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      thenByPlatformId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platformId', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      thenByPlatformIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platformId', Sort.desc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      thenBySchemeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemeName', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      thenBySchemeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemeName', Sort.desc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      thenByUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'units', Sort.asc);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QAfterSortBy>
      thenByUnitsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'units', Sort.desc);
    });
  }
}

extension InvestmentHoldingQueryWhereDistinct
    on QueryBuilder<InvestmentHolding, InvestmentHolding, QDistinct> {
  QueryBuilder<InvestmentHolding, InvestmentHolding, QDistinct>
      distinctByAssetType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetType');
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QDistinct>
      distinctByCurrentValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentValue');
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QDistinct>
      distinctByInvestedAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'investedAmount');
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QDistinct>
      distinctByPlatformId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'platformId');
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QDistinct>
      distinctBySchemeName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemeName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InvestmentHolding, InvestmentHolding, QDistinct>
      distinctByUnits() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'units');
    });
  }
}

extension InvestmentHoldingQueryProperty
    on QueryBuilder<InvestmentHolding, InvestmentHolding, QQueryProperty> {
  QueryBuilder<InvestmentHolding, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InvestmentHolding, AssetType, QQueryOperations>
      assetTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetType');
    });
  }

  QueryBuilder<InvestmentHolding, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<InvestmentHolding, double, QQueryOperations>
      currentValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentValue');
    });
  }

  QueryBuilder<InvestmentHolding, double, QQueryOperations>
      investedAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'investedAmount');
    });
  }

  QueryBuilder<InvestmentHolding, int, QQueryOperations> platformIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'platformId');
    });
  }

  QueryBuilder<InvestmentHolding, String, QQueryOperations>
      schemeNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemeName');
    });
  }

  QueryBuilder<InvestmentHolding, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<InvestmentHolding, double, QQueryOperations> unitsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'units');
    });
  }
}
