import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise.g.dart';

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
  int weight;
  int reps;

  ExerciseSet({
    this.videoPath,
    this.title,
    this.description,
    this.restPeriodAfter,
    this.type,
    this.weight,
    this.reps,
  });

  void updateExercise(
      {String title,
      String description,
      int restPeriodAfter,
      int weight,
      int reps}) {
    this.title = title;
    this.description = description;
    this.restPeriodAfter = restPeriodAfter;
    this.weight = weight;
    this.reps = reps;
    this.type = "video/";
    notifyListeners();
  }

  factory ExerciseSet.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSetFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseSetToJson(this);

  //@override
  List<Object> get props => [
        videoPath,
        title,
        description,
        type,
        restPeriodAfter,
        reps,
        weight,
      ];
}
