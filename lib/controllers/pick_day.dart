import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/controllers/cloud.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/views/views.dart';

class PickDayController {
  // this is an obviously bad idea
  List<String> exercises = ["Squat", "Deadlift", "Bench", "Press"];
  List<bool> selectedExercise = [false, false, false, false];
  bool readyToGo = false;
  String selectedProgram;
  TextEditingController programController = TextEditingController();

  ExerciseDayController exerciseDayController = ExerciseDayController();

  void updateReadyToGo() {
    if (selectedProgram != null && selectedExercise.any((element) => element)) {
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

// TODO: review this, async is messing up if you pick exercise then pick program, or Go button isn't being refreshed at least on the first itme thorugh
  Future<void> pickProgram(BuildContext context) async {
    // launch the page to pick them, return it when done
    /// - do this more safely obviously. if they OS-back button this goes badly.
    String temp = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Programs()));
    // update the page we're on now
    if (temp != null) {
      selectedProgram = temp;
      programController.text = selectedProgram;
      // or just... do actual state management...
      updateReadyToGo();
    }
  }

  Future<void> getExercises(BuildContext context, String program) async {
    await getExercisesCloud(context, program);
  }

  // launch the day, which is program and exercise
  // not sure we care about context here?
  void launchDay(BuildContext context) async {
    await getExercises(context, selectedProgram);
    ExerciseController exerciseController = ExerciseController();
    exerciseController.updateExercise(
        context: context,
        exerciseTitle:
            exercises[selectedExercise.indexWhere((element) => element)]);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Home(
                program: selectedProgram,
                exercise: exercises[
                    selectedExercise.indexWhere((element) => element)])));
  }
}
