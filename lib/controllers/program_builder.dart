import 'package:flutter/material.dart';

import 'package:home_gym/models/models.dart';

class ProgramBuilderController {
  saveUpdatesToProgram(
      {@required PickedProgram updatedProgram,
      @required List<ExerciseDay> exerciseDays}) {
    // TODO: this might not belong here.
    updatedProgram.exerciseDays = exerciseDays;

    // update our local Program - dont do this we dont check this here anymore -below used to be for original but is now for updated
    //var originalProgram = PickedProgram.deepCopy(updatedProgram);
    updatedProgram.neverTouched = false;
    updatedProgram.isAnewCopy = false;

    return updatedProgram;

    // DON'T update the cloud copy here
  }
}
