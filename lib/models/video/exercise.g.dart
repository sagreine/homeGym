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
    thisSetProgressSet: json['thisSetProgressSet'] as bool,
    wasWeightPRSet: json['wasWeightPRSet'] as bool,
    wasRepPRSet: json['wasRepPRSet'] as bool,
    duration: (json['duration'] as num)?.toDouble(),
    hasBeenUpdated: json['hasBeenUpdated'] as bool,
    basedOnBarbellWeight: json['basedOnBarbellWeight'] as bool,
    basedOnPercentageOfTM: json['basedOnPercentageOfTM'] as bool,
    indexForOrdering: json['indexForOrdering'] as int,
    percentageOfTM: (json['percentageOfTM'] as num)?.toDouble(),
    thisIsRPESet: json['thisIsRPESet'] as bool,
    whichBarbellIndex: json['whichBarbellIndex'] as int,
  )
    ..type = json['type'] as String
    ..keywords = (json['keywords'] as List)?.map((e) => e as String)?.toList()
    ..whichLiftForPercentageofTMIndex =
        json['whichLiftForPercentageofTMIndex'] as int
    ..rpe = json['rpe'] as int;
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
      'duration': instance.duration,
      'keywords': instance.keywords,
      'dateTime': instance.dateTime?.toIso8601String(),
      'basedOnBarbellWeight': instance.basedOnBarbellWeight,
      'basedOnPercentageOfTM': instance.basedOnPercentageOfTM,
      'percentageOfTM': instance.percentageOfTM,
      'thisSetPRSet': instance.thisSetPRSet,
      'thisSetProgressSet': instance.thisSetProgressSet,
      'wasWeightPRSet': instance.wasWeightPRSet,
      'wasRepPRSet': instance.wasRepPRSet,
      'thisIsRPESet': instance.thisIsRPESet,
      'indexForOrdering': instance.indexForOrdering,
      'whichBarbellIndex': instance.whichBarbellIndex,
      'whichLiftForPercentageofTMIndex':
          instance.whichLiftForPercentageofTMIndex,
      'rpe': instance.rpe,
      'hasBeenUpdated': instance.hasBeenUpdated,
    };
