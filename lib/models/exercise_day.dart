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
  // these are used by default programs, for now anyway.
  List<int> reps;
  List<int> prSets;
  List<double> percentages;
  List<String> lifts;
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
    if (exerciseSet.indexForOrdering == null) {
      exerciseSet.indexForOrdering = exercises.length - 1;
    }
    exercises.add(exerciseSet);
    if (currentSet == null) {
      currentSet = 0;
    }
    notifyListeners();
  }

  void addAllExercise(
    List<ExerciseSet> exerciseSet,
  ) {
    if (exercises == null) {
      exercises = List<ExerciseSet>();
    }
    exercises.addAll(exerciseSet);
    if (currentSet == null) {
      currentSet = 0;
    }
    // set the order of each element. only needed while building, not while using. stores the order.
    // sorting first pulls in the order from the cloud.
    // TODO: ... and overwrites with the same exact variables that are already there locally, ya?
    // is fine, we don't shoot it off to the cloud again or anything, but still not ideal.
    exercises.sort((lift1, lift2) =>
        lift1.indexForOrdering.compareTo(lift2.indexForOrdering));

    exercises.forEach((element) {
      element.indexForOrdering = exercises.indexOf(element);
    });

    notifyListeners();
  }

  void buildCustomDay(
      {@required List<ExerciseSet> exerciseSets, bool updateMaxIfGetReps}) {
    // clear out what might've been in there before, if we picked multiple programs today
    this.exercises = new List<ExerciseSet>();
    this.addAllExercise(exerciseSets);

    this.updateMaxIfGetReps = updateMaxIfGetReps;
    // when building, this will be false
    this.justDidLastSet = false;
    //notifyListeners();
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
    this.updateMaxIfGetReps = updateMaxIfGetReps;
    this.progressSet = progressSet;
    this.prSetWeek = prSetWeek;
    this.justDidLastSet = false;
    // build and populate the list of exercises to do.
    this.exercises = new List<ExerciseSet>();
    for (int i = 0, mainLiftIterator = 0; i < reps.length; ++i) {
      if (lifts[i].toUpperCase() == "MAIN") {
        // TODO: see elsewhere, but USE CONSTRUCTORS IT IS WHY THEY EXIST
        ExerciseSet tmp = new ExerciseSet(reps: this.reps[i]);
        // add the main items to the list

        // this function depends on the current set of the day, but we need to reset that at the end.
        tmp.updateExerciseFull(
          context: context,
          useBarbellWeight: true,
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

// no idea if this will work but give it a shot!
  factory ExerciseDay.deepCopy({ExerciseDay copyingFrom}) {
    ExerciseDay toReturn = ExerciseDay(
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
      // need to deep copy the exercises

      prSetWeek: copyingFrom.prSetWeek,
      justDidLastSet: copyingFrom.justDidLastSet,
    );
    // deep copy the sets.
    List<ExerciseSet> toReturn2 = List<ExerciseSet>();
    copyingFrom.exercises?.forEach((element) {
      toReturn2.add(ExerciseSet.deepCopy(copyingFrom: element));
    });
    toReturn.exercises = toReturn2;
    return toReturn;
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

  void insert(int index, ExerciseSet exerciseSet, bool isBuildingNotUsing) {
    exercises.insert(index, exerciseSet);
    // for each element, reset the index of
    if (isBuildingNotUsing) {
      exercises.forEach((element) {
        element.indexForOrdering = exercises.indexOf(element);
      });
    }

    //if (isBuildingNotUsing) {
    // update this one to its new index
    //exercises[index].indexForOrdering = index;
    // and increment everyone after since one just came before them
    //for(int i = index; i < exercises.length)
    //}
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
        updateMaxIfGetReps,
        progressSet,
        exercises,
        prSetWeek,
        justDidLastSet,
      ];
}
