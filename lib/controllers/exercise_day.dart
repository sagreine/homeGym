import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

//TODO: implement dispose
class ExerciseDayController {
  updateDay({
    String lift,
    BuildContext context,
    String program,
    List<int> reps,
    List<int> prSets,
    List<double> percentages,
    List<String> lifts,
    double trainingMaxPct,
    /*
    List<String> assistanceCore,
    List<String> assistancePull,
    List<String> assistancePush,
    List<int> assistanceCoreReps,
    List<int> assistancePullReps,
    List<int> assistancePushReps,*/
    bool updateMaxIfGetReps,
    bool prSetWeek,
    int progressSet,
    List<ExerciseSet> exercises,
  }) {
    var day = Provider.of<ExerciseDay>(context, listen: false);
    day.buildDay(
      lift: lift == null ? day.lift : lift,
      updateMaxIfGetReps: updateMaxIfGetReps,
      lifts: lifts,
      program: program,
      currentSet: 0,
      reps: reps,
      percentages: percentages,
      sets: reps.length,
      prSets: prSets,
      /*+
          assistanceCore.length +
          assistancePull.length +
          assistancePush.length*/
      progressSet: progressSet,
      prSetWeek: prSetWeek,
      trainingMax: trainingMaxPct,
      /*
      assistanceCore: assistanceCore,
      assistanceCoreReps: assistanceCoreReps,
      assistancePull: assistancePull,
      assistancePullReps: assistancePullReps,
      assistancePush: assistancePush,
      assistancePushReps: assistancePushReps,
      */
      context: context,
    );
  }

  ExerciseSet nextSet(BuildContext context) {
    var day = Provider.of<ExerciseDay>(context, listen: false);
    day.nextSet();
    return day.exercises[day.currentSet];
  }

  bool areWeOnLastSet(BuildContext context) {
    var day = Provider.of<ExerciseDay>(context, listen: false);
    return day.areWeOnLastSet();
  }

  /*void justDidLastSet(BuildContext context) {
    var day = Provider.of<ExerciseDay>(context, listen: false);
    //day.justDidLastSet();
  }*/
}
