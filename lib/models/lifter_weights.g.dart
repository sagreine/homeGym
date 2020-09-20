// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lifter_weights.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LifterWeights _$LifterWeightsFromJson(Map<String, dynamic> json) {
  return LifterWeights(
    barWeight: json['barWeight'] as int,
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
      'barWeight': instance.barWeight,
      'plates': instance.plates,
      'bumpers': instance.bumpers,
      'deadliftWeightAdjustmentPrefix': instance.deadliftWeightAdjustmentPrefix,
      'deadliftWeightAdjustmentSuffix': instance.deadliftWeightAdjustmentSuffix,
    };
