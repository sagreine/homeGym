import 'package:flutter/material.dart';
//import 'package:json_annotation/json_annotation.dart';

//part 'programs.g.dart';

class PickedProgram {
  String program;
  int week;
  bool potentialProgressWeek;
  String type;
  double trainingMaxPct;

  PickedProgram({
    this.program,
    this.week,
    this.potentialProgressWeek,
    this.type,
    this.trainingMaxPct,
  });
}

//@JsonSerializable()
class Programs extends ChangeNotifier {
  // we don't need these really though?
  List<String> programs;
  List<int> weeks;

  List<PickedProgram> pickedPrograms;

  // but wouldn't want them to do this? woudln't want a public constructor since the other fields are derived i mean.
  Programs({
    this.programs,
    this.weeks,
    this.pickedPrograms,
  });

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
