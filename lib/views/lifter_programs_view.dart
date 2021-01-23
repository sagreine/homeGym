import 'package:flutter/material.dart';
import 'package:home_gym/controllers/lifter_programs.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:provider/provider.dart';

class LifterProgramsView extends StatefulWidget {
  @override
  LifterProgramsViewState createState() => LifterProgramsViewState();
}

/*[
                  Text("My RPE program"),
                  Text("Push/Pull/Legs"),
                  Text("Death by Squat"),
                  Text("WSFSB but front squats"),
                  Text("Crossfit program 1"),
                  Text("TRX program 1"),
                  Text("Full body beginner"),
                  Text("MOAR Kettlebells"),
                ]),*/

class LifterProgramsViewState extends State<LifterProgramsView> {
  LifterProgramsController lifterProgramsController =
      LifterProgramsController();

  _goToEdit({BuildContext context, PickedProgram pickedProgram}) {
    Navigator.pushNamed(context, '/program_builder_view',
        arguments: pickedProgram);
  }

  _getFAB(BuildContext context) {
    return FloatingActionButton(
        isExtended: false,
        child: //Text("Add new"),
            Icon(Icons.add),
        onPressed: () {
          lifterProgramsController.addProgram(context);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ReusableWidgets.getAppBar(),
        drawer: ReusableWidgets.getDrawer(context),
        floatingActionButton: _getFAB(context),
        body: Column(children: <Widget>[
          Text(
            "Add or Edit Programs",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 6,
          ),
          Expanded(
              child: Row(
            children: [
              Consumer<Programs>(builder: (context, _programs, child) {
                return Expanded(
                  //flex: 5,
                  child: ListView.builder(
                      itemCount: _programs.pickedPrograms.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading:
                              Text(_programs.pickedPrograms[index].program),
                          trailing: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Edit is disabled for non-custom programs. copy is not though!
                                IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: (_programs
                                            .pickedPrograms[index].isCustom)
                                        ? () => _goToEdit(
                                            context: context,
                                            pickedProgram:
                                                _programs.pickedPrograms[index])
                                        : null),
                                IconButton(
                                    icon: Icon(Icons.content_copy),
                                    onPressed: () =>
                                        lifterProgramsController.copyProgram(
                                            programs: _programs,
                                            copyingFrom: _programs
                                                .pickedPrograms[index])),
                              ]),
                        );
                      }),
                );
              }),
            ],
          ))
        ]));
  }
}
