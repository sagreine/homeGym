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
    assistancePullReps: json['assistancePullReps'] as int,
    assistanceCoreReps: json['assistanceCoreReps'] as int,
    assistancePushReps: json['assistancePushReps'] as int,
    assistanceCore:
        (json['assistanceCore'] as List)?.map((e) => e as String)?.toList(),
    assistancePull:
        (json['assistancePull'] as List)?.map((e) => e as String)?.toList(),
    assistancePush:
        (json['assistancePush'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$ExerciseDayToJson(ExerciseDay instance) =>
    <String, dynamic>{
      'sets': instance.sets,
      'trainingMax': instance.trainingMax,
      'currentSet': instance.currentSet,
      'reps': instance.reps,
      'percentages': instance.percentages,
      'assistancePullReps': instance.assistancePullReps,
      'assistanceCoreReps': instance.assistanceCoreReps,
      'assistancePushReps': instance.assistancePushReps,
      'assistancePull': instance.assistancePull,
      'assistanceCore': instance.assistanceCore,
      'assistancePush': instance.assistancePush,
    };
