// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_local.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPatientLocalCollection on Isar {
  IsarCollection<PatientLocal> get patientLocals => this.collection();
}

const PatientLocalSchema = CollectionSchema(
  name: r'PatientLocal',
  id: -4316181317897838463,
  properties: {
    r'cognitiveDeclineAlert': PropertySchema(
      id: 0,
      name: r'cognitiveDeclineAlert',
      type: IsarType.bool,
    ),
    r'displayName': PropertySchema(
      id: 1,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'lastRoutineAt': PropertySchema(
      id: 2,
      name: r'lastRoutineAt',
      type: IsarType.dateTime,
    ),
    r'missedRoutineToday': PropertySchema(
      id: 3,
      name: r'missedRoutineToday',
      type: IsarType.bool,
    ),
    r'patientId': PropertySchema(
      id: 4,
      name: r'patientId',
      type: IsarType.string,
    ),
    r'photoPath': PropertySchema(
      id: 5,
      name: r'photoPath',
      type: IsarType.string,
    ),
    r'routineCompliance': PropertySchema(
      id: 6,
      name: r'routineCompliance',
      type: IsarType.double,
    ),
    r'status': PropertySchema(
      id: 7,
      name: r'status',
      type: IsarType.byte,
      enumMap: _PatientLocalstatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 8,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _patientLocalEstimateSize,
  serialize: _patientLocalSerialize,
  deserialize: _patientLocalDeserialize,
  deserializeProp: _patientLocalDeserializeProp,
  idName: r'id',
  indexes: {
    r'patientId': IndexSchema(
      id: 403389457658259617,
      name: r'patientId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'patientId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _patientLocalGetId,
  getLinks: _patientLocalGetLinks,
  attach: _patientLocalAttach,
  version: '3.1.0+1',
);

int _patientLocalEstimateSize(
  PatientLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.displayName.length * 3;
  bytesCount += 3 + object.patientId.length * 3;
  {
    final value = object.photoPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _patientLocalSerialize(
  PatientLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.cognitiveDeclineAlert);
  writer.writeString(offsets[1], object.displayName);
  writer.writeDateTime(offsets[2], object.lastRoutineAt);
  writer.writeBool(offsets[3], object.missedRoutineToday);
  writer.writeString(offsets[4], object.patientId);
  writer.writeString(offsets[5], object.photoPath);
  writer.writeDouble(offsets[6], object.routineCompliance);
  writer.writeByte(offsets[7], object.status.index);
  writer.writeDateTime(offsets[8], object.updatedAt);
}

PatientLocal _patientLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PatientLocal();
  object.cognitiveDeclineAlert = reader.readBool(offsets[0]);
  object.displayName = reader.readString(offsets[1]);
  object.id = id;
  object.lastRoutineAt = reader.readDateTimeOrNull(offsets[2]);
  object.missedRoutineToday = reader.readBool(offsets[3]);
  object.patientId = reader.readString(offsets[4]);
  object.photoPath = reader.readStringOrNull(offsets[5]);
  object.routineCompliance = reader.readDouble(offsets[6]);
  object.status =
      _PatientLocalstatusValueEnumMap[reader.readByteOrNull(offsets[7])] ??
          PatientStatus.ok;
  object.updatedAt = reader.readDateTime(offsets[8]);
  return object;
}

P _patientLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (_PatientLocalstatusValueEnumMap[reader.readByteOrNull(offset)] ??
          PatientStatus.ok) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PatientLocalstatusEnumValueMap = {
  'ok': 0,
  'warning': 1,
  'alert': 2,
};
const _PatientLocalstatusValueEnumMap = {
  0: PatientStatus.ok,
  1: PatientStatus.warning,
  2: PatientStatus.alert,
};

Id _patientLocalGetId(PatientLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _patientLocalGetLinks(PatientLocal object) {
  return [];
}

void _patientLocalAttach(
    IsarCollection<dynamic> col, Id id, PatientLocal object) {
  object.id = id;
}

extension PatientLocalByIndex on IsarCollection<PatientLocal> {
  Future<PatientLocal?> getByPatientId(String patientId) {
    return getByIndex(r'patientId', [patientId]);
  }

  PatientLocal? getByPatientIdSync(String patientId) {
    return getByIndexSync(r'patientId', [patientId]);
  }

  Future<bool> deleteByPatientId(String patientId) {
    return deleteByIndex(r'patientId', [patientId]);
  }

  bool deleteByPatientIdSync(String patientId) {
    return deleteByIndexSync(r'patientId', [patientId]);
  }

  Future<List<PatientLocal?>> getAllByPatientId(List<String> patientIdValues) {
    final values = patientIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'patientId', values);
  }

  List<PatientLocal?> getAllByPatientIdSync(List<String> patientIdValues) {
    final values = patientIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'patientId', values);
  }

  Future<int> deleteAllByPatientId(List<String> patientIdValues) {
    final values = patientIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'patientId', values);
  }

  int deleteAllByPatientIdSync(List<String> patientIdValues) {
    final values = patientIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'patientId', values);
  }

  Future<Id> putByPatientId(PatientLocal object) {
    return putByIndex(r'patientId', object);
  }

  Id putByPatientIdSync(PatientLocal object, {bool saveLinks = true}) {
    return putByIndexSync(r'patientId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPatientId(List<PatientLocal> objects) {
    return putAllByIndex(r'patientId', objects);
  }

  List<Id> putAllByPatientIdSync(List<PatientLocal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'patientId', objects, saveLinks: saveLinks);
  }
}

extension PatientLocalQueryWhereSort
    on QueryBuilder<PatientLocal, PatientLocal, QWhere> {
  QueryBuilder<PatientLocal, PatientLocal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PatientLocalQueryWhere
    on QueryBuilder<PatientLocal, PatientLocal, QWhereClause> {
  QueryBuilder<PatientLocal, PatientLocal, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PatientLocal, PatientLocal, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterWhereClause> idBetween(
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

  QueryBuilder<PatientLocal, PatientLocal, QAfterWhereClause> patientIdEqualTo(
      String patientId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'patientId',
        value: [patientId],
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterWhereClause>
      patientIdNotEqualTo(String patientId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'patientId',
              lower: [],
              upper: [patientId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'patientId',
              lower: [patientId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'patientId',
              lower: [patientId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'patientId',
              lower: [],
              upper: [patientId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PatientLocalQueryFilter
    on QueryBuilder<PatientLocal, PatientLocal, QFilterCondition> {
  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      cognitiveDeclineAlertEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cognitiveDeclineAlert',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      displayNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      displayNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      displayNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      displayNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      displayNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      displayNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      displayNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      displayNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      lastRoutineAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastRoutineAt',
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      lastRoutineAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastRoutineAt',
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      lastRoutineAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastRoutineAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      lastRoutineAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastRoutineAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      lastRoutineAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastRoutineAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      lastRoutineAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastRoutineAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      missedRoutineTodayEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'missedRoutineToday',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      patientIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'patientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      patientIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'patientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      patientIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'patientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      patientIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'patientId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      patientIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'patientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      patientIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'patientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      patientIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'patientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      patientIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'patientId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      patientIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'patientId',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      patientIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'patientId',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      photoPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'photoPath',
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      photoPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'photoPath',
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      photoPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      photoPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      photoPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      photoPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photoPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      photoPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      photoPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      photoPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      photoPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      photoPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      photoPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      routineComplianceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'routineCompliance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      routineComplianceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'routineCompliance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      routineComplianceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'routineCompliance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      routineComplianceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'routineCompliance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition> statusEqualTo(
      PatientStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      statusGreaterThan(
    PatientStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      statusLessThan(
    PatientStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition> statusBetween(
    PatientStatus lower,
    PatientStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PatientLocalQueryObject
    on QueryBuilder<PatientLocal, PatientLocal, QFilterCondition> {}

extension PatientLocalQueryLinks
    on QueryBuilder<PatientLocal, PatientLocal, QFilterCondition> {}

extension PatientLocalQuerySortBy
    on QueryBuilder<PatientLocal, PatientLocal, QSortBy> {
  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy>
      sortByCognitiveDeclineAlert() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cognitiveDeclineAlert', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy>
      sortByCognitiveDeclineAlertDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cognitiveDeclineAlert', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy>
      sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> sortByLastRoutineAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRoutineAt', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy>
      sortByLastRoutineAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRoutineAt', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy>
      sortByMissedRoutineToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missedRoutineToday', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy>
      sortByMissedRoutineTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missedRoutineToday', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> sortByPatientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patientId', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> sortByPatientIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patientId', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> sortByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> sortByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy>
      sortByRoutineCompliance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routineCompliance', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy>
      sortByRoutineComplianceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routineCompliance', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PatientLocalQuerySortThenBy
    on QueryBuilder<PatientLocal, PatientLocal, QSortThenBy> {
  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy>
      thenByCognitiveDeclineAlert() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cognitiveDeclineAlert', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy>
      thenByCognitiveDeclineAlertDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cognitiveDeclineAlert', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy>
      thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> thenByLastRoutineAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRoutineAt', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy>
      thenByLastRoutineAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRoutineAt', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy>
      thenByMissedRoutineToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missedRoutineToday', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy>
      thenByMissedRoutineTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'missedRoutineToday', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> thenByPatientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patientId', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> thenByPatientIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patientId', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> thenByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> thenByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy>
      thenByRoutineCompliance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routineCompliance', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy>
      thenByRoutineComplianceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routineCompliance', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PatientLocalQueryWhereDistinct
    on QueryBuilder<PatientLocal, PatientLocal, QDistinct> {
  QueryBuilder<PatientLocal, PatientLocal, QDistinct>
      distinctByCognitiveDeclineAlert() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cognitiveDeclineAlert');
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QDistinct> distinctByDisplayName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QDistinct>
      distinctByLastRoutineAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastRoutineAt');
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QDistinct>
      distinctByMissedRoutineToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'missedRoutineToday');
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QDistinct> distinctByPatientId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'patientId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QDistinct> distinctByPhotoPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QDistinct>
      distinctByRoutineCompliance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'routineCompliance');
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<PatientLocal, PatientLocal, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension PatientLocalQueryProperty
    on QueryBuilder<PatientLocal, PatientLocal, QQueryProperty> {
  QueryBuilder<PatientLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PatientLocal, bool, QQueryOperations>
      cognitiveDeclineAlertProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cognitiveDeclineAlert');
    });
  }

  QueryBuilder<PatientLocal, String, QQueryOperations> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<PatientLocal, DateTime?, QQueryOperations>
      lastRoutineAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastRoutineAt');
    });
  }

  QueryBuilder<PatientLocal, bool, QQueryOperations>
      missedRoutineTodayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'missedRoutineToday');
    });
  }

  QueryBuilder<PatientLocal, String, QQueryOperations> patientIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'patientId');
    });
  }

  QueryBuilder<PatientLocal, String?, QQueryOperations> photoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoPath');
    });
  }

  QueryBuilder<PatientLocal, double, QQueryOperations>
      routineComplianceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'routineCompliance');
    });
  }

  QueryBuilder<PatientLocal, PatientStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PatientLocal, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
