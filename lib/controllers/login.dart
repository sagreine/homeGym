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
}
