import 'package:flutter/cupertino.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

class ProgramController {
  // if programs would actually change, would use a stream. for now, just so we can load during app initialization
  // but not lose the code for pulling in later if need be.
  Future<List<String>> updateProgramList(BuildContext context) async {
    var model = Provider.of<Programs>(context, listen: false);
    if (model.programs == null || model.programs.length == 0) {
      print("model.programs was null or empty, re-pulling");
      var programs = await getPrograms();
      return programs;
      // this works but breaks the view.
    } else {
      print("model.programs already populated, just use that");
      return model.programs;
    }
  }
}
