import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/controllers/cloud.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:provider/provider.dart';

class PickDayController {
  // this is an obviously bad idea
  List<String> exercises = ["Squat", "Deadlift", "Bench", "Press"];
  List<bool> selectedExercise = [false, false, false, false];
  bool readyToGo = false;
  String selectedProgram;
  int selectedWeek;
  TextEditingController programController = TextEditingController();
  // TODO: not currently used for anythin.
  TextEditingController weekController = TextEditingController();

  ExerciseDayController exerciseDayController = ExerciseDayController();

  void updateReadyToGo() {
    if (selectedProgram != null &&
        selectedExercise.any((element) => element) &&
        selectedWeek != null) {
      readyToGo = true;
    } else {
      readyToGo = false;
    }
  }

  void pickExercise(int index) {
    // if it's already selected, deselect it
    if (selectedExercise[index]) {
      selectedExercise[index] = false;
    } else {
      // unselect all and select the new one
      selectedExercise.setAll(0, [false, false, false, false]);
      selectedExercise[index] = true;
    }
    updateReadyToGo();
  }

  Future<void> pickProgram(BuildContext context) async {
    // launch the page to pick them, return it when done
    /// - do this more safely obviously. if they OS-back button this goes badly.
    /// // can't just do a vanilla push named because we're returning a non primitive object
    final pickedProgram = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgramsView(),
      ),
    );
    // update the page we're on now
    if (pickedProgram != null) {
      selectedProgram = pickedProgram.program;
      selectedWeek = pickedProgram.week;
      programController.text = selectedProgram;
      // or just... do actual state management...
      updateReadyToGo();
    }
  }

  Future<void> getExercises(
      BuildContext context, String program, int week) async {
    await getExercisesCloud(context: context, program: program, week: week);
  }

  // launch the day, which is program and exercise
  // not sure we care about context here?
  void launchDay(BuildContext context) async {
    // update our exercise to the selected day.
    // this should be done only by the controller.
    // also the order of this matters and it must run before the query below (which is very dumb)
    var exerciseDay = Provider.of<ExerciseDay>(context, listen: false);
    exerciseDay.lift =
        exercises[selectedExercise.indexWhere((element) => element)];

    await getExercises(context, selectedProgram, selectedWeek);

    /*
    exerciseController.updateExercise(
        context: context,
        exerciseTitle:
            exercises[selectedExercise.indexWhere((element) => element)]);
            */
    //Navigator.pushNamed(context, '/do_lift');
    //Navigator.pushNamed(context, '/excerciseday');
    Navigator.pushNamed(context, '/today');
  }
}
