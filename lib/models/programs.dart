import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'programs.g.dart';

@JsonSerializable()
class Programs extends ChangeNotifier {
  // sets is derivable no?
  List<String> programs;

  Programs({
    this.programs,
  });

  void setProgram({
    List<String> programs,
  }) {
    this.programs = programs;
    notifyListeners();
  }

  // update currentSet here .... check it is < sets - 1 etc.

  factory Programs.fromJson(Map<String, dynamic> json) =>
      _$ProgramsFromJson(json);

  Map<String, dynamic> toJson() => _$ProgramsToJson(this);

  //@override
  List<Object> get props => [
        programs,
      ];
}
