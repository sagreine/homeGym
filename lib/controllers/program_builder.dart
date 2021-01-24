import 'package:flutter/material.dart';

import 'package:home_gym/models/models.dart';

class ProgramBuilderController {
  saveUpdatesToProgram(
      {@required PickedProgram updatedProgram,
      @required List<ExerciseDay> exerciseDays}) {
    // TODO: this might not belong here.
    updatedProgram.exerciseDays = exerciseDays;

    // update our local Program
    var originalProgram = PickedProgram.deepCopy(updatedProgram);
    originalProgram.neverTouched = false;
    originalProgram.isAnewCopy = false;

    return originalProgram;

    // DON'T update the cloud copy here
  }
}
