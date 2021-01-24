import 'package:flutter/cupertino.dart';
import 'package:home_gym/models/models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_day.g.dart';

@JsonSerializable()
class ExerciseDay extends ChangeNotifier {
  // sets is derivable no? - yes. either don't use or use a getter = to .length ....
  String program;
  String lift;
  int get sets {
    return exercises.length;
  }

  double trainingMax;
  int currentSet;
  // 2d list? or, list of Exercises? probably ultimately a list of exericses will be what we want to use.
  List<int> reps;
  List<int> prSets;
  List<double> percentages;
  List<String> lifts;
  /*
  List<int> assistancePullReps;
  List<int> assistanceCoreReps;
  List<int> assistancePushReps;
  List<String> assistancePull;
  List<String> assistanceCore;
  List<String> assistancePush;*/
  bool updateMaxIfGetReps;
  bool prSetWeek;
  int progressSet;

  bool justDidLastSet;

  List<ExerciseSet> exercises;
  //ExerciseController exerciseController = new ExerciseController();

  ExerciseDay({
    this.lift,
    this.program,
    //this.sets,
    this.reps,
    this.currentSet,
    this.percentages,
    this.trainingMax,
    this.lifts,
    this.prSets,
    /*
    this.assistancePullReps,
    this.assistanceCoreReps,
    this.assistancePushReps,
    this.assistanceCore,
    this.assistancePull,
    this.assistancePush,
    */
    this.updateMaxIfGetReps,
    this.progressSet,
    this.exercises,
    this.prSetWeek,
    this.justDidLastSet,
  }) {
    /*if (exercises == null) {
      exercises = List<ExerciseSet>();
    }*/
  }

  void addExercise(ExerciseSet exerciseSet) {
    if (exercises == null) {
      exercises = List<ExerciseSet>();
    }
    exercises.add(exerciseSet);
    if (currentSet == null) {
      currentSet = 0;
    }
    notifyListeners();
  }

  void buildDay({
    String lift,
    String program,
    int sets,
    List<int> reps,
    List<double> percentages,
    List<int> prSets,
    int currentSet,
    //double trainingMax,
    /*
    List<int> assistanceCoreReps,
    List<int> assistancePullReps,
    List<int> assistancePushReps,
    List<String> assistancePull,
    List<String> assistanceCore,
    List<String> assistancePush,*/
    bool updateMaxIfGetReps,
    bool prSetWeek,
    int progressSet,
    BuildContext context,
    List<String> lifts,
  }) {
    this.lift = lift;
    this.program = program;
    //this.sets = sets;
    this.reps = reps;
    this.percentages = percentages;
    this.currentSet = currentSet;
    //this.trainingMax = trainingMax;
    this.lifts = lifts;
    this.prSets = prSets;
    /*
    this.assistanceCoreReps = assistanceCoreReps;
    this.assistancePullReps = assistancePullReps;
    this.assistancePushReps = assistancePushReps;
    this.assistanceCore = assistanceCore;
    this.assistancePull = assistancePull;
    this.assistancePush = assistancePush;
    */
    this.updateMaxIfGetReps = updateMaxIfGetReps;
    this.progressSet = progressSet;
    this.prSetWeek = prSetWeek;
    this.justDidLastSet = false;
    // build and populate the list of exercises to do.
    this.exercises = new List<ExerciseSet>();
    /*
    List<String> allAssistance =
        assistanceCore + assistancePull + assistancePush;
    List<int> allAssistanceReps =
        assistanceCoreReps + assistancePullReps + assistancePushReps;
        */
    for (int i = 0, mainLiftIterator = 0; i < reps.length; ++i) {
      if (lifts[i].toUpperCase() == "MAIN") {
        // TODO: see elsewhere, but USE CONSTRUCTORS IT IS WHY THEY EXIST
        ExerciseSet tmp = new ExerciseSet(reps: this.reps[i]);
        // add the main items to the list

        // this function depends on the current set of the day, but we need to reset that at the end.
        tmp.updateExerciseFull(
          context: context,
          exerciseTitle: lift,
          id: UniqueKey().toString() +
              UniqueKey().toString() +
              UniqueKey().toString() +
              UniqueKey().toString() +
              UniqueKey().toString() +
              UniqueKey().toString(),
          reps: this.reps[i],
          setPct: this.percentages[mainLiftIterator],
          // this is a PR set if it is in the list of PR sets.
          thisSetPRSet: prSets.any((element) => element == i),
          thisSetProgressSet: this.progressSet == i && this.updateMaxIfGetReps,
        );
        this.exercises.add(tmp);
        // this iterator works through percentages, with is main lift only
        ++mainLiftIterator;
      }

      // updating it here for whatever reason instead of passing it in as a parameter.........
      else {
        this.exercises.add(new ExerciseSet(
            restPeriodAfter: 90,
            // the first rep.length are the main lift, non-assistance.
            title: lifts[i],
            description: "Do the lift",
            id: UniqueKey().toString() +
                UniqueKey().toString() +
                UniqueKey().toString() +
                UniqueKey().toString() +
                UniqueKey().toString() +
                UniqueKey().toString(),
            weight:
                0, // TODO: could do ternary? if there is a weight set in db, use it.
            reps: reps[i]));
      }
      // reset this to the very first set.
      //this.currentSet = 0;
      notifyListeners();
    }
  }

  ExerciseDay.deepCopy({ExerciseDay copyingFrom})
      : this(
          lift: copyingFrom.lift,
          program: copyingFrom.program,
          reps: copyingFrom.reps,
          currentSet: copyingFrom.currentSet,
          percentages: copyingFrom.percentages,
          trainingMax: copyingFrom.trainingMax,
          lifts: copyingFrom.lifts,
          prSets: copyingFrom.prSets,
          updateMaxIfGetReps: copyingFrom.updateMaxIfGetReps,
          progressSet: copyingFrom.progressSet,
          exercises: copyingFrom.exercises,
          prSetWeek: copyingFrom.prSetWeek,
          justDidLastSet: copyingFrom.justDidLastSet,
        );

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

  // this is disgusting but expedient.
  // because we dont' have MVC actually in use, we need to treat it differently
  // so if you press the button on the last set, you want to set it to no more by subtracting 1
  // but if you delete the last item from the Day view, you don't want to skip that last set.
  bool areWeOnLastSet({int offset}) {
    offset ??= 1;
    if (currentSet == sets - offset) {
      justDidLastSet = true;
      notifyListeners();
      return true;
    }
    return false;

    //justDidLastSet = true;
  }

  ExerciseSet removeAt(int index) {
    var _return = exercises.removeAt(index);
    //sets -= 1;
    // to update justDidLastSet, but also why we should probably have that as the getter for a private variable if we're doing caching like that...
    areWeOnLastSet(offset: 0);
    //displayInExerciseInfo();
    notifyListeners();
    return _return;
  }

  void insert(int index, ExerciseSet exerciseSet) {
    exercises.insert(index, exerciseSet);
    //if (increaseTotal) {
    //sets++;

    notifyListeners();
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
        lifts,
        prSets,
        /*
        assistanceCoreReps,
        assistancePullReps,
        assistancePushReps,
        assistanceCore,
        assistancePull,
        assistancePush,
        */
        updateMaxIfGetReps,
        progressSet,
        exercises,
        prSetWeek,
        justDidLastSet,
      ];
}
