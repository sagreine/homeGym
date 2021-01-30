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

  _goToEdit({BuildContext context, PickedProgram pickedProgram}) async {
    return await Navigator.pushNamed(context, '/program_builder_view',
        arguments: pickedProgram);
  }

  _getFAB(BuildContext context) {
    return FloatingActionButton(
        isExtended: false,
        child: //Text("Add new"),
            Icon(Icons.add),
        onPressed: () async {
          var newProgram = await _goToEdit(
              context: context, pickedProgram: PickedProgram.newBlankProgram());
          if (newProgram != null) {
            lifterProgramsController.addProgram(context, newProgram);
            setState(() {});
          }

          //lifterProgramsController.addProgram(context);
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
                                // TODO: if we send a copy here, the first time we edit a program in a given
                                // session it is ALWAYS going to compare unequal because the 'copy' has not
                                // had its exerciseDay pulled in.
                                IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: (_programs
                                            .pickedPrograms[index].isCustom)
                                        ? () async {
                                            /*var copyToSend =
                                                PickedProgram.deepCopy(_programs
                                                    .pickedPrograms[index]);*/
                                            var potentiallyEditedProgram =
                                                await _goToEdit(
                                                    context: context,
                                                    pickedProgram:
                                                        // pass in a copy of this program straight away
                                                        //copyToSend
                                                        //PickedProgram.deepCopy(
                                                        _programs
                                                                .pickedPrograms[
                                                            index]
                                                    //)
                                                    );
                                            // if we did change the program and didn't cancel
                                            if (potentiallyEditedProgram !=
                                                    null &&
                                                potentiallyEditedProgram !=
                                                    _programs.pickedPrograms[
                                                        index]) {
                                              // update our local repository (cough not view...) and
                                              // update the cloud
                                              await lifterProgramsController
                                                  .saveProgram(
                                                      context: context,
                                                      potentiallyEditedProgram:
                                                          potentiallyEditedProgram,
                                                      originalProgram: _programs
                                                              .pickedPrograms[
                                                          index]);
                                              // save to local
                                              _programs.pickedPrograms[index] =
                                                  potentiallyEditedProgram;
                                              setState(() {});
                                            }
                                            // reflect any name changes here next.
                                          }
                                        : null),
                                IconButton(
                                    icon: Icon(Icons.content_copy),
                                    onPressed: () async {
                                      var newProgram = await _goToEdit(
                                          context: context,
                                          pickedProgram:
                                              lifterProgramsController
                                                  .copyProgram(
                                                      programs: _programs,
                                                      copyingFrom: _programs
                                                              .pickedPrograms[
                                                          index]));
                                      if (newProgram != null) {
                                        // adds to local and cloud
                                        lifterProgramsController.addProgram(
                                            context, newProgram);
                                        setState(() {});
                                      }
                                    }),
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
