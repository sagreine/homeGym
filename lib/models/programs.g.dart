// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'programs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Programs _$ProgramsFromJson(Map<String, dynamic> json) {
  return Programs(
    programs: (json['programs'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$ProgramsToJson(Programs instance) => <String, dynamic>{
      'programs': instance.programs,
    };
