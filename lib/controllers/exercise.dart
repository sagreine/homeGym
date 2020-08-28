import 'package:flutter/material.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

class ExerciseController {
  ExerciseDayController exerciseDayController = ExerciseDayController();
  // may eventually move to ExerciseDay is a collection of ExerciseSet objects...
  // but for now staying away from relational stuff.
  void updateExercise({context, String exerciseTitle}) {
    var exercise = Provider.of<ExerciseSet>(context, listen: false);
    // should be using the controller here instead of doing this...
    // if we passed a title in and there wasn't already a title (that equals this one)
    if (exerciseTitle != null &&
        (exercise.title == null || exercise.title != exerciseTitle)) {
      exercise.title = exerciseTitle;
    }
    var thisDay = Provider.of<ExerciseDay>(context, listen: false);
    var thisMax = Provider.of<LiftMaxes>(context, listen: false);
    // would, when needed, listen because if we update the bar weight we want this update. look into more though.
    var thisWeights = Provider.of<LifterWeights>(context, listen: false);
    double trainingMax;
    switch (exercise.title.toLowerCase()) {
      case "deadlift":
        trainingMax = (thisMax.deadliftMax.toDouble() * thisDay.trainingMax);
        break;
      case "bench":
        trainingMax = (thisMax.benchMax.toDouble() * thisDay.trainingMax);
        break;
      case "press":
        trainingMax = (thisMax.pressMax.toDouble() * thisDay.trainingMax);
        break;
      case "squat":
        trainingMax = (thisMax.squatMax.toDouble() * thisDay.trainingMax);
        break;
    }
    double targetWeight =
        ((thisDay.percentages[thisDay.currentSet]) * trainingMax);

    exercise.updateExercise(
      // reps is a straight pull
      reps: thisDay.reps[thisDay.currentSet],
      weight: targetWeight.toInt(),
      description: "Weight each side: " +
          (thisWeights.pickPlates(targetWeight: targetWeight)[0])
              .round()
              .toString() +
          nextExercise(context),
    );
    //formControllerTitle
    //formControllerDescription.text = exercise.description;
    //formControllerReps.text = exercise.reps.toString();
    //formControllerWeight.text = exercise.weight.toString();

    // this is a hack for now.
  }

// this is gross. don't advance and return frippery
  String nextExercise(BuildContext context) {
    if (!exerciseDayController.nextSet(context)) {
      return " - Last Set";
    }
    return "";
  }
}
