import 'package:home_gym/controllers/controllers.dart';

class ProgramController {
  Future updateProgramList() async {
    var programs = await getPrograms();
    return programs;
  }
}
