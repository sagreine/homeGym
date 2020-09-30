// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseDay _$ExerciseDayFromJson(Map<String, dynamic> json) {
  return ExerciseDay(
    lift: json['lift'] as String,
    program: json['program'] as String,
    sets: json['sets'] as int,
    reps: (json['reps'] as List)?.map((e) => e as int)?.toList(),
    currentSet: json['currentSet'] as int,
    percentages: (json['percentages'] as List)
        ?.map((e) => (e as num)?.toDouble())
        ?.toList(),
    trainingMax: (json['trainingMax'] as num)?.toDouble(),
    lifts: (json['lifts'] as List)?.map((e) => e as String)?.toList(),
    prSets: (json['prSets'] as List)?.map((e) => e as int)?.toList(),
    updateMaxIfGetReps: json['updateMaxIfGetReps'] as bool,
    progressSet: json['progressSet'] as int,
    exercises: (json['exercises'] as List)
        ?.map((e) =>
            e == null ? null : ExerciseSet.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    prSetWeek: json['prSetWeek'] as bool,
    justDidLastSet: json['justDidLastSet'] as bool,
  );
}

Map<String, dynamic> _$ExerciseDayToJson(ExerciseDay instance) =>
    <String, dynamic>{
      'program': instance.program,
      'lift': instance.lift,
      'sets': instance.sets,
      'trainingMax': instance.trainingMax,
      'currentSet': instance.currentSet,
      'reps': instance.reps,
      'prSets': instance.prSets,
      'percentages': instance.percentages,
      'lifts': instance.lifts,
      'updateMaxIfGetReps': instance.updateMaxIfGetReps,
      'prSetWeek': instance.prSetWeek,
      'progressSet': instance.progressSet,
      'justDidLastSet': instance.justDidLastSet,
      'exercises': instance.exercises,
    };
