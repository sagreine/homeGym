import 'package:flutter/material.dart';
import 'package:home_gym/controllers/controllers.dart';

class ProgramController {
  List<String> _programs;
  Future updateProgramList() async {
    var programs = await getPrograms();
    return programs;
  }
}
