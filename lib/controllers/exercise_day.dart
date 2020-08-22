import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

//TODO: implement dispose
class ExerciseDayController {
  updateDay(
      {BuildContext context,
      String program,
      List<int> reps,
      List<double> percentages,
      double trainingMaxPct,
      List<String> assistanceCore,
      List<String> assistancePull,
      List<String> assistancePush,
      int assistanceCoreReps,
      int assistancePullReps,
      int assistancePushReps}) {
    var day = Provider.of<ExerciseDay>(context, listen: false);
    day.buildDay(
      program: program,
      currentSet: 0,
      reps: reps,
      percentages: percentages,
      sets: reps.length,
      trainingMax: trainingMaxPct,
      assistanceCore: assistanceCore,
      assistanceCoreReps: assistanceCoreReps,
      assistancePull: assistancePull,
      assistancePullReps: assistancePullReps,
      assistancePush: assistancePush,
      assistancePushReps: assistancePushReps,
    );
  }

  bool nextSet(BuildContext context) {
    var day = Provider.of<ExerciseDay>(context, listen: false);
    return day.nextSet();
  }
}
