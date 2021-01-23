import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/controllers/program_builder.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

class ProgramBuilderView extends StatefulWidget {
  @override
  ProgramBuilderViewState createState() => ProgramBuilderViewState();
}

class ProgramBuilderViewState extends State<ProgramBuilderView> {
  bool firstBuild;
  bool firstFutureBuildComplete;
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

  @override
  dispose() {
    super.dispose();
    programNameController.dispose();
    programTypeController.dispose();
    tmController.dispose();
  }

  List<ExerciseDay> exerciseDays = List<ExerciseDay>();

  TextEditingController programNameController = TextEditingController();
  TextEditingController programTypeController = TextEditingController();
  TextEditingController tmController = TextEditingController();
  ProgramBuilderController programBuilderController =
      ProgramBuilderController();
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
    firstFutureBuildComplete = false;
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
            //setState(() {});
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
              //setState(() {});
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
                      if (newValue == false) {
                        potentialNewPRogram.week = 1;
                        weekSpecificPages = weekSpecificPages.take(1).toList();
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
      if (potentialNewPRogram.week > 1)
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
                    2;
                // drain out these since we don't need them anymore
                weekSpecificPages =
                    weekSpecificPages.take(potentialNewPRogram.week).toList();
                exerciseDays =
                    exerciseDays.take(potentialNewPRogram.week).toList();
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

  //Future<List<PageViewModel>>
  _getPageModelsForWeeks(BuildContext context, int weeks) async {
    //List<PageViewModel> list = List<PageViewModel>();
    for (int i = 1; i <= weeks; ++i) {
      //list.add(
      await _buildPageModelForWeek(context, i);
      //);
    }

    // TODO well this is dangerous. but it is needed because the other function pulls from this..
    //weekSpecificPages = list;
    //return list;
  }

  _buildPageModelForWeek(BuildContext context, int week) async {
    //return Consumer<ExerciseDay>(builder: (context, lifterweights, child) {
    // TODO but is this actually weeks

    //if the program has never been touched, don't bring in any contextual program
    if (program.neverTouched == true || week > program.week) {
      //if (exerciseDays.length == 0) {
      if (exerciseDays.length < week) {
        exerciseDays.add(ExerciseDay());
        var newPage = PageViewModel(
            // humans prefer 1-3 over 0-2
            title: Text("Week $week"),
            mainImage: Column(
              children: [
                //Text("a title"),
                SizedBox(
                  // TODO: well lets not hardcode this now. at least use mediaquery
                  height: 367,
                  child: ChangeNotifierProvider.value(
                    value: exerciseDays[week - 1],
                    child: ExcerciseDayView(
                        program: PickedProgram.deepCopy(program)),
                  ),
                )
              ],
            ),
            // TODO: add editable information at the set level here?
            // e.g. copy from another week's sets. maybe just that.
            body: Container());
        if (weekSpecificPages.contains(newPage)) {
          print(
              "An equivalent day is already in there, just use that pageviewmodel");
          return;
        } else {
          weekSpecificPages.add(newPage);
        }
      }
      return;
      //}
    }

    var thisweek;
    var exerciseDay;
    // if there could never be a week for this, just pass a blank one in - if you have a 3 week program you're copying from and add a 4th, it should be blank
    // if () {
    //   exerciseDays.add(ExerciseDay());
    // } else {
    thisweek = PickedProgram.deepCopy(program);
    thisweek.week = week;
    thisweek.program = "Widowmaker";

    exerciseDay = Provider.of<ExerciseDay>(context, listen: false);
    exerciseDay.trainingMax = thisweek.trainingMaxPct;
    //}
    //PickDay().updatePickedProgram(thisweek);

    // this should be == 'were building this page for the first time'
    // it might rebuild a deleted page of a copied program but they can deal :)
    if (exerciseDays == null || exerciseDays.length < week) {
      // only get weeks that exist and neverpull more than once (e.g., if you change # of weeks this could re-pull
      // but we'll never have weeks in existence and want to get them (they can cancel out of it if necessary)).
      if (week <= program.week && !firstFutureBuildComplete) {
        await getExercisesCloud(
            context: context, program: thisweek.program, week: week);
      }
    }
    // else if we are just hitting next to a page we haven't changed since we built , just return that page
    // TODO: if we can do this is entirely theoretical :)
    // but this is important for this use case: build page, edit it, revisit it -> is this going to return it for us?
    // don't want to overwrite our changes
    else if (exerciseDays.length < week) {
      if (exerciseDays[week] == exerciseDay) {
        print(
            "An equivalent day is already in there, just return that pageviewmodel");
        return weekSpecificPages[week];
      }
    }
    // otherwise, build the page -> if this is the very first time, we're adding it
    // otherwise we need to put it in line -> do we? shouldn't that be covered by above? yes?
    if (exerciseDays.length < week) {
      //if (!weekSpecificPages.contains(exerciseDay)) {
      print("a new page model! add it in.");
      // if this is a week that existed, add it in
      exerciseDays.add(ExerciseDay.deepCopy(copyingFrom: exerciseDay));
      //}
    } else {
      //exerciseDays[week] = ExerciseDay.deepCopy(copyingFrom: exerciseDay);
      print(
          "should never happen - happens on cancel press though, which is real scary");
      return;
    }

    var newPage = PageViewModel(
        // humans prefer 1-3 over 0-2
        title: Text("Week $week"),
        mainImage: Column(
          children: [
            //Text("a title"),
            SizedBox(
              // TODO: well lets not hardcode this now. at least use mediaquery
              height: 367,
              child: ChangeNotifierProvider.value(
                value: exerciseDays[week - 1], //ExerciseDay(),
                child: ExcerciseDayView(program: thisweek),
              ),
            )
          ],
        ),
        // TODO: add editable information at the set level here?
        // e.g. copy from another week's sets. maybe just that.
        body: Container());
    weekSpecificPages.add(newPage);
  }

  //Widget programBuilderViews;
  PickedProgram potentialNewPRogram = PickedProgram();
  int originalNumWeeks = 1;
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
      // this is just a safe place check. but don't use 1.0 because that is == 100% and that definitely happens.
      tmController.text = potentialNewPRogram.trainingMaxPct < 1.00001
          ? (potentialNewPRogram.trainingMaxPct * 100).toInt().toString()
          : potentialNewPRogram.trainingMaxPct.toInt().toString();
      originalNumWeeks = program.week;
      //weekSpecificPages =
      //  await _getPageModelsForWeeks(potentialNewPRogram?.week ?? 1);
    }
    firstBuild = false;

    return Scaffold(
        appBar: ReusableWidgets.getAppBar(),
        drawer: ReusableWidgets.getDrawer(context),
        body: FutureBuilder(
            // if we already have some weekSpecificPages, we don't need to repull at all..
            // ^ that isnt true, what if we just added a week?
            future: //(weekSpecificPages?.length ?? 0) == 0
                //?
                _getPageModelsForWeeks(context, potentialNewPRogram?.week ?? 1),
            //: Future.delayed(Duration(milliseconds: 0)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                var toReturn = IntroViewsFlutter(
                  listPagesViewModel(),
                  // TODO i don't think this will work? also we don't want to do it every time...
                  // needs to change based on how many weeks there are, which can change in the IntroView...
                  onTapNextButton: () async {
                    if (originalNumWeeks != potentialNewPRogram.week) {
                      // _buildPageModelForWeek(potentialNewPRogram.week);
                      //weekSpecificPages = await _getPageModelsForWeeks(
                      //  context, potentialNewPRogram.week);
                      //setState(() {});
                    }
                  },
                  onTapDoneButton: () {
                    print("Program saved!");
                    programBuilderController.saveUpdatesToProgram(
                        originalProgram: program,
                        exerciseDays: exerciseDays,
                        updatedProgram: potentialNewPRogram);
                    Navigator.of(context).pop();
                  },
                  doneText: Text("Save Program!"),
                  showSkipButton: true,
                  skipText: Text("Cancel"),
                  // we preserved the original program and edited the deep copy, so we don't need to do anything to restore the original.
                  // Skip == cancel for us.
                  onTapSkipButton: () {
                    Navigator.of(context).pop();
                  },
                  showBackButton: true,
                  showNextButton: true,
                  pageButtonTextStyles: new TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontFamily: "Regular",
                  ),
                );
                firstFutureBuildComplete = true;
                return toReturn;
              } else
                return Container();
            }));
  }
}
