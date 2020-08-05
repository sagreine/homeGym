import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_day.g.dart';

@JsonSerializable()
class ExerciseDay extends ChangeNotifier {
  int sets;
  int currentSet;
  // 2d list? or, list of Exercises? probably ultimately a list of exericses will be what we want to use.
  List<int> reps;
  List<double> percentages;

  ExerciseDay({
    this.sets,
    this.reps,
    this.currentSet,
    this.percentages,
  });

  void buildDay(
      {int sets, List<int> reps, List<double> percentages, int currentSet}) {
    this.sets = sets;
    this.reps = reps;
    this.percentages = percentages;
    this.currentSet = currentSet;
    notifyListeners();
  }

  // update currentSet here .... check it is < sets - 1 etc.
  notifyListeners();

  factory ExerciseDay.fromJson(Map<String, dynamic> json) =>
      _$ExerciseDayFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseDayToJson(this);

  //@override
  List<Object> get props => [
        sets,
        reps,
        percentages,
        currentSet,
      ];
}
