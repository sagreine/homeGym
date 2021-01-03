import 'package:flutter/material.dart';
import 'package:home_gym/controllers/cloud.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

class LoginController {
  void getBarWeights(BuildContext context) async {
    var liftweights = Provider.of<LifterWeights>(context, listen: false);
    var user = Provider.of<Muser>(context, listen: false);

    liftweights.updateBarWeight(
        newWeight:
            await getBarWeightCloud(userID: user.fAuthUser.uid, lift: "Press"),
        lift: "Press");

    liftweights.updateBarWeight(
        newWeight:
            await getBarWeightCloud(userID: user.fAuthUser.uid, lift: "Squat"),
        lift: "Squat");

    liftweights.updateBarWeight(
        newWeight: await getBarWeightCloud(
            userID: user.fAuthUser.uid, lift: "Deadlift"),
        lift: "Deadlift");
    liftweights.updateBarWeight(
        newWeight:
            await getBarWeightCloud(userID: user.fAuthUser.uid, lift: "Bench"),
        lift: "Bench");
  }

  void getMaxes(BuildContext context) async {
    var user = Provider.of<Muser>(context, listen: false);
    getMaxesCloud(context: context, userID: user.fAuthUser.uid);
  }

  // very stupid. rearrange db organization instead of doing this.
  void getPlates(BuildContext context) async {
    var user = Provider.of<Muser>(context, listen: false);
    getPlatesCloud(context: context, userID: user.fAuthUser.uid);
  }

  void getPRs(BuildContext context) async {
    var user = Provider.of<Muser>(context, listen: false);
    var prs = Provider.of<Prs>(context, listen: false);
    prs.createOrPopulateCurrentPrs(
        squatPRs: await getCurrentRepsPRsCloud(
            context: context,
            userId: user.fAuthUser.uid,
            lift: "Squat",
            isRep: false),
        pressPRs: await getCurrentRepsPRsCloud(
            context: context,
            userId: user.fAuthUser.uid,
            lift: "Press",
            isRep: false),
        deadliftPRs: await getCurrentRepsPRsCloud(
            context: context,
            userId: user.fAuthUser.uid,
            lift: "Deadlift",
            isRep: false),
        benchPRs: await getCurrentRepsPRsCloud(
            context: context,
            userId: user.fAuthUser.uid,
            lift: "Bench",
            isRep: false),
        isRep: false);
    prs.createOrPopulateCurrentPrs(
        squatPRs: await getCurrentRepsPRsCloud(
            context: context,
            userId: user.fAuthUser.uid,
            lift: "Squat",
            isRep: true),
        pressPRs: await getCurrentRepsPRsCloud(
            context: context,
            userId: user.fAuthUser.uid,
            lift: "Press",
            isRep: true),
        deadliftPRs: await getCurrentRepsPRsCloud(
            context: context,
            userId: user.fAuthUser.uid,
            lift: "Deadlift",
            isRep: true),
        benchPRs: await getCurrentRepsPRsCloud(
            context: context,
            userId: user.fAuthUser.uid,
            lift: "Bench",
            isRep: true),
        isRep: true);
    // get all prs, once we have something to do with them (graph etc.)
    /*prs.createOrPopulateAllPrsWeight(
      squatPRs: await getCurrentPRsCloud(
          context: context, userId: user.fAuthUser.uid, lift: "Squat"),
      pressPRs: await getCurrentPRsCloud(
          context: context, userId: user.fAuthUser.uid, lift: "Press"),
      deadliftPRs: await getCurrentPRsCloud(
          context: context, userId: user.fAuthUser.uid, lift: "Deadlift"),
      benchPRs: await getCurrentPRsCloud(
          context: context, userId: user.fAuthUser.uid, lift: "Bench"),
    );*/
  }
}
