import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:numberpicker/numberpicker.dart';

class ProgramBuilderView extends StatefulWidget {
  @override
  ProgramBuilderViewState createState() => ProgramBuilderViewState();
}

class ProgramBuilderViewState extends State<ProgramBuilderView> {
  bool firstBuild;
  PickedProgram program;
  //TextEditingController programNameController = TextEditingController();
  //TextEditingController programTypeController = TextEditingController();
  //TextEditingController tmController = TextEditingController();
  String mainLiftExplanatory = "Main lifts are Squat, Bench, Deadlift, and Press. " +
      "You can build programs where any lift uses a % of one of those lifts 1RM. For example, a set of Front Squats " +
      "done at 50% of your Squat 1RM.\nYou can also make a 'Main' day program. " +
      "That is, do Squats/Bench/Deadlift/Press on their own day, all with the same percentages and reps, " +
      "instead of making separate week/days here, select Yes for the Main day above. When you do the program " +
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

  List<PageViewModel> listPagesViewModel() {
    return [
      PageViewModel(
        pageColor: const Color(0xFF607D8B),
        iconImageAssetPath: 'assets/images/pos_icon.png',
        bubbleBackgroundColor: Colors.blueGrey[400],
        body: TextFormField(
          initialValue: program.program,
          textCapitalization: TextCapitalization.sentences,
          //initialValue: exerciseSet.title,
          //controller: programNameController,
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
                // borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                ),
            //labelText: "Program Name",
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
        title: Text('Program Name'),
        mainImage: null,
        /* Image.asset(
          'assets/images/animation_1.gif',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        ),*/
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
      PageViewModel(
        pageColor: Colors.greenAccent[700],
        iconImageAssetPath: 'assets/images/pos_icon.png',
        bubbleBackgroundColor: Colors.greenAccent[400],
        body: TextFormField(
            textCapitalization: TextCapitalization.sentences,
            initialValue: program.type,
            //controller: programTypeController,
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
                  //borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                  ),
              labelText: "Used for sorting. E.g. '5/3/1' or 'Deload'",
            )
            //labelStyle: TextStyle(fontSize: 18)),
            //validator: (value) {
            //homeController.formController.validator()
            // TODO decide if we want to let them have null values here. depends on if sorting cares in program picker and here even... cloud.sort
            //},
            //controller: homeController.formControllerTitle,
            ),
        title: Text("Program Type"),
        mainImage: Image.asset(
          'assets/images/pos_icon.png',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        ),
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
      PageViewModel(
        pageColor: Colors.indigoAccent[700],
        iconImageAssetPath: 'assets/images/pos_icon.png',
        bubbleBackgroundColor: Colors.indigoAccent[700],
        body: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
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
            ],
          ),
        ),
        title: Text('Main Lift Day?'),
        mainImage: Image.asset(
          'assets/images/pos_icon.png',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        ),
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
      PageViewModel(
        pageColor: Colors.indigoAccent[700],
        iconImageAssetPath: 'assets/images/pos_icon.png',
        bubbleBackgroundColor: Colors.blueGrey[400],
        body: Container(),
        title: Text('Training Max %'),
        mainImage: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 4,
              ),
              TextFormField(
                //controller: tmController,
                onChanged: (newValue) {
                  //pickDay.pickedProgram.trainingMaxPct =
                  program.trainingMaxPct = double.parse(newValue);
                },
                initialValue: (program.trainingMaxPct * 100).toInt().toString(),
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
                  labelText: "as % of 1 Rep max for Main lifts",
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
            ], //
          ),
        ), //Container(),
        /*Image.asset(
          'assets/images/pos_icon.png',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        ),*/
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
      PageViewModel(
        pageColor: Colors.indigoAccent[700],
        iconImageAssetPath: 'assets/images/pos_icon.png',
        bubbleBackgroundColor: Colors.greenAccent[700],
        body: SwitchListTile.adaptive(
            title: Text("The program has > 1 distinct week(s)"),
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
        title: Text('Distinct Weeks?'),
        mainImage: Image.asset(
          'assets/images/pos_icon.png',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        ),
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
      PageViewModel(
        pageColor: Colors.indigoAccent[700],
        iconImageAssetPath: 'assets/images/pos_icon.png',
        bubbleBackgroundColor: Colors.indigoAccent[700],
        body: RaisedButton(
            color: Colors.transparent,
            child: Text((program.week ?? 2).toString()),
            onPressed: () async {
              program.week = await showDialog<int>(
                      context: context,
                      builder: (BuildContext context) {
                        return new NumberPickerDialog.integer(
                          minValue: 2,
                          maxValue: 24,
                          title: new Text("How many weeks"),
                          initialIntegerValue: 2,
                        );
                      }) ??
                  1;
            }),
        title: Text('How many?'),
        mainImage: Image.asset(
          'assets/images/pos_icon.png',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        ),
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
      /*
      PageViewModel(
        pageColor: Colors.indigoAccent[700],
        iconImageAssetPath: 'assets/images/pos_icon.png',
        bubbleBackgroundColor: Colors.indigoAccent[700],
        body: Column(
          children: [
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
          ],
        ),
        title: Text('Make it happen'),
        mainImage: Image.asset(
          'assets/images/pos_icon.png',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        ),
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),*/
    ];
  }

  Widget programBuilderViews;
  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      program = ModalRoute.of(context).settings.arguments;
      //programNameController.text = program.program;
      //program.type;
      programBuilderViews = new IntroViewsFlutter(
        listPagesViewModel(),
        onTapDoneButton: () {
          //Navigator.pushReplacementNamed(context, '/lifter_maxes');
        },
        showSkipButton: false,
        showBackButton: true,
        showNextButton: true,
        pageButtonTextStyles: new TextStyle(
          color: Colors.white,
          fontSize: 18.0,
          fontFamily: "Regular",
        ),
      );
    }
    firstBuild = false;
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(),
      drawer: ReusableWidgets.getDrawer(context),
      body: programBuilderViews,
      //floatingActionButton: _getDoneButton(context),
    );
  }
}
