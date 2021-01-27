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

// TODO need to use setters because this needs to notify consumer on the exercise day page. don't edit here,
// use setters with notifyListeners() on them
class _ExerciseViewState extends State<ExerciseView> {
  //ProgramController programsController = ProgramController();
  bool firstBuild;
  String barbellLift;
  String barbellLiftForPercentage;
  //Form _form;
  final _formEditKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//_formEditKey.

  //bool showBarbellPicker;
  //bool showBarbellPercentagePicker;
  ExerciseSet exerciseSet;
  ExerciseForm fullForm;

  @override
  void initState() {
    //programsController.updateProgramList();
    super.initState();
    firstBuild = true;
    // don't default to it, for now.
    //showBarbellPercentagePicker = false;
  }

  FloatingActionButton _getDoneButton(BuildContext context) {
    return FloatingActionButton(
      key: ObjectKey(exerciseSet),
      heroTag: UniqueKey(),
      child: Icon(
        Icons.done,
        //size: 200,
        //color: Colors.red,
      ),
      onPressed: () async {
        _formEditKey.currentState.validate();
        _formEditKey.currentState.save();
        //_form.key
        //fullForm.saveForm(showBarbellPicker);
        /*if (_updateToMinBarbellWeight(context, showBarbellPicker)) {
          await Future.delayed(Duration(seconds: 1));
        }*/
        //;
        Navigator.of(context).pop();
      },
    );
  }

  _getBarbellForWeight(
      {bool isNotForBarbellPercentage = false,
      @required String switchListLabel,
      Widget trailingChild}) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SwitchListTile.adaptive(
          title: Text(switchListLabel),
          value: isNotForBarbellPercentage
              ? exerciseSet.basedOnBarbellWeight ?? false
              : exerciseSet.basedOnPercentageOfTM ?? false,
          onChanged: (newValue) {
            setState(() {
              if (isNotForBarbellPercentage) {
                exerciseSet.basedOnBarbellWeight = newValue;
              } else {
                exerciseSet.basedOnPercentageOfTM = newValue;
              }
              if (newValue == true) {
                if (!isNotForBarbellPercentage) {
                  //if (barbellLiftForPercentage == null) {
                  if (exerciseSet.basedOnBarbellWeight) {
                    barbellLiftForPercentage = ReusableWidgets.lifts[
                        exerciseSet.whichLiftForPercentageofTMIndex ?? 0];
                  } else {
                    barbellLiftForPercentage =
                        ReusableWidgets.lifts.contains(exerciseSet.title)
                            ? exerciseSet.title
                            : "Squat";
                  }
                  //}
                } else {
                  //if (barbellLift == null) {
                  if (exerciseSet.basedOnBarbellWeight) {
                    barbellLift = ReusableWidgets
                        .lifts[exerciseSet.whichBarbellIndex ?? 0];
                  } else {
                    barbellLift =
                        ReusableWidgets.lifts.contains(exerciseSet.title)
                            ? exerciseSet.title
                            : "Squat";
                  }
                  //}
                }
              }
              if (newValue == false) {
                // if they changed their mind, we don't want to use a barbell in calculating weights so disable that.
                //exerciseSet.weight = 0;
              }
              //_updateToMinBarbellWeight(context, newValue);
              // TODO: look into this vs using the finalizeWeightsAndDescription function
              // because this doesn't trigger a recalc of weight but should...
              _formEditKey.currentState.save();
            });
          }),
      Visibility(
        visible: isNotForBarbellPercentage
            ? exerciseSet.basedOnBarbellWeight ?? false
            : exerciseSet.basedOnPercentageOfTM ?? false,
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
                      lift: (!isNotForBarbellPercentage
                              ? barbellLiftForPercentage
                              : barbellLift) ??
                          "Squat",
                      onItemSelectedListener: (item, index, context) {
                        if (isNotForBarbellPercentage == false) {
                          barbellLiftForPercentage = item;
                          exerciseSet.whichLiftForPercentageofTMIndex =
                              ReusableWidgets.lifts.indexOf(item);
                        } else {
                          barbellLift = item;
                          exerciseSet.whichBarbellIndex =
                              ReusableWidgets.lifts.indexOf(item);
                        }
                        // only update the weight using raw values if it is not a percentage
                        //TODO need to implement one way for barbell and another for percentage... that is, populate weight based on percentage here....
                        fullForm.finalizeWeightsAndDescription(
                            context: context,
                            exerciseSet: exerciseSet,
                            usingBarbell: exerciseSet.basedOnBarbellWeight,
                            isBuildingNotUsing: true,
                            barbellLift: (!isNotForBarbellPercentage
                                ? barbellLiftForPercentage
                                : barbellLift),
                            scaffoldKey: scaffoldKey);
                        setState(() {});
                        //}
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
                  exerciseSet.title = (isNotForBarbellPercentage
                      ? barbellLiftForPercentage
                      : barbellLift);
                  var _prs = prs.bothLocalExistingPR(lift: exerciseSet
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
                            "${(isNotForBarbellPercentage ? barbellLiftForPercentage : barbellLift) ?? 'Squat'} ${formSet.reps ?? exerciseSet.reps}RM: ${_prs["Rep"].weight} "),
                        Text(
                            "Max reps for ${formSet.weight ?? exerciseSet.weight}: ${_prs["Weight"].reps}"),
                      ]);
                });
              },
            ),
            if (trailingChild != null)
              SizedBox(
                height: 6,
              ),
            trailingChild != null ? trailingChild : Container(),
            if (trailingChild != null)
              SizedBox(
                height: 6,
              ),
          ],
        ),
      )
    ]);
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController restController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //= ModalRoute.of(context).settings.arguments;
    if (firstBuild) {
      exerciseSet = ModalRoute.of(context).settings.arguments;
      //showBarbellPicker = ReusableWidgets.lifts.contains(exerciseSet.title);

      //if (showBarbellPicker) {
      //barbellLift = exerciseSet.title;
      //}
    }
    fullForm = ExerciseForm(
        titleController: titleController,
        descriptionController: descriptionController,
        repsController: repsController,
        weightController: weightController,
        restController: restController,
        context: context,
        readOnlyTitle: false,
        exerciseSet: exerciseSet,
        isBuildingNotUsing: true,
        scaffoldKey: scaffoldKey,
        key: _formEditKey,
        usingBarbell: exerciseSet.basedOnBarbellWeight,
        barbellLift: barbellLift,
        onValueUpdate: () {
          setState(() {
            //_updateToMinBarbellWeight(context, showBarbellPicker);
          });
        });

    //_form = fullForm.form;
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
                fullForm.form,
                //},
                //),
                SwitchListTile.adaptive(
                    title: Text("This is a xPR set"),
                    value: exerciseSet.thisSetPRSet,
                    onChanged: (newValue) {
                      setState(() {
                        exerciseSet.thisSetPRSet = newValue;
                        // TODO: this is likely something we want, just not right now.
                        //exerciseSet.updateExercise(thisSetPRSet: newValue);
                      });
                    }),
                // TODO: make this actually happen?
                SwitchListTile.adaptive(
                    title: Text("If you get reps, increase lifter's 1RM max?"),
                    value: exerciseSet.thisSetProgressSet,
                    onChanged: (newValue) {
                      setState(() {
                        exerciseSet.thisSetProgressSet = newValue;
                        // TODO: this is likely something we want, just not right now.
                        //exerciseSet.updateExercise(thisSetPRSet: newValue);
                      });
                    }),

                _getBarbellForWeight(
                    isNotForBarbellPercentage: true,
                    switchListLabel: "There is a barbell used for this lift"),
                SwitchListTile.adaptive(
                    title: Text("This is an RPE set"),
                    value: exerciseSet.thisSetProgressSet,
                    onChanged: (newValue) {
                      setState(() {
                        exerciseSet.thisIsRPESet = newValue;
                        // TODO: this is likely something we want, just not right now.
                        //exerciseSet.updateExercise(thisSetPRSet: newValue);
                      });
                    }),
                _getBarbellForWeight(
                  isNotForBarbellPercentage: false,
                  switchListLabel: "Calculate weight from % of a Main lift 1RM",
                  trailingChild: TextFormField(
                    //initialValue: exerciseSet.title,
                    //controller: titleController,
                    onChanged: (value) {
                      exerciseSet.percentageOfTM = double.parse(value);
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
                      labelText: "Percentage of Training Max to use",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      //homeController.formController.validator()
                      if (value.isEmpty) {
                        return "Can't be blank";
                      }
                      return null;
                    },
                    //controller: homeController.formControllerTitle,
                  ),
                ),
              ]),
            ),
          ),

          //_getDoneButton(context),
        ])));
  }
}
