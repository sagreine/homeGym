import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:provider/provider.dart';

class ExerciseView extends StatefulWidget {
  @override
  _ExerciseViewState createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<ExerciseView> {
  //ProgramController programsController = ProgramController();
  bool firstBuild;
  String barbellLift;
  Form _form;

  @override
  void initState() {
    //programsController.updateProgramList();
    super.initState();
    firstBuild = true;
  }

  final _formEditKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//_formEditKey.

  bool showBarbellPicker;
  ExerciseSet exerciseSet;
  ExerciseForm fullForm;

  // TODO this is so terrible. just use provider.
  bool _updateToMinBarbellWeight(BuildContext context, bool usingBarbell) {
    if (exerciseSet.weight != int.parse(fullForm.weightController.text)) {
      exerciseSet.weight = int.parse(fullForm.weightController.text);
    }
    if (exerciseSet.reps != int.parse(fullForm.repsController.text)) {
      exerciseSet.reps = int.parse(fullForm.repsController.text);
    }
    if (exerciseSet.restPeriodAfter !=
        int.parse(fullForm.restController.text)) {
      exerciseSet.restPeriodAfter = int.parse(fullForm.restController.text);
    }
    if (exerciseSet.title != fullForm.titleController.text) {
      exerciseSet.title = fullForm.titleController.text;
    }
    if (exerciseSet.description != fullForm.descriptionController.text) {
      exerciseSet.description = fullForm.descriptionController.text;
    }

    // we dont need to update anything about barbells if they aren't using a barbell
    if (!usingBarbell) {
      return false;
    }
    // we dont need to update the description always, and we dont have to because the weight is the barbell at this point
    var lifterWeights = Provider.of<LifterWeights>(context, listen: false);
    if (exerciseSet.weight <
        lifterWeights.getbarWeight(barbellLift ?? "Squat")) {
      setState(() {
        exerciseSet.weight = lifterWeights.getbarWeight(barbellLift ?? "Squat");
      });

      // TODO this doesn't show because we close right afterwards.
      scaffoldKey.currentState.showSnackBar(
        //Scaffold.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Weight was less than weight to weight of the $barbellLift bar and you're using a bar, so set weight equal to it")),
      );
      return true;
    }
    // if we set weights and barbells, need to adjust because we might not be able to get that exact weight.
    // so, take care of that here
    // first, update the weights and then, we may need to update the description. Both are affected based on the bar we chose
    setState(() {
      var lifterWeights = Provider.of<LifterWeights>(context, listen: false);
      var closestWeight = lifterWeights.getPickedOverallTotal(
          lift: barbellLift,
          targetWeight: exerciseSet.weight,
          notActuallyThisLift: true);
      if (exerciseSet.weight != closestWeight.floor()) {
        exerciseSet.weight = closestWeight.floor();
        scaffoldKey.currentState.showSnackBar(
          //Scaffold.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Weight modified to meet plates you have. If not a barbell lift, change that first!")),
        );
      }

      exerciseSet.description = "Plates: " +
          lifterWeights.getPickedPlatesAsString(
              lift: barbellLift,
              targetWeight: exerciseSet.weight,
              notActuallyThisLift: true);
    });
    return false;
  }

  FloatingActionButton _getDoneButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(
        Icons.done,
        //size: 200,
        //color: Colors.red,
      ),
      onPressed: () async {
        if (_updateToMinBarbellWeight(context, showBarbellPicker)) {
          await Future.delayed(Duration(seconds: 1));
        }
        //;
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //= ModalRoute.of(context).settings.arguments;
    if (firstBuild) {
      exerciseSet = ModalRoute.of(context).settings.arguments;
      showBarbellPicker = ReusableWidgets.lifts.contains(exerciseSet.title);
      if (showBarbellPicker) {
        barbellLift = exerciseSet.title;
      }
    }
    fullForm = ExerciseForm(
        context: context,
        readOnlyTitle: false,
        exerciseSet: exerciseSet,
        key: _formEditKey,
        barbellLift: barbellLift,
        onValueUpdate: () {
          setState(() {
            _updateToMinBarbellWeight(context, showBarbellPicker);
          });
        });
    _form = fullForm.form;
    firstBuild = false;

    //TextEditingController titleEditingController = TextEditingController();
    return Scaffold(
        key: scaffoldKey,
        appBar: ReusableWidgets.getAppBar(),
        drawer: ReusableWidgets.getDrawer(context),
        floatingActionButton: _getDoneButton(context),
        body: DirectSelectContainer(
            child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                //Consumer<ExerciseSet>(
                //builder: (context, value, child) {
                //return
                _form,
                //},
                //),
                SwitchListTile.adaptive(
                    title: Text("Is this a xPR set?"),
                    value: exerciseSet.thisSetPRSet,
                    onChanged: (newValue) {
                      setState(() {
                        exerciseSet.thisSetPRSet = newValue;
                      });
                    }),
                SwitchListTile.adaptive(
                    title: Text("Is there a barbell used for this lift?"),
                    value: showBarbellPicker,
                    onChanged: (newValue) {
                      setState(() {
                        showBarbellPicker = newValue;
                        if (newValue == true) {
                          if (barbellLift == null) {
                            barbellLift = ReusableWidgets.lifts
                                    .contains(exerciseSet.title)
                                ? exerciseSet.title
                                : "Squat";
                          }
                        }
                        if (newValue == false) {
                          // if they changed their mind, we don't want to use a barbell in calculating weights so disable that.
                          //exerciseSet.weight = 0;
                        }
                        _updateToMinBarbellWeight(context, newValue);
                      });
                    }),

                Visibility(
                  visible: showBarbellPicker,
                  child: Column(
                    children: [
                      Container(
                          alignment: AlignmentDirectional.centerStart,
                          margin: EdgeInsets.only(left: 12),
                          child: Text("Which one?")),
                      Padding(
                        padding: EdgeInsets.fromLTRB(8, 8, 0, 8),
                        child: Container(
                            decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                new BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  spreadRadius: 4,
                                  offset: new Offset(0.0, 0.0),
                                  blurRadius: 15.0,
                                ),
                              ],
                            ),
                            child: ReusableWidgets.getMainLiftPicker(
                                scaffoldKey: scaffoldKey,
                                lift: barbellLift ?? "Squat",
                                onItemSelectedListener: (item, index, context) {
                                  setState(() {
                                    barbellLift = item;
                                    _updateToMinBarbellWeight(
                                        context, showBarbellPicker);
                                    /*
                                    var lifterWeights =
                                        Provider.of<LifterWeights>(context,
                                            listen: false);
                                    if (exerciseSet.weight <
                                        lifterWeights.getbarWeight(item)) {
                                      exerciseSet.weight =
                                          lifterWeights.getbarWeight(item);
                                      //form.
                                      Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Weight was less than weight to weight of the $item bar, now equal to it")),
                                      );
                                    }*/
                                    // call to the model of exercise here...

                                    //lift = ReusableWidgets.lifts[index];
                                    /*updateThisLifPrs(
                            prs: fullCurrentPrs, isRep: tabName == "Rep");*/
                                  });
                                })),
                      ),
                      // TODO this will let us update the rep and weight maxes as the forms change
                      // TODO dont forget to update the ExerciseSet we pass in to be the consumer
                      // also this doesn't work at all right now and i'm not sure why
                      Consumer<ExerciseSet>(
                        builder: (context, formSet, child) {
                          return Consumer<Prs>(builder: (context, prs, child) {
                            // temporarily set this lift to the barbell we chose
                            var currentTitleForm = exerciseSet.title;
                            exerciseSet.title = barbellLift;
                            var _prs = prs.bothLocalPR(lift: exerciseSet
                                /*ExerciseSet(
                              title: barbellLift ?? "Squat",
                              reps: exerciseSet.reps,
                              weight: exerciseSet.weight)*/

                                );
                            // then set it back to whatever they've edited to on the form
                            // note, don't do it this way without e.g. local variables at least.
                            exerciseSet.title = currentTitleForm;
                            //setState(() {});

                            return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("For reference"),
                                  Text(
                                      "${barbellLift ?? 'Squat'} ${formSet.reps ?? exerciseSet.reps}RM: ${_prs["Rep"].weight} "),
                                  Text(
                                      "Max reps for ${formSet.weight ?? exerciseSet.weight}: ${_prs["Weight"].reps}"),
                                ]);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          SizedBox(
            height: 36,
          ),
          //_getDoneButton(context),
        ])));
  }
}
