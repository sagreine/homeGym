import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
//import 'package:json_annotation/json_annotation.dart';

// TODO there's a lot of duplication here because we built these at different times.
// basically, every function can just pick currentPRs or Allprs not a function for each..

class Pr {
  String lift;
  int reps;
  //int prescribedReps;
  int weight;
  DateTime dateTime;

  Pr({this.reps, this.weight, this.dateTime, this.lift});
}

// TODO: just use a map of list<pr> ...
class Prs extends ChangeNotifier {
  //List<Pr> prsRep;
  //List<Pr> prsWeight;
  Map<String, List<Pr>> currentPrs;
  Map<String, List<Pr>> allPrs;

  Prs({this.currentPrs, this.allPrs});

  List<Object> get props => [currentPrs, allPrs];

  Map<String, Pr> bothLocalExistingPR({ExerciseSet lift}) {
    Map<String, Pr> toReturn = Map<String, Pr>();
    toReturn["Rep"] = _getExistingRepPR(lift);
    toReturn["Weight"] = _getExistingWeightPR(lift);
    return toReturn;
  }

  clearLocalPRs() {
    allPrs?.clear();
    currentPrs?.clear();
    allPrs = null;
    currentPrs = null;
  }

  Map<String, List<Pr>> bothLocalAllPR(
      {String liftTitle, @required Map<String, List<Pr>> prs}) {
    Map<String, List<Pr>> toReturn = Map<String, List<Pr>>();
    toReturn["Rep"] =
        _getExistingAllPR(liftTitle: liftTitle, isRep: true, prs: prs);
    toReturn["Weight"] =
        _getExistingAllPR(liftTitle: liftTitle, isRep: false, prs: prs);
    return toReturn;
  }

  _getExistingAllPR(
      {@required String liftTitle,
      @required bool isRep,
      @required Map<String, List<Pr>> prs}) {
    List<Pr> repOrWeight = prs[isRep ? "Rep" : "Weight"];

    return repOrWeight.where((element) => element.lift == liftTitle).toList();

    /*[
      allPrs[isRep ? "Rep" : "Weight"]
          .indexWhere((element) => element.lift == liftTitle)
    ];*/
  }

  _getExistingRepPR(ExerciseSet lift) {
    return _getExistingPR(lift: lift, isRep: true);
  }

  _getExistingWeightPR(ExerciseSet lift) {
    return _getExistingPR(lift: lift, isRep: false);
  }

  Pr _getExistingPR({ExerciseSet lift, bool isRep}) {
    var index = _getExistingPRIndex(lift: lift, isRep: isRep);
    if (index == -1) {
      return Pr(dateTime: DateTime.now(), weight: 0, reps: 0);
    } else {
      return currentPrs[isRep ? "Rep" : "Weight"][index];
    }
  }

  _getExistingPRIndex({ExerciseSet lift, bool isRep}) {
    /*var prs;
    if (isRep) {
      prs = prsRep;
    } else {
      prs = prsWeight;
    }*/
    if (currentPrs == null || currentPrs[isRep ? "Rep" : "Weight"] == null) {
      return -1;
    }
    return currentPrs[isRep ? "Rep" : "Weight"].indexWhere((element) =>
        (isRep ? element.reps == lift.reps : element.weight == lift.weight) &&
        element.lift == lift.title);
  }

/*
  // note that there is no "both" here. that is intentional
  // we don't want callers to have to check that a lift is both a Rep max and a Weight max
  // and if they do they can just call each of them..

  setRepPR(
      {@required context,
      @required String userId,
      @required ExerciseSet lift}) {
    _setPR(context: context, userId: userId, lift: lift, isRep: true);
  }

  setWeightPR(
      {@required context,
      @required String userId,
      @required ExerciseSet lift}) {
    _setPR(context: context, userId: userId, lift: lift, isRep: false);
  }
*/
  // this is done very stupidly and from pointer thinking.
  setPR(
      {@required context,
      @required String userId,
      @required ExerciseSet lift,
      @required bool isRep}) {
    var thisPRIndex;
    /*var prs;
    if (isRep) {
      prs = prsRep;
    } else {
      prs = prsWeight;
    }*/
    if (currentPrs == null) {
      currentPrs = Map<String, List<Pr>>();
    }
    if (currentPrs[isRep ? "Rep" : "Weight"] == null) {
      currentPrs[isRep ? "Rep" : "Weight"] = List<Pr>();
    }
    thisPRIndex = _getExistingPRIndex(lift: lift, isRep: isRep);
    if (thisPRIndex == -1) {
      currentPrs[isRep ? "Rep" : "Weight"].add(Pr(
        reps: lift.reps,
        //prescribedReps: lift.prescribedReps,
        weight: lift.weight,
        dateTime: lift.dateTime,
        lift: lift.title,
      ));
    } else {
      currentPrs[isRep ? "Rep" : "Weight"][thisPRIndex].lift = lift.title;
      //currentPrs[isRep ? "Rep" : "Weight"][thisPRIndex].prescribedReps = lift.prescribedReps;
      currentPrs[isRep ? "Rep" : "Weight"][thisPRIndex].weight = lift.weight;
      currentPrs[isRep ? "Rep" : "Weight"][thisPRIndex].dateTime =
          lift.dateTime;
    }
    // the safety placeholder can be removed at this point.
    if (currentPrs[isRep ? "Rep" : "Weight"][0].reps == 0) {
      currentPrs[isRep ? "Rep" : "Weight"].removeAt(0);
    }
    /*if (isRep) {
      prsRep = prs;
    } else {
      prsWeight = prs;
    }*/
    notifyListeners();
  }

// this is not needed because we're pulling from separate tables for Rep, Weight.
/*
  void createOrPopulateBothCurrentPrs ({List<Pr> squatPRs,
      List<Pr> pressPRs,
      List<Pr> deadliftPRs,
      List<Pr> benchPRs,}) {
        _createOrPopulateCurrentPrsRep(benchPRs: benchPRs, squatPRs: squatPRs, pressPRs: pressPRs, deadliftPRs: deadliftPRs);
        _createOrPopulateCurrentPrsWeight(benchPRs: benchPRs, squatPRs: squatPRs, pressPRs: pressPRs, deadliftPRs: deadliftPRs);
  }*/
  /*
  void createOrPopulateCurrentPrsRep({
    List<Pr> squatPRs,
    List<Pr> pressPRs,
    List<Pr> deadliftPRs,
    List<Pr> benchPRs,
  }) {
    _createOrPopulateCurrentPrs(
        benchPRs: benchPRs,
        squatPRs: squatPRs,
        deadliftPRs: deadliftPRs,
        pressPRs: pressPRs,
        isRep: true);
    _createOrPopulateCurrentPrs(
        benchPRs: benchPRs,
        squatPRs: squatPRs,
        deadliftPRs: deadliftPRs,
        pressPRs: pressPRs,
        isRep: false);
  }

  void createOrPopulateCurrentPrsWeight({
    List<Pr> squatPRs,
    List<Pr> pressPRs,
    List<Pr> deadliftPRs,
    List<Pr> benchPRs,
  }) {
    _createOrPopulateCurrentPrs(
        benchPRs: benchPRs,
        squatPRs: squatPRs,
        deadliftPRs: deadliftPRs,
        pressPRs: pressPRs,
        isRep: false);
    _createOrPopulateCurrentPrs(
        benchPRs: benchPRs,
        squatPRs: squatPRs,
        deadliftPRs: deadliftPRs,
        pressPRs: pressPRs,
        isRep: true);
  }*/
  void createOrPopulateAllPrs({List<Pr> repPrs, List<Pr> weightPrs}) {
    if (allPrs == null) {
      allPrs = Map<String, List<Pr>>();
      allPrs["Rep"] = List<Pr>();
      allPrs["Weight"] = List<Pr>();
    }
    if (repPrs != null) {
      allPrs["Rep"].addAll(repPrs);
    }
    if (weightPrs != null) {
      allPrs["Weight"].addAll(weightPrs);
    }
  }

  //TODO: this is terribly named
  void createOrPopulateCurrentPrs(
      {List<Pr> squatPRs,
      List<Pr> pressPRs,
      List<Pr> deadliftPRs,
      List<Pr> benchPRs,
      @required bool isRep}) {
    /*var prs;
    if (isRep) {
      prsRep = prs;
    } else {
      prsWeight = prs;
    }*/
    if (currentPrs == null) {
      currentPrs = Map<String, List<Pr>>();
    }
    if (currentPrs[isRep ? "Rep" : "Weight"] == null) {
      currentPrs[isRep ? "Rep" : "Weight"] = List<Pr>();
    }
    if (squatPRs != null) {
      currentPrs[isRep ? "Rep" : "Weight"].addAll(squatPRs);
    }
    if (pressPRs != null) {
      currentPrs[isRep ? "Rep" : "Weight"].addAll(pressPRs);
    }
    if (deadliftPRs != null) {
      currentPrs[isRep ? "Rep" : "Weight"].addAll(deadliftPRs);
    }
    if (benchPRs != null) {
      currentPrs[isRep ? "Rep" : "Weight"].addAll(benchPRs);
    }
    /*
    if (isRep) {
      prsRep = prs;
    } else {
      prsWeight = prs;
    }*/
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
