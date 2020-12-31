// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lifter_weights.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LifterWeights _$LifterWeightsFromJson(Map<String, dynamic> json) {
  return LifterWeights(
    squatBarWeight: json['squatBarWeight'] as int,
    deadliftBarWeight: json['deadliftBarWeight'] as int,
    pressBarWeight: json['pressBarWeight'] as int,
    benchBarWeight: json['benchBarWeight'] as int,
    plates: (json['plates'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as int),
    ),
    bumpers: json['bumpers'] as bool,
  )
    ..deadliftWeightAdjustmentPrefix =
        json['deadliftWeightAdjustmentPrefix'] as String
    ..deadliftWeightAdjustmentSuffix =
        json['deadliftWeightAdjustmentSuffix'] as String;
}

Map<String, dynamic> _$LifterWeightsToJson(LifterWeights instance) =>
    <String, dynamic>{
      'squatBarWeight': instance.squatBarWeight,
      'deadliftBarWeight': instance.deadliftBarWeight,
      'pressBarWeight': instance.pressBarWeight,
      'benchBarWeight': instance.benchBarWeight,
      'plates': instance.plates,
      'bumpers': instance.bumpers,
      'deadliftWeightAdjustmentPrefix': instance.deadliftWeightAdjustmentPrefix,
      'deadliftWeightAdjustmentSuffix': instance.deadliftWeightAdjustmentSuffix,
    };
