import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';

import 'package:provider/provider.dart';
import 'package:home_gym/controllers/controllers.dart';

//TODO: implement dispose
class LifterWeightsController {
  void updatePlate(BuildContext context, double plate, int _plateCount) {
    var liftweights = Provider.of<LifterWeights>(context, listen: false);
    if (liftweights.updatePlate(plate, _plateCount)) {
      updatePlateCloud(plate, _plateCount);
    }
  }

  void updateBarWeight(BuildContext context, double newBarWeight) {
    var liftweights = Provider.of<LifterWeights>(context, listen: false);
    liftweights.updateBarWeight(newBarWeight);
    updateBarWeightCloud(newBarWeight);
  }

  List<double> pickPlates({BuildContext context, double targetWeight}) {
    var liftweights = Provider.of<LifterWeights>(context, listen: false);
    return liftweights.pickPlates(targetWeight: targetWeight);
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
