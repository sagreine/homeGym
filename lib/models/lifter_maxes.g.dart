part of 'lifter_maxes.dart';

LifterMaxes _$LifterMaxesFromJson(Map<String, dynamic> json) {
  return LifterMaxes(
    deadliftMax: json['deadliftMax'] as int,
    squatMax: json['squatMax'] as int,
    benchMax: json['benchMax'] as int,
    pressMax: json['pressMax'] as int,
  );
}

Map<String, dynamic> _$LifterMaxesToJson(LifterMaxes instance) =>
    <String, dynamic>{
      'deadliftMax': instance.deadliftMax,
      'squatMax': instance.squatMax,
      'benchMax': instance.benchMax,
      'pressMax': instance.pressMax,
    };
