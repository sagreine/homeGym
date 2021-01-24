import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
//import 'package:json_annotation/json_annotation.dart';

//part 'programs.g.dart';

// TODO this is really 'program-week' and we get ourselves in trouble because of that...
// specifically, take care if we treat this as "weeks" and "week". e.g. is this telling us it is week2?
// or is it not independent from the List<>weeks of the parent class and therefore doing both Num of Weeks and selected week duty?

// TODO: add ID here since we're switching away from distinct names. we'll use that ID to query against, e.g. for if we copied
// from another program that'll have the old id in it - will it? no, once we write, we'll have the new one .
// i guess we could have a CopiedFrom ID here or something?
class PickedProgram {
  String program;
  int week;
  bool potentialProgressWeek;
  String type;
  double trainingMaxPct;
  bool isCustom;
  bool isMainLift;
  bool neverTouched;
  bool isAnewCopy;
  List<ExerciseDay> exerciseDays;

  get numWeeks => exerciseDays.length;

  PickedProgram({
    this.program,
    this.week,
    this.potentialProgressWeek,
    this.type,
    this.trainingMaxPct,
    this.isCustom,
    this.isMainLift,
    this.isAnewCopy,
    this.exerciseDays,
  }) {
    this.neverTouched = false;
  }

  /// This creates a new program from another program by deep copying all of the other program's variables values
  PickedProgram.deepCopy(PickedProgram otherProgram) {
    this.program = otherProgram.program;
    this.week = otherProgram.week;
    this.potentialProgressWeek = otherProgram.potentialProgressWeek;
    this.type = otherProgram.type;
    this.trainingMaxPct = otherProgram.trainingMaxPct;
    this.isCustom = otherProgram.isCustom;
    this.isMainLift = otherProgram.isMainLift;
    this.isAnewCopy = otherProgram.isAnewCopy;
    // need we deep copy this too?

    // copy over the exerciseDays too
    // TODO: untested
    List<ExerciseDay> toReturn = List<ExerciseDay>();
    otherProgram.exerciseDays.forEach((element) {
      toReturn.add(ExerciseDay.deepCopy(copyingFrom: element));
    });
    this.exerciseDays = toReturn;
  }

  upsertExerciseDay(ExerciseDay exerciseDay, int index) {
    //if we try to add an exercise Day that is, say , 7 larger something has gone wrong
    assert(numWeeks - index <= 1);
    // if we're adding one
    if (numWeeks == index) {
      this.exerciseDays.add(exerciseDay);
    }
    // if we're edting one
    else {
      this.exerciseDays[index] = exerciseDay;
    }
  }
}

//@JsonSerializable()
class Programs extends ChangeNotifier {
  // we don't need these really though? it's just there for convenience but now that we have more intelligence here we should really
  // for them not to use this and use pickedPrograms instead...
  List<String> programs;
  List<int> weeks;
  List<bool> hasMainLifts;

  List<PickedProgram> pickedPrograms;

  // but wouldn't want them to do this? woudln't want a public constructor since the other fields are derived i mean.
  Programs({this.programs, this.weeks, this.pickedPrograms, this.hasMainLifts});

  // TODO: need to consider the other variables  here........ or get rid of them entirly.
  void addProgram({PickedProgram newProgram}) {
    if (newProgram == null) {
      newProgram = PickedProgram();
      newProgram.program = "New Program";
      newProgram.isCustom = true;
      newProgram.potentialProgressWeek = false;
      newProgram.isMainLift = false;
      newProgram.type = "Default - Change me!";
      newProgram.trainingMaxPct = 1.0;
      newProgram.week = 1;
      newProgram.neverTouched = true;
    }
    pickedPrograms.add(newProgram);
    notifyListeners();
  }

  // TODO need to set the individual pickd programs values?
  void setProgram({
    @required List<PickedProgram> programs,
  }) {
    this.pickedPrograms = programs;
    this.programs = new List<String>.generate(
        programs.length, (index) => programs[index].program);
    this.weeks = new List<int>.generate(
        programs.length, (index) => programs[index].week);
    notifyListeners();
  }

  // update currentSet here .... check it is < sets - 1 etc.

  //factory Programs.fromJson(Map<String, dynamic> json) =>
  // _$ProgramsFromJson(json);

  //Map<String, dynamic> toJson() => _$ProgramsToJson(this);

  //@override
  List<Object> get props => [
        programs,
        weeks,
        pickedPrograms,
      ];
}
