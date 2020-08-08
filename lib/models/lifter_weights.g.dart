// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lifter_weights.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LifterWeights _$LifterWeightsFromJson(Map<String, dynamic> json) {
  return LifterWeights(
    barWeight: json['barWeight'] as int,
    plates:
        (json['plates'] as List)?.map((e) => (e as num)?.toDouble())?.toList(),
    plateCount: (json['plateCount'] as List)?.map((e) => e as int)?.toList(),
  );
}

Map<String, dynamic> _$LifterWeightsToJson(LifterWeights instance) =>
    <String, dynamic>{
      'barWeight': instance.barWeight,
      'plates': instance.plates,
      'plateCount': instance.plateCount,
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
