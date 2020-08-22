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
  void pickProgram(BuildContext context) async {
    // launch the page to pick them
    Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (BuildContext context) => Programs()));
    // update the page we're on now
    programController.text = selectedProgram;
  }
}
