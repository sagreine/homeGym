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
