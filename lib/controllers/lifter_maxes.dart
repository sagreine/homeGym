import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';

import 'package:provider/provider.dart';
import 'package:home_gym/controllers/controllers.dart';

class LifterMaxesController {
  void update1RepMax({BuildContext context, String lift, int newMax}) {
    var thisMaxes = Provider.of<LifterMaxes>(context, listen: false);
    thisMaxes.updateMax(lift, newMax);
  }

  //TODO: you'd update the database not just set the local val....
  updateMax({BuildContext context, String lift, int newMax}) {
    var liftMaxes = Provider.of<LifterMaxes>(context, listen: false);
    bool updateCloud = false;
    // check if this is indeed a new max. if so, update it and the cloud copy.
    switch (lift) {
      case "deadlift":
        if (liftMaxes.deadliftMax != newMax) {
          liftMaxes.deadliftMax = newMax;
          updateCloud = true;
        }
        break;
      case "bench":
        if (liftMaxes.benchMax != newMax) {
          liftMaxes.benchMax = newMax;
          updateCloud = true;
        }
        break;
      case "press":
        if (liftMaxes.pressMax != newMax) {
          liftMaxes.pressMax = newMax;
          updateCloud = true;
        }
        break;
      case "squat":
        if (liftMaxes.squatMax != newMax) {
          liftMaxes.squatMax = newMax;
          updateCloud = true;
        }
        break;
    }
    if (updateCloud) {
      update1RepMaxCloud(lift, newMax);
    }
    // call (perhaps not implemented yet) cloud update liftMax function - that'd be if the max both wasn't null and is now different.
  }
}
