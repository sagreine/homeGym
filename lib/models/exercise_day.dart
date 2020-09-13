import 'package:flutter/cupertino.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_day.g.dart';

@JsonSerializable()
class ExerciseDay extends ChangeNotifier {
  // sets is derivable no?
  String program;
  String lift;
  int sets;
  double trainingMax;
  int currentSet;
  // 2d list? or, list of Exercises? probably ultimately a list of exericses will be what we want to use.
  List<int> reps;
  List<double> percentages;
  List<int> assistancePullReps;
  List<int> assistanceCoreReps;
  List<int> assistancePushReps;
  List<String> assistancePull;
  List<String> assistanceCore;
  List<String> assistancePush;
  bool updateMaxIfGetReps;
  bool prSetWeek;
  int progressSet;

  List<ExerciseSet> exercises;
  ExerciseController exerciseController = new ExerciseController();

  ExerciseDay({
    this.lift,
    this.program,
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
    this.updateMaxIfGetReps,
    this.progressSet,
    this.exercises,
    this.prSetWeek,
  });

  void buildDay({
    String lift,
    String program,
    int sets,
    List<int> reps,
    List<double> percentages,
    int currentSet,
    double trainingMax,
    List<int> assistanceCoreReps,
    List<int> assistancePullReps,
    List<int> assistancePushReps,
    List<String> assistancePull,
    List<String> assistanceCore,
    List<String> assistancePush,
    bool updateMaxIfGetReps,
    bool prSetWeek,
    int progressSet,
    BuildContext context,
  }) {
    this.lift = lift;
    this.program = program;
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
    this.updateMaxIfGetReps = updateMaxIfGetReps;
    this.progressSet = progressSet;
    this.prSetWeek = prSetWeek;
    // build and populate the list of exercises to do.
    this.exercises = new List<ExerciseSet>();
    List<String> allAssistance =
        assistanceCore + assistancePull + assistancePush;
    List<int> allAssistanceReps =
        assistanceCoreReps + assistancePullReps + assistancePushReps;
    // this is bad, but sometimes we want to prime some exercises based on what set they're planned to be
    // this is very stupid.
    int plannedSet = 0;
    for (int i = 0; i < reps.length; ++i, ++plannedSet) {
      ExerciseSet tmp = new ExerciseSet();
      // add the main items to the list

      // this function depends on the current set of the day, but we need to reset that at the end.
      tmp.updateExerciseFull(
        context: context,
        exerciseTitle: lift,
        reps: this.reps[i],
        setPct: this.percentages[i],
        plannedSet: plannedSet,
      );
      this.exercises.add(tmp);
      // updating it here for whatever reason instead of passing it in as a parameter.........
    }
    for (int i = 0; i < allAssistance.length; ++i, ++plannedSet) {
      this.exercises.add(new ExerciseSet(
          restPeriodAfter: 90,
          // the first rep.length are the main lift, non-assistance.
          title: allAssistance[i],
          description: "Do the assistance activity",
          weight:
              0, // TODO: could do ternary? if there is a weight set in db, use it.
          reps: allAssistanceReps[i]));
    }
    // reset this to the very first set.
    //this.currentSet = 0;
    notifyListeners();
  }

  // hmmm
  // also, previously returned true right away with no notify. might want that...
  bool nextSet() {
    bool returnval;
    print("old current set: " + currentSet.toString());
    if (!areWeOnLastSet()) {
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

  bool areWeOnLastSet() {
    return (currentSet == sets - 1);
  }

  // update currentSet here .... check it is < sets - 1 etc.

  factory ExerciseDay.fromJson(Map<String, dynamic> json) =>
      _$ExerciseDayFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseDayToJson(this);

  //@override
  List<Object> get props => [
        lift,
        program,
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
        updateMaxIfGetReps,
        progressSet,
        exercises,
        prSetWeek,
      ];
}
