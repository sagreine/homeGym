// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseDay _$ExerciseDayFromJson(Map<String, dynamic> json) {
  return ExerciseDay(
    sets: json['sets'] as int,
    reps: (json['reps'] as List)?.map((e) => e as int)?.toList(),
    currentSet: json['currentSet'] as int,
    percentages: (json['percentages'] as List)
        ?.map((e) => (e as num)?.toDouble())
        ?.toList(),
    trainingMax: (json['trainingMax'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$ExerciseDayToJson(ExerciseDay instance) =>
    <String, dynamic>{
      'sets': instance.sets,
      'trainingMax': instance.trainingMax,
      'currentSet': instance.currentSet,
      'reps': instance.reps,
      'percentages': instance.percentages,
    };
