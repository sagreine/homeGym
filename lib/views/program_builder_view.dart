import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:expand_widget/expand_widget.dart';

class ProgramBuilderView extends StatefulWidget {
  @override
  ProgramBuilderViewState createState() => ProgramBuilderViewState();
}

class ProgramBuilderViewState extends State<ProgramBuilderView> {
  bool firstBuild;
  PickedProgram program;
  TextEditingController programNameController = TextEditingController();
  TextEditingController programTypeController = TextEditingController();
  TextEditingController tmController = TextEditingController();
  String mainLiftExplanatory = "Main lifts are Squat, Bench, Deadlift, and Press. " +
      "You can build programs where any lift uses a % of one of those lifts 1RM. For example, a set of Front Squats " +
      "done at 50% of your Squat 1RM.\nYou can also make a 'Main' day program. " +
      "That is, do Squats/Bench/Deadlift/Press on their own day, all with the same percentages and reps, " +
      "instead of making separate week/days here, select Yes for the Main day below. When you do the program " +
      "we'll also ask you what 'Day' you're doing." +
      "\nTo see an example, go to Pick Lift and select Widowmaker and see that four Main options are presented.";

  String tmPercentageExplanatory =
      "Some programs use percentages of your 1RM to calculate weight for a set. For each set, you can optionally set the % of this % of your 1RM to use. " +
          "E.g. say you want your top set to be 85% of your 1RM, then you would set this to 85. Your first set of the day might be 50% of that weight, the next 60%, etc. " +
          "This lets you just put 50 for that set, not try to multiply 0.85 * 0.50. " +
          "You can override this when you pick doing this program. If you don't want to use percentages, just leave this at 100 and " +
          "use either exact weights or RPE on the next page";

  @override
  void initState() {
    //programsController.updateProgramList();
    super.initState();
    firstBuild = true;
  }

  FloatingActionButton _getDoneButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(
        Icons.done,
      ),
      onPressed: () async {
        //_formEditKey.currentState.validate();
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      program = ModalRoute.of(context).settings.arguments;
      programNameController.text = program.program;
    }
    firstBuild = false;
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(),
      drawer: ReusableWidgets.getDrawer(context),
      body: Column(children: [
        Expanded(
            child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text("Edit this set"),
                  SizedBox(height: 8),
                  TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    //initialValue: exerciseSet.title,
                    controller: programNameController,
                    onChanged: (value) {
                      program.program = value;
                      //onValueUpdate(value);
                    },
                    style: TextStyle(fontSize: 30),
                    textAlign: TextAlign.center,
                    autocorrect: true,
                    enableSuggestions: true,
                    //enabled: true,
                    // remove border and center
                    decoration: new InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.greenAccent,
                          width: 1.0,
                          style: BorderStyle.solid,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.blueGrey, width: 1.0),
                      ),
                      labelText: "Program Name",
                    ),
                    validator: (value) {
                      //homeController.formController.validator()
                      // TODO decide if we want to let them make duplicate custom programs. probably not, so stop them here
                      // for firestore reasons - could let them and use a display Id but .... why
                      /*
                      var allPrograms = Provider.of<Programs>(context, listen: false);
                      if(allPrograms.programs.contains(value)) {                        
                      }
                      */
                      if (value.isEmpty) {
                        return "Title can't be blank";
                      }

                      return null;
                    },
                    //controller: homeController.formControllerTitle,
                  ),
                  SizedBox(height: 8),
                  //Text(""),
                  SizedBox(height: 8),
                  TextField(
                      textCapitalization: TextCapitalization.sentences,
                      //initialValue: exerciseSet.title,
                      controller: programTypeController,
                      onChanged: (value) {
                        program.program = value;
                        //onValueUpdate(value);
                      },
                      //style: TextStyle(fontSize: 30),
                      textAlign: TextAlign.center,
                      autocorrect: true,
                      enableSuggestions: true,
                      //enabled: true,
                      // remove border and center
                      decoration: new InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.greenAccent,
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blueGrey, width: 1.0),
                        ),
                        labelText:
                            "Type - used for sorting. E.g. '5/3/1' or 'Deload'",
                      )
                      //labelStyle: TextStyle(fontSize: 18)),
                      //validator: (value) {
                      //homeController.formController.validator()
                      // TODO decide if we want to let them have null values here. depends on if sorting cares in program picker and here even... cloud.sort
                      //},
                      //controller: homeController.formControllerTitle,
                      ),
                  SizedBox(height: 8),

                  SwitchListTile.adaptive(
                      title: Text("The program has a 'Main' lift day"),
                      // TODO: need to implmeent 'has a main day' not just do this.
                      value: program.isMainLift ?? program.type == "5/3/1",
                      onChanged: (newValue) {
                        setState(() {
                          program.isMainLift = newValue;
                        });
                      }),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(children: <Widget>[
                      Text("What's This?"),
                      ExpandChild(
                        child: Text(mainLiftExplanatory),
                      ),
                    ]),
                  ),
                  SizedBox(height: 8),
                  SizedBox(height: 4),
                  TextFormField(
                    controller: tmController,
                    onChanged: (newValue) {
                      //pickDay.pickedProgram.trainingMaxPct =
                      program.trainingMaxPct = double.parse(tmController.text);
                    },
                    keyboardType: TextInputType.numberWithOptions(
                      signed: false,
                      decimal: false,
                    ),
                    //validator: numberValidator,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    decoration: new InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blueGrey, //Color(0xFF1976D2),
                          width: 1.0,
                          style: BorderStyle.solid,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.blueGrey,
                            //Color(0xFF06ac51),
                            width: 1.0),
                      ),
                      labelText:
                          "Default Training Max, as % of 1 Rep max for Main lifts",
                    ),
                    //onChanged: (value) => ,
                    readOnly: false,
                    style: TextStyle(fontSize: 15),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(children: <Widget>[
                      //Text(
                      // child:
                      Text("What's This?"),
                      //onPressed: () {}, //=> print('Pressed button1'),
                      //),

                      ExpandChild(
                        child: Text(tmPercentageExplanatory),
                      ),
                    ]),
                  ),

                  SizedBox(height: 8),
                  SwitchListTile.adaptive(
                      title: Text("The program has distinct weeks"),
                      // TODO: need to implmeent 'has a main day' not just do this.
                      value: program.week > 1,
                      onChanged: (newValue) {
                        setState(() {
                          //program.isMainLift = newValue;
                          if (newValue = false) {
                            program.week = 1;
                          } else {
                            program.week = 2;
                          }
                        });
                      }),
                  SizedBox(height: 8),
                ])))
      ]),
      floatingActionButton: _getDoneButton(context),
    );
  }
}
