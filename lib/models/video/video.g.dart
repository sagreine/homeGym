// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Video _$VideoFromJson(Map<String, dynamic> json) {
  return Video(
    videoPath: json['videoPath'] as String,
    videoTitle: json['videoTitle'] as String,
  );
}

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
      'videoPath': instance.videoPath,
      'videoTitle': instance.videoTitle,
    };
