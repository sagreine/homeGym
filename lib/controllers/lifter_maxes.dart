import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';

import 'package:provider/provider.dart';
import 'package:home_gym/controllers/controllers.dart';

class LifterMaxesController {
  //TODO: compare if this is different from the cloud value as we currently see it before making a call...
  update1RepMax(
      { // this seems stupid and we should pass the object in.
      @required BuildContext context,
      @required String lift,
      int newMax,
      bool updateCloud = false,
      @required bool progression}) {
    // this is not how we want to do this and it wouldn't print but sure
    assert(progression == true || newMax != null);
    /*{
      print(
          "You have to either progress or explicitly state the new max. ERROR");
    }*/
// get this so we can read from and update the local
    var liftMaxes = Provider.of<LifterMaxes>(context, listen: false);
    var user = Provider.of<Muser>(context, listen: false);

    // check if this is indeed a new max. if so, update it and the cloud copy.
// business rules dictate maximum increases by exercise type under progression circumstance
    switch (lift.toLowerCase()) {
      case "deadlift":
        // jeepers if we aren't copying and pasting a lottt of readily parameterizeable code....
        // if this is a vanilla progression, they can specify a smaller-than-typical progression or not. plus, need to handle
        // dev error
        if (progression) {
          // if they gave a newMax, it either is valid or is not
          if (newMax != null) {
            if (newMax <= liftMaxes.deadliftMax + 10) {
              liftMaxes.updateMax(lift, newMax);
            } else {
              print(
                  "You can't increase it this much under progression. You're using the wrong function parameters");
            }
            // if they didn't, this is just vanilla progression
          } else {
            liftMaxes.updateMax(lift, liftMaxes.deadliftMax + 10);
            liftMaxes = Provider.of<LifterMaxes>(context, listen: false);
            newMax = liftMaxes.deadliftMax;
          }
          //if this is not progression at all, just update to the new max
        } else {
          liftMaxes.updateMax(lift.toLowerCase(), newMax);
        }
        break;
      case "bench":
        // if this is a vanilla progression, they can specify a smaller-than-typical progression or not. plus, need to handle
        // dev error
        if (progression) {
          // if they gave a newMax, it either is valid or is not
          if (newMax != null) {
            if (newMax <= liftMaxes.benchMax + 5) {
              liftMaxes.updateMax(lift, newMax);
            } else {
              print(
                  "You can't increase it this much under progression. You're using the wrong function parameters");
            }
            // if they didn't, this is just vanilla progression
          } else {
            liftMaxes.updateMax(lift, liftMaxes.benchMax + 5);
            liftMaxes = Provider.of<LifterMaxes>(context, listen: false);
            newMax = liftMaxes.benchMax;
          }
          //if this is not progression at all, just update to the new max
        } else {
          liftMaxes.updateMax(lift.toLowerCase(), newMax);
        }
        break;
      case "press":
        // if this is a vanilla progression, they can specify a smaller-than-typical progression or not. plus, need to handle
        // dev error
        if (progression) {
          // if they gave a newMax, it either is valid or is not
          if (newMax != null) {
            if (newMax <= liftMaxes.pressMax + 5) {
              liftMaxes.updateMax(lift, newMax);
            } else {
              print(
                  "You can't increase it this much under progression. You're using the wrong function parameters");
            }
            // if they didn't, this is just vanilla progression
          } else {
            liftMaxes.updateMax(lift, liftMaxes.pressMax + 5);
            liftMaxes = Provider.of<LifterMaxes>(context, listen: false);
            newMax = liftMaxes.pressMax;
          }
          //if this is not progression at all, just update to the new max
        } else {
          liftMaxes.updateMax(lift.toLowerCase(), newMax);
        }
        break;
      case "squat":
        // if this is a vanilla progression, they can specify a smaller-than-typical progression or not. plus, need to handle
        // dev error
        if (progression) {
          // if they gave a newMax, it either is valid or is not
          if (newMax != null) {
            if (newMax <= liftMaxes.squatMax + 10) {
              liftMaxes.updateMax(lift, newMax);
            } else {
              print(
                  "You can't increase it this much under progression. You're using the wrong function parameters");
            }
            // if they didn't, this is just vanilla progression
          } else {
            liftMaxes.updateMax(lift, liftMaxes.squatMax + 10);
            liftMaxes = Provider.of<LifterMaxes>(context, listen: false);
            newMax = liftMaxes.squatMax;
          }
          //if this is not progression at all, just update to the new max
        } else {
          liftMaxes.updateMax(lift.toLowerCase(), newMax);
        }
        break;
    }
    if (updateCloud) {
      update1RepMaxCloud(
          lift: lift, newMax: newMax, userID: user.fAuthUser.uid);
    }
    // call (perhaps not implemented yet) cloud update liftMax function - that'd be if the max both wasn't null and is now different.
  }
}
