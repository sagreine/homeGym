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
    programs.addProgram(newProgram: copyingTo);

    // write program to cloud
    // TODO
  }

  addProgram(BuildContext context) {
    // add new locally
    var programs = Provider.of<Programs>(context, listen: false);
    programs.addProgram();

    // write program to cloud
    // TODO
  }
}
