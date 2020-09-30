// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseSet _$ExerciseSetFromJson(Map<String, dynamic> json) {
  return ExerciseSet(
    videoPath: json['videoPath'] as String,
    thumbnailPath: json['thumbnailPath'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    restPeriodAfter: json['restPeriodAfter'] as int,
    weight: json['weight'] as int,
    reps: json['reps'] as int,
    thisSetPRSet: json['thisSetPRSet'] as bool,
    aspectRatio: (json['aspectRatio'] as num)?.toDouble(),
    dateTime: json['dateTime'] == null
        ? null
        : DateTime.parse(json['dateTime'] as String),
  )..type = json['type'] as String;
}

Map<String, dynamic> _$ExerciseSetToJson(ExerciseSet instance) =>
    <String, dynamic>{
      'videoPath': instance.videoPath,
      'thumbnailPath': instance.thumbnailPath,
      'aspectRatio': instance.aspectRatio,
      'title': instance.title,
      'description': instance.description,
      'type': instance.type,
      'restPeriodAfter': instance.restPeriodAfter,
      'weight': instance.weight,
      'reps': instance.reps,
      'dateTime': instance.dateTime?.toIso8601String(),
      'thisSetPRSet': instance.thisSetPRSet,
    };
