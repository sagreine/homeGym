import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';

import 'package:provider/provider.dart';
import 'package:home_gym/controllers/controllers.dart';

//TODO: implement dispose
class LifterWeightsController {
  TextEditingController barWeightTextController = new TextEditingController();

  void updatePlate(
      {@required BuildContext context,
      @required double plate,
      @required int plateCount}) {
    var liftweights = Provider.of<LifterWeights>(context, listen: false);
    var user = Provider.of<Muser>(context, listen: false);
    if (liftweights.updatePlate(plate: plate, plateCount: plateCount)) {
      updatePlateCloud(
          plate: plate, plateCount: plateCount, userID: user.firebaseUser.uid);
    }
  }

  void updateBumpers({@required BuildContext context, @required bool bumpers}) {
    var liftweights = Provider.of<LifterWeights>(context, listen: false);
    var user = Provider.of<Muser>(context, listen: false);
    if (liftweights.updateBumpers(bumpers: bumpers)) {
      updateBumpersCloud(bumpers: bumpers, userID: user.firebaseUser.uid);
    }
  }

  void updateBarWeight(BuildContext context, int newBarWeight) {
    var liftweights = Provider.of<LifterWeights>(context, listen: false);
    var user = Provider.of<Muser>(context, listen: false);
    liftweights.updateBarWeight(newBarWeight);
    updateBarWeightCloud(
        newWeight: newBarWeight, userID: user.firebaseUser.uid);
  }

  //String pickPlates({BuildContext context, int targetWeight}) {
  //var liftweights = Provider.of<LifterWeights>(context, listen: false);
  //return liftweights.pickPlates(targetWeight: targetWeight).platesAsStrings();
  //}
}
