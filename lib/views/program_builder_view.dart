import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  List<Color> pageColors = [
    const Color(0xFF607D8B),
    Colors.greenAccent[700],
    Colors.indigoAccent[700],
  ];
  List<Color> bubbleColors = [
    Colors.blueGrey[400],
    Colors.deepOrange[900],
    Colors.deepPurpleAccent[100],
  ];

  TextEditingController programNameController = TextEditingController();
  TextEditingController programTypeController = TextEditingController();
  TextEditingController tmController = TextEditingController();
  String mainLiftExplanatory = "Main lifts are Squat, Bench, Deadlift, and Press. \n\n" +
      "If your program has days centered around a 'main' lift, with the same rep and weight/effor scheme for each day even with different weights, " +
      "you can save time by making a single 'Main day' program by selecting this option above. " +
      "When you do the program we'll ask you to select what 'Day' you're doing." +
      "\nTo see an example, go to Pick Lift and select Widowmaker and see that the four Main lift options are presented.";

  String tmPercentageExplanatory =
      "Some programs use percentages of your 1RM to calculate weight for a set. For each set, you can optionally set the % of this % of your 1RM to use. " +
          "E.g. say you want your top set to be 85% of your 1RM, then you would set this to 85. Your first set of the day might be 50% of that weight, the next 60%, etc. " +
          "This lets you just put 50 for that set, not try to multiply 0.85 * 0.50 then 0.85 * 0.6 etc. " +
          "You can override this when you pick doing this program, so don't worry if e.g. sometimes it is 85 and sometimes it is 90. If you don't want to use percentages " +
          "at all, just leave this at 100 and use either exact weights or RPE on the next page";

  String distinctWeeksExplanatory =
      "Programs have different numbers of weeks. Sometimes, a four week program might have 4 distinct weeks. But, sometimes " +
          "a program might run the same weeks more than once, e.g. week 1, week 2, week 1, week 2, or 1-2-3, 1-2-3. That is, repeating the same rep and " +
          "(relative) weight. This is often the case if you increase your " +
          "training max afer the first 1-2 or 1-2-3 or use RPE to progress the weights while keeping the sets and reps the same. Other times, you might simply "
              "have a single week for deload. We will have you build each of these weeks soon. Keep in mind that we say 'weeks' everywhere in this app "
              "but it can be any unit of time you like - even days, though we hope that we provide enough flexibility to build whole weeks at a time.";
  List<PageViewModel> weekSpecificPages = List<PageViewModel>();

  @override
  void initState() {
    //programsController.updateProgramList();
    super.initState();
    firstBuild = true;
  }

  List<PageViewModel> listPagesViewModel() {
    List<PageViewModel> toReturn = List<PageViewModel>();
    List<PageViewModel> basePages = [
      PageViewModel(
        pageColor: pageColors[0],
        iconImageAssetPath: 'assets/images/pos_icon.png',
        bubbleBackgroundColor: bubbleColors[0],
        body: Container(),
        title: Text('Program Name'),
        mainImage: TextFormField(
          //initialValue: program.program,
          textCapitalization: TextCapitalization.sentences,
          controller: programNameController,
          onChanged: (value) {
            potentialNewPRogram.program = value;
            //onValueUpdate(value);
            setState(() {});
          },
          style: TextStyle(fontSize: 30),
          textAlign: TextAlign.center,
          autocorrect: true,
          enableSuggestions: true,
          decoration: new InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey[300], width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(),
            labelText: "Unique Name",
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
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
      PageViewModel(
        pageColor: pageColors[1],
        iconImageAssetPath: 'assets/images/pos_icon.png',
        bubbleBackgroundColor: bubbleColors[1],
        mainImage: TextFormField(
            textCapitalization: TextCapitalization.sentences,
            //initialValue: program.type,
            style: TextStyle(fontSize: 30),
            controller: programTypeController,
            onChanged: (value) {
              potentialNewPRogram.type = value;
              //onValueUpdate(value);
              setState(() {});
            },
            textAlign: TextAlign.center,
            autocorrect: true,
            enableSuggestions: true,
            decoration: new InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.greenAccent,
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
              ),
              enabledBorder: OutlineInputBorder(),
              labelText: "For sorting. E.g. '5/3/1' or 'Deload'",
            )
            //labelStyle: TextStyle(fontSize: 18)),
            //validator: (value) {
            //homeController.formController.validator()
            // TODO decide if we want to let them have null values here. depends on if sorting cares in program picker and here even... cloud.sort
            //},
            //controller: homeController.formControllerTitle,
            ),
        title: Text("Program Type"),
        body: Container(),
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
      PageViewModel(
        pageColor: pageColors[2],
        iconImageAssetPath: 'assets/images/pos_icon.png',
        bubbleBackgroundColor: bubbleColors[2],
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
                controller: tmController,
                onChanged: (newValue) {
                  //pickDay.pickedProgram.trainingMaxPct =
                  potentialNewPRogram.trainingMaxPct = double.parse(newValue);
                },
                //initialValue: ,
                keyboardType: TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                //validator: numberValidator,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
                decoration: new InputDecoration(
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.blueGrey[300], width: 1.0),
                  ),
                  labelText: "as % of 1 Rep max for Main lifts",
                ),
                //onChanged: (value) => ,
                readOnly: false,
                style: TextStyle(fontSize: 30),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(children: <Widget>[
                  Text("What's This?"),
                  ExpandChild(
                    child: Text(tmPercentageExplanatory),
                  ),
                ]),
              ),
            ], //
          ),
        ),
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
      PageViewModel(
        pageColor: pageColors[0],
        iconImageAssetPath: 'assets/images/pos_icon.png',
        bubbleBackgroundColor: bubbleColors[0],
        body: Container(),
        title: Text('Main Lift Day?'),
        mainImage: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SwitchListTile.adaptive(
                  title: Text("The program has a 'Main' lift day"),
                  // TODO: need to implmeent 'has a main day' not just do this.
                  value: potentialNewPRogram.isMainLift ??
                      potentialNewPRogram.type == "5/3/1",
                  onChanged: (newValue) {
                    setState(() {
                      potentialNewPRogram.isMainLift = newValue;
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
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
      PageViewModel(
        pageColor: pageColors[1],
        iconImageAssetPath: 'assets/images/pos_icon.png',
        bubbleBackgroundColor: bubbleColors[1],
        body: Container(),
        title: Text('Distinct Weeks?'),
        mainImage: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(mainAxisSize: MainAxisSize.max, children: [
              SwitchListTile.adaptive(
                  title: Text("The program has > 1 distinct week(s)"),
                  value: potentialNewPRogram.week > 1,
                  onChanged: (newValue) {
                    setState(() {
                      if (newValue = false) {
                        potentialNewPRogram.week = 1;
                      } else {
                        potentialNewPRogram.week = 2;
                      }
                    });
                  }),
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(children: <Widget>[
                  Text("What's This?"),
                  ExpandChild(
                    child: Text(distinctWeeksExplanatory),
                  ),
                ]),
              ),
            ])),
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
      PageViewModel(
        pageColor: pageColors[2],
        iconImageAssetPath: 'assets/images/pos_icon.png',
        bubbleBackgroundColor: bubbleColors[2],
        body: Container(),
        title: Text(
          'How many?',
        ),
        mainImage: SizedBox.expand(
          child: FlatButton(
            onPressed: () async {
              potentialNewPRogram.week = await showDialog<int>(
                      context: context,
                      builder: (BuildContext context) {
                        return new NumberPickerDialog.integer(
                          minValue: 2,
                          maxValue: 24,
                          title: new Text("How many weeks"),
                          initialIntegerValue: potentialNewPRogram.week,
                        );
                      }) ??
                  1;
              setState(() {});
            },
            child: Text(
              (potentialNewPRogram.week ?? 2).toString(),
              style: TextStyle(fontSize: 48),
            ),
          ),
        ),
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
    ];
    toReturn.addAll(basePages);
    toReturn.addAll(weekSpecificPages);
    return toReturn;
  }

  List<PageViewModel> _getPageModelsForWeeks(int weeks) {
    List<PageViewModel> list = List<PageViewModel>();
    for (int i = 0; i < weeks; ++i) {
      list.add(_buildPageModelForWeek(i));
    }
    return list;
  }

  _buildPageModelForWeek(int week) {
    return PageViewModel(
        // humans prefer 1-3 over 0-2
        title: Text("Week ${week + 1}"),
        mainImage: Column(
          children: [
            //Text("a title"),
            SizedBox(
              // TODO: well lets not hardcode this now. at least use mediaquery
              height: 367,
              child: ExcerciseDayView(program: potentialNewPRogram),
            ),
          ],
        ),
        body: Container());
  }

  Widget programBuilderViews;
  PickedProgram potentialNewPRogram = PickedProgram();
  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      program = ModalRoute.of(context).settings.arguments;
      // this is a shallow copy and not doing what you think it is doing.
      if (program != null) {
        potentialNewPRogram = PickedProgram.deepCopy(program);
      }
      programNameController.text = potentialNewPRogram.program;
      programTypeController.text = potentialNewPRogram.type;
      tmController.text = potentialNewPRogram.trainingMaxPct < 1
          ? (potentialNewPRogram.trainingMaxPct * 100).toInt().toString()
          : potentialNewPRogram.trainingMaxPct.toInt().toString();
      weekSpecificPages =
          _getPageModelsForWeeks(potentialNewPRogram?.week ?? 1);
    }

    firstBuild = false;
    return Scaffold(
        appBar: ReusableWidgets.getAppBar(),
        drawer: ReusableWidgets.getDrawer(context),
        body:

            //Container(
            //height: 400,
            //width: 400,
            //child:
            //SingleChildScrollView(
            //primary: true,
            //clipBehavior: Clip.antiAlias,
            //scrollDirection: Axis.horizontal,
            // child:
            //Container(
            //width: 580, //double.infinity,
            //child:
            //SizedBox.expand(
            //  child: Row(children: [
            //SizedBox(
            //  width: MediaQuery.of(context).size.width + 9000,
            //height: MediaQuery.of(context).size.height,
            //child: Wrap(direction: Axis.horizontal, children: [
            //child:
            // Row(children: [
            //Expanded(
            //child:
            //ClipRect(
            //child:
            
            IntroViewsFlutter(
          listPagesViewModel(),
          // TODO i don't think this will work? also we don't want to do it every time...
          // needs to change based on how many weeks there are, which can change in the IntroView...
          onTapNextButton: () {
            weekSpecificPages =
                _getPageModelsForWeeks(potentialNewPRogram.week);
            setState(() {});
          },
          onTapDoneButton: () {
            Navigator.of(context).pop;
            //Navigator.pushReplacementNamed(context, '/lifter_maxes');

            // we need to update our local Programs

            // then update the cloud's programs

            // then go back

            //Navigator.pushNamed(context, "/excerciseday");
          },
          doneText: Text("Save Program!"),
          showSkipButton: true,
          skipText: Text("Cancel"),
          // we preserved the original program and edited the deep copy, so we don't need to do anything to restore the original.
          onTapSkipButton: () {
            /*if (program != null && potentialNewPRogram != null) {
            potentialNewPRogram = PickedProgram.deepCopy(program);
          }*/
            Navigator.of(context).pop();
          },
          showBackButton: true,
          showNextButton: true,
          pageButtonTextStyles: new TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontFamily: "Regular",
          ),
          //),
          //)
          //)
          //)

          //)
          //]
          //)
          //)
        ));
  }
}
