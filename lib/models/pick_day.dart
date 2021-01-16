import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';

class PickDay extends ChangeNotifier {
  PickedProgram pickedProgram = PickedProgram();
  updatePickedProgram(_pickedProgram) {
    pickedProgram.program = _pickedProgram.program;
    pickedProgram.week = _pickedProgram.week;
    pickedProgram.potentialProgressWeek = _pickedProgram.potentialProgressWeek;
    pickedProgram.type = _pickedProgram.type;
    pickedProgram.trainingMaxPct = _pickedProgram.trainingMaxPct;
    notifyListeners();
  }
}
