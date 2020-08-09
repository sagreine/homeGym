// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lifter_weights.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LifterWeights _$LifterWeightsFromJson(Map<String, dynamic> json) {
  return LifterWeights(
    barWeight: (json['barWeight'] as num)?.toDouble(),
    plates: (json['plates'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
  );
}

Map<String, dynamic> _$LifterWeightsToJson(LifterWeights instance) =>
    <String, dynamic>{
      'barWeight': instance.barWeight,
      'plates': instance.plates,
    };

LiftMaxes _$LiftMaxesFromJson(Map<String, dynamic> json) {
  return LiftMaxes(
    deadliftMax: json['deadliftMax'] as int,
    squatMax: json['squatMax'] as int,
    benchMax: json['benchMax'] as int,
    pressMax: json['pressMax'] as int,
  );
}

Map<String, dynamic> _$LiftMaxesToJson(LiftMaxes instance) => <String, dynamic>{
      'deadliftMax': instance.deadliftMax,
      'squatMax': instance.squatMax,
      'benchMax': instance.benchMax,
      'pressMax': instance.pressMax,
    };
