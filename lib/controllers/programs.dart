import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

class ProgramController {
  // if programs would actually change, would use a stream. for now, just so we can load during app initialization
  // but not lose the code for pulling in later if need be.

  // this is fine though, because we are just showing them the programs? so we don't need to return a map?
  Future<List<PickedProgram>> updateProgramList(BuildContext context) async {
    var model = Provider.of<Programs>(context, listen: false);
    // if it is null, pull it in. could just listen instead of htis, but realistically we aren't adding programs much at all rn.
    if (model.programs == null || model.programs.length == 0) {
      print("model.programs was null or empty, re-pulling");
      model.setProgram(programs: await getPrograms());
      // this works but breaks the view.
    } else {
      print("model.programs already populated, using that");
    }
    //return model.programs;
    return model.pickedPrograms;
  }

  Future<int> pickWeek(context, int maxWeek) async {
    // launch the page to pick them, return it when done
    /// - do this more safely obviously. if they OS-back button this goes badly.
    int returnVal = await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
            minValue: 1,
            maxValue: maxWeek,
            title: new Text("Pick a week"),
            initialIntegerValue: 1,
          );
        });
    print("returnVal: $returnVal");
    return returnVal;
  }
}
