import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/controllers/cloud.dart';
import 'package:home_gym/views/views.dart';

class PickDayController {
  // this is an obviously bad idea
  List<String> exercises = ["Squat", "Deadlift", "Bench", "Press"];
  List<bool> selectedExercise = [false, false, false, false];
  bool readyToGo = false;
  String selectedProgram;
  TextEditingController programController = TextEditingController();

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
  void pickProgram(BuildContext context) async {
    // launch the page to pick them, return it when done
    /// - do this more safely obviously. if they OS-back button this goes badly.
    selectedProgram = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Programs()));
    // update the page we're on now
    programController.text = selectedProgram;
    // or just do actual state management...
    updateReadyToGo();
  }

  // launch the day, which is program and exercise
  // not sure we care about context here?
  void launchDay(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Home(
                program: selectedProgram,
                exercise: exercises[
                    selectedExercise.indexWhere((element) => element)])));
  }
}
