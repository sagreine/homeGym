import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:json_annotation/json_annotation.dart';

class Pr {
  String lift;
  int reps;
  int weight;
  DateTime dateTime;

  Pr({this.reps, this.weight, this.dateTime, this.lift});
}

class Prs extends ChangeNotifier {
  List<Pr> prs;

  _getExistingPRIndex({ExerciseSet lift, bool isRep}) {
    return prs.indexWhere((element) =>
        (isRep ? element.reps == lift.reps : element.weight == lift.weight) &&
        element.lift == lift.title);
  }

  getExistingRepPR(ExerciseSet lift) {
    return _getExistingPR(lift: lift, isRep: true);
  }

  getExistingWeightPR(ExerciseSet lift) {
    return _getExistingPR(lift: lift, isRep: false);
  }

  Pr _getExistingPR({ExerciseSet lift, bool isRep}) {
    var index = _getExistingPRIndex(lift: lift, isRep: isRep);
    if (index == -1) {
      return Pr(dateTime: DateTime.now(), weight: 0, reps: 0);
    } else {
      return prs[index];
    }
  }

  setRepPR(
      {@required context,
      @required String userId,
      @required ExerciseSet lift}) {
    var thisPRIndex;
    if (prs == null) {
      prs = List<Pr>();
    }
    thisPRIndex = _getExistingPRIndex(lift: lift, isRep: true);
    if (thisPRIndex == -1) {
      prs.add(Pr(
        reps: lift.reps,
        weight: lift.weight,
        dateTime: lift.dateTime,
        lift: lift.title,
      ));
    } else {
      prs[thisPRIndex].lift = lift.title;
      prs[thisPRIndex].weight = lift.weight;
      prs[thisPRIndex].dateTime = lift.dateTime;
    }
    // the safety placeholder can be removed at this point.
    if (prs[0].reps == 0) {
      prs.removeAt(0);
    }
    notifyListeners();
  }

  Prs({
    this.prs,
  });

  List<Object> get props => [prs];
  //TODO: this is terribly named
  void getCurrentPrs(
      {List<Pr> squatPRs,
      List<Pr> pressPRs,
      List<Pr> deadliftPRs,
      List<Pr> benchPRs}) {
    if (prs == null) {
      prs = List<Pr>();
    }
    if (squatPRs != null) {
      prs.addAll(squatPRs);
    }
    if (pressPRs != null) {
      prs.addAll(pressPRs);
    }
    if (deadliftPRs != null) {
      prs.addAll(deadliftPRs);
    }
    if (benchPRs != null) {
      prs.addAll(benchPRs);
    }
    /*if (squatPRs == null &&
        pressPRs == null &&
        deadliftPRs == null &&
        benchPRs == null) {
      prs = null;
    }*/
  }

  //factory Prs.fromJson(Map<String, dynamic> json) => _$PrsFromJson(json);

  //Map<String, dynamic> toJson() => _$PrsToJson(this);
}
