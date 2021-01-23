import 'package:flutter/material.dart';
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
  _goToEdit({BuildContext context, PickedProgram pickedProgram}) {
    Navigator.pushNamed(context, '/program_builder_view',
        arguments: pickedProgram);
  }

  _copyProgram({Programs programs, PickedProgram copyingFrom}) {
    PickedProgram copyingTo = PickedProgram.deepCopy(copyingFrom);
    print("deep copy complete!");
    copyingTo.isCustom = true;
    copyingTo.program += "- copy";
    programs.addProgram(newProgram: copyingTo);
  }

  _getFAB(BuildContext context) {
    return FloatingActionButton(
        isExtended: false,
        child: //Text("Add new"),
            Icon(Icons.add),
        onPressed: () {
          // TODO: this sure shouldn't be done here
          var programs = Provider.of<Programs>(context, listen: false);

          programs.addProgram();
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
            "Edit or Add Programs",
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
                      itemCount: _programs
                          .pickedPrograms
                          //.where((element) => !element.isCustom)
                          .length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading:
                              Text(_programs.pickedPrograms[index].program),
                          trailing: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                    //
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
                                    onPressed: () => _copyProgram(
                                        programs: _programs,
                                        copyingFrom:
                                            _programs.pickedPrograms[index])),
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
