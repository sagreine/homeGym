import 'package:home_gym/models/models.dart';

class ProgramBuilderController {
  saveUpdatesToProgram(
      {PickedProgram updatedProgram, List<ExerciseDay> exerciseDays}) {
    // TODO: this might not belong here.
    updatedProgram.exerciseDays = exerciseDays;

    // update our local Program
    var originalProgram = PickedProgram.deepCopy(updatedProgram);
    originalProgram.neverTouched = false;
    originalProgram.isAnewCopy = false;
    return originalProgram;

    // update this program's exerciseDay - ?

    // update the cloud copy
    // TODO
  }
}
