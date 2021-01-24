import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

class LifterProgramsController {
  copyProgram({Programs programs, PickedProgram copyingFrom}) {
    // copy locally
    PickedProgram copyingTo = PickedProgram.deepCopy(copyingFrom);
    print("deep copy complete!");
    copyingTo.isCustom = true;
    copyingTo.program += "- copy";
    copyingTo.isAnewCopy = true;
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
    await saveProgram(context, program);
  }

  saveProgram(BuildContext context, PickedProgram program) async {
    // save to cloud

    // save to local? shouldn't be necessary?
  }
}
