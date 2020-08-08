import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

//TODO: implement dispose
class LifterWeightsController {
  updatePlates(BuildContext context) {
    //TODO: implement, updload to cloud
  }
  updateBarWeight(BuildContext context, int newBarWeight) {
    var liftweights = Provider.of<LifterWeights>(context, listen: false);
    liftweights.updateBarWeight(newBarWeight);
  }
}

class LiftMaxController {
  //TODO: you'd update the database not just set the local val....
  updateMax({BuildContext context, String lift, int newMax}) {
    var liftMaxes = Provider.of<LiftMaxes>(context, listen: false);
    switch (lift) {
      case "deadlift":
        liftMaxes.deadliftMax = newMax;
        break;
      case "bench":
        liftMaxes.benchMax = newMax;
        break;
      case "press":
        liftMaxes.pressMax = newMax;
        break;
      case "squat":
        liftMaxes.squatMax = newMax;
        break;
    }
  }
}
