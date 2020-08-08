import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

//TODO: implement dispose
class ExerciseDayController {
  updateDay(BuildContext context, List<int> reps, List<double> percentages,
      double trainingMaxPct) {
    var day = Provider.of<ExerciseDay>(context, listen: false);
    day.buildDay(
        currentSet: 0,
        reps: reps,
        percentages: percentages,
        sets: reps.length,
        trainingMax: trainingMaxPct);
  }

  nextSet(BuildContext context) {
    var day = Provider.of<ExerciseDay>(context, listen: false);
    day.nextSet();
  }
}
