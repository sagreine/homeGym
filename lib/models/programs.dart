import 'package:flutter/material.dart';
//import 'package:json_annotation/json_annotation.dart';

//part 'programs.g.dart';

// TODO this is really 'program-week' and we get ourselves in trouble because of that...
class PickedProgram {
  String program;
  int week;
  bool potentialProgressWeek;
  String type;
  double trainingMaxPct;
  bool isCustom;
  bool isMainLift;

  PickedProgram({
    this.program,
    this.week,
    this.potentialProgressWeek,
    this.type,
    this.trainingMaxPct,
    this.isCustom,
    this.isMainLift,
  });

  /// This creates a new program from another program by deep copying all of the other program's variables values
  PickedProgram.deepCopy(PickedProgram otherProgram)
      : this(
            program: otherProgram.program,
            week: otherProgram.week,
            potentialProgressWeek: otherProgram.potentialProgressWeek,
            type: otherProgram.type,
            trainingMaxPct: otherProgram.trainingMaxPct,
            isCustom: otherProgram.isCustom,
            isMainLift: otherProgram.isMainLift);
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
    }
    pickedPrograms.add(newProgram);
    notifyListeners();
  }

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
