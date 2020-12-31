// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lifter_maxes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LifterMaxes _$LifterMaxesFromJson(Map<String, dynamic> json) {
  return LifterMaxes(
    deadliftMax: json['deadliftMax'] as int,
    squatMax: json['squatMax'] as int,
    benchMax: json['benchMax'] as int,
    pressMax: json['pressMax'] as int,
  )..calculatedMax = json['calculatedMax'] as int;
}

Map<String, dynamic> _$LifterMaxesToJson(LifterMaxes instance) =>
    <String, dynamic>{
      'deadliftMax': instance.deadliftMax,
      'squatMax': instance.squatMax,
      'benchMax': instance.benchMax,
      'pressMax': instance.pressMax,
      'calculatedMax': instance.calculatedMax,
    };
