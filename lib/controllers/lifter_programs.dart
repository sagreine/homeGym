import 'package:flutter/material.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:provider/provider.dart';

class LifterProgramsController {
  copyProgram({Programs programs, PickedProgram copyingFrom}) {
    // copy locally
    PickedProgram copyingTo = PickedProgram.deepCopy(copyingFrom);
    print("deep copy complete!");
    copyingTo.isCustom = true;
    copyingTo.program += "- copy";
    copyingTo.isAnewCopy = true;
    copyingTo.id = null;
    // TODO these are historical artifacts of the default programs. we may be able to remove them if we move on from that approach
    // check if this works by making a new program from a copy and see what gets written to the cloud.
    if (copyingTo.potentialProgressWeek == null) {
      copyingTo.potentialProgressWeek = false;
    }
    if (copyingTo.isMainLift == null) {
      copyingTo.isMainLift = false;
    }
    // dont want to do this for copy.
    //copyingTo.neverTouched = true;
    return copyingTo;
    // no writing to cloud here. only if they add
  }

  addProgram(BuildContext context, PickedProgram program) async {
    // add new locally
    var programs = Provider.of<Programs>(context, listen: false);

    programs.addProgram(newProgram: program ?? null);

    // write program to cloud
    await saveProgram(context: context, potentiallyEditedProgram: program);
    // update the local copy's training max pct and indexes (this is done on read-back-in-program from cloud, but we wont be reading back in!)
    // so, update the local copy so that it has these changes too in case they go directly to using it.
    program.trainingMaxPct /= 100;
    //var isMain = lift.data()["thisIsMainSet"] ?? false;
    program.exerciseDays.forEach((day) {
      day.exercises.forEach((lift) {
        var barbellPctIndex = lift.whichLiftForPercentageofTMIndex;
        var barbellIndex = lift.whichBarbellIndex;
        if (lift.thisIsMainSet) {
          if (barbellPctIndex == -1) {
            barbellPctIndex = ReusableWidgets.lifts
                .indexOf(Provider.of<ExerciseDay>(context, listen: false).lift);
          }
          // thuis modification is needed here and on the other one if we populated against (4 lifts + Main) when we set this
          /*else if (barbellPctIndex != null) {
        barbellPctIndex--;
      }*/
          if (barbellIndex == -1) {
            barbellIndex = ReusableWidgets.lifts
                .indexOf(Provider.of<ExerciseDay>(context, listen: false).lift);
          }
        }
      });
    });
  }

  saveProgram(
      {@required BuildContext context,
      @required PickedProgram potentiallyEditedProgram,
      PickedProgram originalProgram}) async {
    // error check : we shouldn't be saving un-updated programs in any way
    if (potentiallyEditedProgram == originalProgram) {
      return;
    }
    bool anyProgramsToUpdate = false;
    // TODO: absolutely not the way to do this, come on now. next, check if we need to update program-level info
    if (potentiallyEditedProgram.toJson() != originalProgram?.toJson()) {
      anyProgramsToUpdate = true;
    }

    // there is not ExerciseDay-level information

    // then check for each exerciseSet if we need to update --- unless we can just dump over it?
    // also, stop doing this manually?
    for (int i = 0; i < potentiallyEditedProgram.numWeeks; ++i) {
      for (int j = 0;
          j < potentiallyEditedProgram.exerciseDays[i].exercises.length;
          ++j) {
        if (originalProgram == null ||
            i >= originalProgram?.exerciseDays?.length ||
            j >= originalProgram?.exerciseDays[i]?.exercises?.length ||

            //originalProgram.exerciseDays[i].exercises[j]
            // TODO this does not work. need to override == and hash...
            potentiallyEditedProgram.exerciseDays[i].exercises[j] !=
                originalProgram?.exerciseDays[i]?.exercises[j]) {
          potentiallyEditedProgram.exerciseDays[i].exercises[j].hasBeenUpdated =
              true;
        }
      }
    }

    // save to cloud
    var programIDCloud = await saveProgramCloud(
        userID: Provider.of<Muser>(context, listen: false).fAuthUser.uid,
        program: potentiallyEditedProgram,
        anyProgramsToUpdate: anyProgramsToUpdate);
    potentiallyEditedProgram.id = programIDCloud.id;
  }
}
