import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';

import 'package:provider/provider.dart';
import 'package:home_gym/controllers/controllers.dart';

//TODO: implement dispose
class LifterWeightsController {
  TextEditingController barWeightTextController = new TextEditingController();

  void updatePlate({BuildContext context, double plate, int plateCount}) {
    var liftweights = Provider.of<LifterWeights>(context, listen: false);
    if (liftweights.updatePlate(plate: plate, plateCount: plateCount)) {
      updatePlateCloud(plate, plateCount);
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
