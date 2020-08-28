import 'package:flutter/material.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

class SettingsController {
  TextEditingController barWeightTextController = new TextEditingController();
  FlingController flingController = FlingController();
  LiftMaxController liftMaxController = LiftMaxController();
  LifterWeightsController lifterWeightsController = LifterWeightsController();

  void updatePlateCount({BuildContext context, double plate, int newCount}) {
    var thisWeights = Provider.of<LifterWeights>(context, listen: false);
    thisWeights.plates[plate] = newCount;
    updatePlateCloud(plate, newCount);
  }

  void update1RepMax({BuildContext context, String lift, int newMax}) {
    var thisMaxes = Provider.of<LiftMaxes>(context, listen: false);
    thisMaxes.updateMax(lift, newMax);
    update1RepMaxCloud(lift, newMax);
  }
}
