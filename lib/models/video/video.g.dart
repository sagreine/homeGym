// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseSet _$ExcerciseSetFromJson(Map<String, dynamic> json) {
  return ExerciseSet(
    title: json['title'] as String,
    description: json['description'] as String,
    restPeriodAfter: json['restPeriodAfter'] as int,
  );
}

Map<String, dynamic> _$ExcerciseSetToJson(ExerciseSet instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'restPeriodAfter': instance.restPeriodAfter,
    };
