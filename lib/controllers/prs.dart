import 'package:flutter/material.dart';
import 'package:home_gym/controllers/cloud.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

class PrsController {
  _setPR(
      {@required context, @required ExerciseSet lift, @required bool isRep}) {
    var prs = Provider.of<Prs>(context, listen: false);
    var user = Provider.of<Muser>(context, listen: false);
    // first update locally
    prs.setPR(
        context: context, userId: user.fAuthUser.uid, lift: lift, isRep: isRep);
    // then tell the cloud about this, which updates current and adds to historical
    setPRCloud(
        context: context, userId: user.fAuthUser.uid, lift: lift, isRep: isRep);
  }

  Future<bool> setPotentialPR(
      {@required context, @required ExerciseSet lift, @required isRep}) async {
    var prs = Provider.of<Prs>(context, listen: false);

    // we only set PRs for the main lifts.
    var list = ["squat", "press", "deadlift", "bench"];
    var index = list.indexOf(lift.title.toLowerCase());
    if (index == -1) {
      return false;
    }

    Pr currentPR = prs.bothLocalPR(lift: lift)[isRep ? "Rep" : "Weight"];
    // getExistingRepPR(lift);
    if ((isRep && currentPR.weight < lift.weight) ||
        (!isRep && currentPR.reps < lift.reps)) {
      _setPR(context: context, lift: lift, isRep: isRep);
      return true;
    }
    return false;
    //setWeightPR();
  }

/*
  Future<QuerySnapshot> getWhereQueriedPRsCloud(
    {@required context,
    @required String userID,
    @required String lift,
    @required String query}) async {
      */

/*
Future<List<int>> getCurrentPRsCloud(
    {@required context, @required String userID, @required String lift}) async {
*/

/*

Future<void> setPRCloud(
    {@required context,
    @required String userID,
    @required ExerciseSet lift}) async {

      */
}
