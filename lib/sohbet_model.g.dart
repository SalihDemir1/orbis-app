// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sohbet_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSohbetMesajiCollection on Isar {
  IsarCollection<SohbetMesaji> get sohbetMesajis => this.collection();
}

const SohbetMesajiSchema = CollectionSchema(
  name: r'SohbetMesaji',
  id: 6698980603612614963,
  properties: {
    r'asistanMi': PropertySchema(
      id: 0,
      name: r'asistanMi',
      type: IsarType.bool,
    ),
    r'baslik': PropertySchema(
      id: 1,
      name: r'baslik',
      type: IsarType.string,
    ),
    r'metin': PropertySchema(
      id: 2,
      name: r'metin',
      type: IsarType.string,
    ),
    r'sessionId': PropertySchema(
      id: 3,
      name: r'sessionId',
      type: IsarType.string,
    ),
    r'tarih': PropertySchema(
      id: 4,
      name: r'tarih',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _sohbetMesajiEstimateSize,
  serialize: _sohbetMesajiSerialize,
  deserialize: _sohbetMesajiDeserialize,
  deserializeProp: _sohbetMesajiDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _sohbetMesajiGetId,
  getLinks: _sohbetMesajiGetLinks,
  attach: _sohbetMesajiAttach,
  version: '3.1.0+1',
);

int _sohbetMesajiEstimateSize(
  SohbetMesaji object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.baslik;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.metin.length * 3;
  {
    final value = object.sessionId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _sohbetMesajiSerialize(
  SohbetMesaji object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.asistanMi);
  writer.writeString(offsets[1], object.baslik);
  writer.writeString(offsets[2], object.metin);
  writer.writeString(offsets[3], object.sessionId);
  writer.writeDateTime(offsets[4], object.tarih);
}

SohbetMesaji _sohbetMesajiDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SohbetMesaji();
  object.asistanMi = reader.readBool(offsets[0]);
  object.baslik = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.metin = reader.readString(offsets[2]);
  object.sessionId = reader.readStringOrNull(offsets[3]);
  object.tarih = reader.readDateTime(offsets[4]);
  return object;
}

P _sohbetMesajiDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sohbetMesajiGetId(SohbetMesaji object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sohbetMesajiGetLinks(SohbetMesaji object) {
  return [];
}

void _sohbetMesajiAttach(
    IsarCollection<dynamic> col, Id id, SohbetMesaji object) {
  object.id = id;
}

extension SohbetMesajiQueryWhereSort
    on QueryBuilder<SohbetMesaji, SohbetMesaji, QWhere> {
  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SohbetMesajiQueryWhere
    on QueryBuilder<SohbetMesaji, SohbetMesaji, QWhereClause> {
  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterWhereClause> idBetween(
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

extension SohbetMesajiQueryFilter
    on QueryBuilder<SohbetMesaji, SohbetMesaji, QFilterCondition> {
  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      asistanMiEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'asistanMi',
        value: value,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      baslikIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'baslik',
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      baslikIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'baslik',
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition> baslikEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baslik',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      baslikGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baslik',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      baslikLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baslik',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition> baslikBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baslik',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      baslikStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'baslik',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      baslikEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'baslik',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      baslikContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'baslik',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition> baslikMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'baslik',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      baslikIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baslik',
        value: '',
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      baslikIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'baslik',
        value: '',
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition> metinEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      metinGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition> metinLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition> metinBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      metinStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition> metinEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition> metinContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition> metinMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metin',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      metinIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metin',
        value: '',
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      metinIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metin',
        value: '',
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      sessionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sessionId',
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      sessionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sessionId',
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      sessionIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      sessionIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      sessionIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      sessionIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      sessionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      sessionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      sessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      sessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sessionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition> tarihEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tarih',
        value: value,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition>
      tarihGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tarih',
        value: value,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition> tarihLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tarih',
        value: value,
      ));
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterFilterCondition> tarihBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tarih',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SohbetMesajiQueryObject
    on QueryBuilder<SohbetMesaji, SohbetMesaji, QFilterCondition> {}

extension SohbetMesajiQueryLinks
    on QueryBuilder<SohbetMesaji, SohbetMesaji, QFilterCondition> {}

extension SohbetMesajiQuerySortBy
    on QueryBuilder<SohbetMesaji, SohbetMesaji, QSortBy> {
  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> sortByAsistanMi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asistanMi', Sort.asc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> sortByAsistanMiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asistanMi', Sort.desc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> sortByBaslik() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baslik', Sort.asc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> sortByBaslikDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baslik', Sort.desc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> sortByMetin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metin', Sort.asc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> sortByMetinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metin', Sort.desc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> sortByTarih() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tarih', Sort.asc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> sortByTarihDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tarih', Sort.desc);
    });
  }
}

extension SohbetMesajiQuerySortThenBy
    on QueryBuilder<SohbetMesaji, SohbetMesaji, QSortThenBy> {
  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> thenByAsistanMi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asistanMi', Sort.asc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> thenByAsistanMiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asistanMi', Sort.desc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> thenByBaslik() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baslik', Sort.asc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> thenByBaslikDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baslik', Sort.desc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> thenByMetin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metin', Sort.asc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> thenByMetinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metin', Sort.desc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> thenByTarih() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tarih', Sort.asc);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QAfterSortBy> thenByTarihDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tarih', Sort.desc);
    });
  }
}

extension SohbetMesajiQueryWhereDistinct
    on QueryBuilder<SohbetMesaji, SohbetMesaji, QDistinct> {
  QueryBuilder<SohbetMesaji, SohbetMesaji, QDistinct> distinctByAsistanMi() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'asistanMi');
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QDistinct> distinctByBaslik(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baslik', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QDistinct> distinctByMetin(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metin', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QDistinct> distinctBySessionId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SohbetMesaji, SohbetMesaji, QDistinct> distinctByTarih() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tarih');
    });
  }
}

extension SohbetMesajiQueryProperty
    on QueryBuilder<SohbetMesaji, SohbetMesaji, QQueryProperty> {
  QueryBuilder<SohbetMesaji, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SohbetMesaji, bool, QQueryOperations> asistanMiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'asistanMi');
    });
  }

  QueryBuilder<SohbetMesaji, String?, QQueryOperations> baslikProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baslik');
    });
  }

  QueryBuilder<SohbetMesaji, String, QQueryOperations> metinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metin');
    });
  }

  QueryBuilder<SohbetMesaji, String?, QQueryOperations> sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<SohbetMesaji, DateTime, QQueryOperations> tarihProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tarih');
    });
  }
}
