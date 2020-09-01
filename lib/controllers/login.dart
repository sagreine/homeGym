import 'package:flutter/material.dart';
import 'package:home_gym/controllers/cloud.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

class LoginController {
  void getBarWeight(BuildContext context) async {
    var liftweights = Provider.of<LifterWeights>(context, listen: false);
    var user = Provider.of<Muser>(context, listen: false);

    liftweights.updateBarWeight(
        await getBarWeightCloud(userID: user.firebaseUser.uid));
    print("new bar weight: $liftweights.barWeight");
  }

  void getMaxes(BuildContext context) async {
    var user = Provider.of<Muser>(context, listen: false);
    getMaxesCloud(context: context, userID: user.firebaseUser.uid);
  }

  // very stupid. rearrange db organization instead of doing this.
  void getPlates(BuildContext context) async {
    var user = Provider.of<Muser>(context, listen: false);
    getPlatesCloud(context: context, userID: user.firebaseUser.uid);
  }
}
