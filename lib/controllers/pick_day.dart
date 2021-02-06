import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/controllers/cloud.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:provider/provider.dart';

class PickDayController {
  // this is an obviously bad idea and should not be here - > user the staticlly available enum.
  //List<String> exercises = ["Squat", "Deadlift", "Bench", "Press"];
  List<bool> selectedExercise = [false, false, false, false];
  bool readyToGo = false;

  TextEditingController programController = TextEditingController();
  // TODO: not currently used for anythin.
  TextEditingController weekController = TextEditingController();
  TextEditingController tmController = TextEditingController();

  ExerciseDayController exerciseDayController = ExerciseDayController();

  void updateReadyToGo(context) {
    var model = Provider.of<PickDay>(context, listen: false);
    if (model.pickedProgram.program != null &&
        (selectedExercise.any((element) => element) ||
            !model.pickedProgram.isMainLift) &&
        model.pickedProgram.week != null) {
      readyToGo = true;
    } else {
      readyToGo = false;
    }
  }

  void pickExercise(int index, context) {
    // if it's already selected, deselect it
    if (selectedExercise[index]) {
      selectedExercise[index] = false;
    } else {
      // unselect all and select the new one
      selectedExercise.setAll(0, [false, false, false, false]);
      selectedExercise[index] = true;
    }
    updateReadyToGo(context);
  }

  Future<void> pickProgram(BuildContext context) async {
    var model = Provider.of<PickDay>(context, listen: false);
    // launch the page to pick them, return it when done
    /// - do this more safely obviously. if they OS-back button this goes badly.
    /// // can't just do a vanilla push named because we're returning a non primitive object
    final _pickedProgram = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgramsView(),
      ),
    );
    // update the page we're on now
    if (_pickedProgram != null) {
      model.updatePickedProgram(_pickedProgram);
      // unselect the main lift if there is no more main lift.
      if (!_pickedProgram.isMainLift) {
        selectedExercise.setAll(0, [false, false, false, false]);
      }

      programController.text = _pickedProgram.program;
      tmController.text = _pickedProgram.trainingMaxPct
          .toString(); //exerciseDay.trainingMax.toString();
      // or just... do actual state management...
      updateReadyToGo(context);
    }
  }

  Future<void> getExercises(BuildContext context, PickedProgram program,
      int week, bool isCustom) async {
    var userID;
    if (isCustom) {
      userID =
          Provider.of<Muser>(context, listen: false).fAuthUser.uid.toString();
    }
    await getExercisesCloud(
        context: context,
        program: program,
        week: week,
        isCustom: isCustom,
        userID: userID);
  }

  // launch the day, which is program and exercise
  // not sure we care about context here?
  void launchDay(BuildContext context, bool isCustom) async {
    // update our exercise to the selected day.
    // this should be done only by the controller.
    // also the order of this matters and it must run before the query below (which is very dumb)
    var exerciseDay = Provider.of<ExerciseDay>(context, listen: false);
    var model = Provider.of<PickDay>(context, listen: false);
    // this sets our "main" lift to hte one selected
    // TODO this needs to be handled only for 'Main' lift days once that is implemented...
    if (model.pickedProgram.isMainLift) {
      exerciseDay.lift = ReusableWidgets
          .lifts[selectedExercise.indexWhere((element) => element)];
    }
    /*else {
      exerciseDay.lift = "Squat";
    }*/

    // if (tmController.text != null && tmController.text.length != 0) {
    //exerciseDay.trainingMax = double.tryParse(tmController.text) / 100;

    //// THIS IS NECESSARY RIGHT NOW BECAUSE OF HOW THIS FLOWS THROUGH. IT WONT B SET OTHERWISE
    /// AND YOU WILL GET AN ERROR TRYING TO HIT ON NULL
    exerciseDay.trainingMax = model.pickedProgram.trainingMaxPct / 100;
    //}
    // TODO need to make this owrk for custom...
    await getExercises(
        context, model.pickedProgram, model.pickedProgram.week, isCustom);

    // if we overrode the %TM percentage, update that here - need to do erro control here...

    // only allow this to be a progress week if:
    // 1) the program allows progression at all and
    // 2) this is the last week of the program
    ///// orrrrrr just specify this in the db as a week to do so...
    exerciseDay.updateMaxIfGetReps = (exerciseDay.updateMaxIfGetReps &&
        model.pickedProgram.potentialProgressWeek);

    // at this point we've set the week-level variable to false, need to set it to false for each
    // day element as well for safety (also i stupidly made this a requirement later..)
    if (exerciseDay.updateMaxIfGetReps == false) {
      exerciseDay.exercises.forEach((element) {
        element.thisSetProgressSet = false;
      });
    }

    /*
    exerciseController.updateExercise(
        context: context,
        exerciseTitle:
            exercises[selectedExercise.indexWhere((element) => element)]);
            */
    //Navigator.pushNamed(context, '/do_lift');
    //Navigator.pushNamed(context, '/excerciseday');
    Navigator.pushNamed(context, '/today', arguments: model.pickedProgram);
  }
}
