import 'package:flutter/material.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';

class ProgramsView extends StatefulWidget {
  @override
  _ProgramsState createState() => _ProgramsState();
}

class _ProgramsState extends State<ProgramsView> {
  ProgramController programsController = ProgramController();

  @override
  void initState() {
    //programsController.updateProgramList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(),
      drawer: ReusableWidgets.getDrawer(context),
      body: _buildSuggestions(context),
    );
  }

  // b) will likely not want to use documentID in reality, but rather a display name..
  Widget _buildSuggestions(context) {
    return FutureBuilder(
      // while retrieving, put a loading indicator
      builder: (context, programSnap) {
        if (programSnap.hasData == false) {
          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator()]);
        }
        // once we have data put it in.
        return ListView.builder(
            itemCount: programSnap.data.length * 2 + 1,
            padding: EdgeInsets.all(16.0),
            itemBuilder: (context, i) {
              if (i == 0) {
                return ListTile(
                    onTap: () async {
                      //Navigator.pop(context, programSnap.data[index]);
                    },
                    title:
                        Text("Make your own! <this feature isn't built yet>"));
              }

              if (i.isOdd) return Divider();
              final index = (i - 1) ~/ 2;
              // default to the 1st week, but only for programs that don't have weeks specified (those get nulled if they don't pick a week)
              PickedProgram returnProgram = PickedProgram();
              returnProgram.program = programSnap.data[index].program;
              returnProgram.week = 1;
              return ListTile(
                  onTap: () async {
                    // this should be done in a controller....
                    if (programSnap.data[index].week > 1) {
                      returnProgram.week = await programsController.pickWeek(
                          context, programSnap.data[index].week);
                      // this is a (potential) progressWeek if this is the last week of the program.
                      // later we'll also check if this program is allowed to progess (at any week) -> why later though?
                      returnProgram.potentialProgressWeek =
                          (returnProgram.week == programSnap.data[index].week);
                    }
                    // if they picked a week, return with it, else just play dumb
                    if (returnProgram.week != null) {
                      Navigator.pop(context, returnProgram);
                    }
                    //Navigator.pop(context, programSnap.data[index]);
                  },
                  title: Text(programSnap.data[index].program));
            });
      },
      future: programsController.updateProgramList(context),
    );
  }
}
