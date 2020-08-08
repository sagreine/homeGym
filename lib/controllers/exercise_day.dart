import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

class ExerciseDayController {
  updateDay(BuildContext context, List<int> reps, List<double> percentages) {
    var day = Provider.of<ExerciseDay>(context, listen: false);
    day.buildDay(
        currentSet: 0, reps: reps, percentages: percentages, sets: reps.length);
  }

  nextSet(BuildContext context) {
    var day = Provider.of<ExerciseDay>(context, listen: false);
    day.nextSet();
  }
}
