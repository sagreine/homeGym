import 'package:home_gym/models/models.dart';

class ProgramBuilderController {
  saveUpdatesToProgram(
      {PickedProgram originalProgram,
      PickedProgram updatedProgram,
      List<ExerciseDay> exerciseDays}) {
    // update our local Program
    originalProgram = PickedProgram.deepCopy(updatedProgram);
    originalProgram.neverTouched = false;

    // update the cloud copy
    // TODO
  }
}
