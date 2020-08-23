import 'package:flutter/material.dart';
import 'package:home_gym/controllers/cloud.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

class LoginController {
  void getBarWeight(BuildContext context) async {
    var liftweights = Provider.of<LifterWeights>(context, listen: false);
    liftweights.barWeight = await getBarWeightCloud();
    print("new bar weight: $liftweights.barWeight");
  }

  void getMaxes(BuildContext context) async {
    getMaxesCloud(context);
  }

  // very stupid. rearrange db organization instead of doing this.
  void getPlates(BuildContext context) async {
    getPlatesCloud(context);
  }
}
