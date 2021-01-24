// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'programs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PickedProgram _$PickedProgramFromJson(Map<String, dynamic> json) {
  return PickedProgram(
    program: json['program'] as String,
    week: json['week'] as int,
    potentialProgressWeek: json['potentialProgressWeek'] as bool,
    type: json['type'] as String,
    trainingMaxPct: (json['trainingMaxPct'] as num)?.toDouble(),
    isCustom: json['isCustom'] as bool,
    isMainLift: json['isMainLift'] as bool,
    isAnewCopy: json['isAnewCopy'] as bool,
    id: json['id'] as String,
  )..neverTouched = json['neverTouched'] as bool;
}

Map<String, dynamic> _$PickedProgramToJson(PickedProgram instance) =>
    <String, dynamic>{
      'program': instance.program,
      'week': instance.week,
      'potentialProgressWeek': instance.potentialProgressWeek,
      'type': instance.type,
      'trainingMaxPct': instance.trainingMaxPct,
      'isCustom': instance.isCustom,
      'isMainLift': instance.isMainLift,
      'neverTouched': instance.neverTouched,
      'isAnewCopy': instance.isAnewCopy,
      'id': instance.id,
    };
