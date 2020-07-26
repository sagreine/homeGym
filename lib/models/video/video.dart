import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
//import 'package:camera/camera.dart';
//import 'package:flutter/material.dart';
//import 'dart:async';
//import 'dart:io';
//import 'package:path_provider/path_provider.dart';

import 'package:json_annotation/json_annotation.dart';

part 'video.g.dart';

//? not sure

@JsonSerializable()
class ExerciseSet extends ChangeNotifier {
  // this will only be used on mobile - previously i thought that, but easiest to keep it and write it to db alongside this..

  String videoPath;
  // these will be passed to TV. probably won't live here in the long run tbh.
  String title;
  String description;
  // TV app uses this to pick vidoes - for now
  String type;
  int restPeriodAfter;

  ExerciseSet(
      {this.videoPath,
      this.title,
      this.description,
      this.restPeriodAfter,
      this.type});

  factory ExerciseSet.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSetFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseSetToJson(this);

  @override
  List<Object> get props => [
        videoPath,
        title,
        description,
        type,
        restPeriodAfter,
      ];
}
