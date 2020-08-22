import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_day.g.dart';

@JsonSerializable()
class ExerciseDay extends ChangeNotifier {
  // sets is derivable no?
  int sets;
  double trainingMax;
  int currentSet;
  // 2d list? or, list of Exercises? probably ultimately a list of exericses will be what we want to use.
  List<int> reps;
  List<double> percentages;
  int assistancePullReps;
  int assistanceCoreReps;
  int assistancePushReps;
  List<String> assistancePull;
  List<String> assistanceCore;
  List<String> assistancePush;

  ExerciseDay({
    this.sets,
    this.reps,
    this.currentSet,
    this.percentages,
    this.trainingMax,
    this.assistancePullReps,
    this.assistanceCoreReps,
    this.assistancePushReps,
    this.assistanceCore,
    this.assistancePull,
    this.assistancePush,
  });

  void buildDay({
    int sets,
    List<int> reps,
    List<double> percentages,
    int currentSet,
    double trainingMax,
    int assistanceCoreReps,
    int assistancePullReps,
    int assistancePushReps,
    List<String> assistancePull,
    List<String> assistanceCore,
    List<String> assistancePush,
  }) {
    this.sets = sets;
    this.reps = reps;
    this.percentages = percentages;
    this.currentSet = currentSet;
    this.trainingMax = trainingMax;
    this.assistanceCoreReps = assistanceCoreReps;
    this.assistancePullReps = assistancePullReps;
    this.assistancePushReps = assistancePushReps;
    this.assistanceCore = assistanceCore;
    this.assistancePull = assistancePull;
    this.assistancePush = assistancePush;
    notifyListeners();
  }

  // hmmm
  // also, previously returned true right away with no notify. might want that...
  bool nextSet() {
    bool returnval;
    print("old current set: " + currentSet.toString());
    if (currentSet + 1 < sets) {
      currentSet++;
      returnval = true;
    } else {
      print("this was the last set");
      returnval = false;
    }
    print("new current set: " + currentSet.toString());
    notifyListeners();
    return returnval;
  }

  // update currentSet here .... check it is < sets - 1 etc.

  factory ExerciseDay.fromJson(Map<String, dynamic> json) =>
      _$ExerciseDayFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseDayToJson(this);

  //@override
  List<Object> get props => [
        sets,
        reps,
        percentages,
        currentSet,
        trainingMax,
        assistanceCoreReps,
        assistancePullReps,
        assistancePushReps,
        assistanceCore,
        assistancePull,
        assistancePush,
      ];
}
