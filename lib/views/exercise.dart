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

  _buildPctTMFormField() {
    return TextFormField(
      initialValue: (exerciseSet.percentageOfTM ?? "").toString(),
      key: _pctTMFieldKey,
      //controller: titleController,
      onChanged: (value) {
        if (value == "" || value == null) {
          exerciseSet.percentageOfTM = null;
        } else {
          exerciseSet.percentageOfTM = double.parse(value);
        }
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
          borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
        ),
        labelText: "Percentage of Training Max to use",
      ),
      keyboardType: TextInputType.number,
      autovalidate: exerciseSet.basedOnPercentageOfTM ?? false,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        //homeController.formController.validator()
        if (value.isEmpty || double.tryParse(value) == 0.0) {
          return "Can't be blank";
        }
        return null;
      },
      //controller: homeController.formControllerTitle,
    );
  }

  FloatingActionButton _getDoneButton(
      BuildContext context, ExerciseSet activity) {
    return FloatingActionButton(
      key: ObjectKey(exerciseSet),
      heroTag: UniqueKey(),
      child: Icon(
        Icons.done,
        //size: 200,
        //color: Colors.red,
      ),
      onPressed: () async {
        if (_formEditKey.currentState.validate()) {
          _formEditKey.currentState.save();
          //_form.key
          //fullForm.saveForm(showBarbellPicker);
          /*if (_updateToMinBarbellWeight(context, showBarbellPicker)) {
          await Future.delayed(Duration(seconds: 1));
        }*/
          //;
          if (!activity.basedOnPercentageOfTM ||
              _pctTMFieldKey.currentState.validate()) {
            Navigator.pop(context, activity);
          }
        }
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
                // if it is based on % of TM, it is not based on weight. so, set that.
                exerciseSet.weight = null;
                weightController.text = "";
                exerciseSet.thisIsRPESet = false;
              }
              if (newValue == true) {
                if (!isNotForBarbellPercentage) {
                  // if they haven't picked a lift yet, we still want to set one -> the default. string and index
                  if (barbellLiftForPercentage == null) {
                    if (exerciseSet.basedOnPercentageOfTM) {
                      barbellLiftForPercentage = ReusableWidgets.lifts[
                          exerciseSet.whichLiftForPercentageofTMIndex ?? 0];
                      if (exerciseSet.whichLiftForPercentageofTMIndex == null) {
                        exerciseSet.whichLiftForPercentageofTMIndex = 0;
                      }
                    } else {
                      barbellLiftForPercentage =
                          ReusableWidgets.lifts.contains(exerciseSet.title)
                              ? exerciseSet.title
                              : "Squat";
                    }
                  }
                } else {
                  // if they haven't picked a lift yet, we still want to set one -> the default
                  if (barbellLift == null) {
                    if (exerciseSet.basedOnBarbellWeight) {
                      barbellLift = ReusableWidgets
                          .lifts[exerciseSet.whichBarbellIndex ?? 0];
                      if (exerciseSet.whichBarbellIndex == null) {
                        exerciseSet.whichBarbellIndex = 0;
                      }
                    } else {
                      barbellLift =
                          ReusableWidgets.lifts.contains(exerciseSet.title)
                              ? exerciseSet.title
                              : "Squat";
                    }
                  }
                }
              }
              // if we just said it is not using a barbell/TM, reflect that
              if (newValue == false) {
                if (!isNotForBarbellPercentage) {
                  barbellLiftForPercentage = null;
                  exerciseSet.percentageOfTM = null;
                  exerciseSet.whichLiftForPercentageofTMIndex = null;
                } else {
                  barbellLift = null;
                  exerciseSet.whichBarbellIndex = null;
                }
                // if they changed their mind, we don't want to use a barbell in calculating weights so disable that.
                //exerciseSet.weight = 0;
              }
              //_updateToMinBarbellWeight(context, newValue);
              // TODO: look into this vs using the finalizeWeightsAndDescription function
              // because this doesn't trigger a recalc of weight but should...

              // TODO: the problem here is that the form is not built yet so it uses the old values. doesn't work even if you
              // put it outside setState because (maybe) the key is the key, if it gets overwritten that's later's problem
              //formEditKey.currentState.save();
              if (!exerciseSet.thisIsMainSet) {
                fullForm.finalizeWeightsAndDescription(
                    context: context,
                    exerciseSet: exerciseSet,
                    usingBarbell: exerciseSet.basedOnBarbellWeight,
                    isBuildingNotUsing: true,
                    barbellLift: (!isNotForBarbellPercentage
                        ? barbellLiftForPercentage
                        : barbellLift),
                    scaffoldKey: scaffoldKey);
              }
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
                  child: ReusableWidgets().getMainLiftPicker(
                      scaffoldKey: scaffoldKey,
                      // if we are Building a Main lift, there will be a 'Main' option.
                      isBuildingMainLift: ((isBuildingNotUsing ?? false) &&
                          (exerciseSet.thisIsMainSet ?? false)),
                      // this is the default lift to show
                      lift: (!isNotForBarbellPercentage
                              ? barbellLiftForPercentage
                              : barbellLift) ??
                          "Squat",
                      // TODO: need to have something here to deal with main lifts
                      // because it isn't in the static list, but we don't want to rely on
                      // returning -1 here because that will be a nightmare to debug in the future.

                      // for now YOLO just use it.
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
                        if (!exerciseSet.thisIsMainSet) {
                          fullForm.finalizeWeightsAndDescription(
                              context: context,
                              exerciseSet: exerciseSet,
                              usingBarbell: exerciseSet.basedOnBarbellWeight,
                              isBuildingNotUsing: true,
                              barbellLift: (!isNotForBarbellPercentage
                                  ? barbellLiftForPercentage
                                  : barbellLift),
                              scaffoldKey: scaffoldKey);
                        }
                        setState(() {});
                        //}
                      })),
            ),

            // we don't want this to exist if they've picked Main
            ((!isNotForBarbellPercentage &&
                        barbellLiftForPercentage == "Main") ||
                    isNotForBarbellPercentage && barbellLift == "Main")
                ? Container()
                :
                // TODO this will let us update the rep and weight maxes as the forms change
                // TODO dont forget to update the ExerciseSet we pass in to be the consumer
                Consumer<ExerciseSet>(
                    builder: (context, formSet, child) {
                      return Consumer<Prs>(builder: (context, prs, child) {
                        // temporarily set this lift to the barbell we chose
                        var currentTitleForm = exerciseSet.title;
                        exerciseSet.title = (!isNotForBarbellPercentage
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
                                  "${(isNotForBarbellPercentage ? barbellLift : barbellLiftForPercentage) ?? 'Squat'} ${formSet.reps ?? exerciseSet.reps ?? ''}RM: ${_prs["Rep"].weight} "),
                              Text(
                                  "Max reps for ${formSet.weight ?? exerciseSet.weight ?? 0}: ${_prs["Weight"].reps}"),
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
  bool isBuildingNotUsing;
  bool isExerciseFromMainLiftPRogram;
  final _pctTMFieldKey = GlobalKey<FormFieldState>();
  TextFormField pctTrainingMaxFormField;

  @override
  Widget build(BuildContext context) {
    //= ModalRoute.of(context).settings.arguments;
    if (firstBuild) {
      final EditExerciseScreenArguments args =
          ModalRoute.of(context).settings.arguments;
      exerciseSet = args.activity;
      isBuildingNotUsing = args.isBuildingNotUsing;
      isExerciseFromMainLiftPRogram = args.isExerciseFromMainLiftPRogram;
      if (exerciseSet.whichBarbellIndex != null) {
        // this first one should only trigger while building and the exercise is Main, but isBuildingNotUsing in there for safety
        if (exerciseSet.whichBarbellIndex == -1 && isBuildingNotUsing) {
          barbellLift = "Main";
        } else {
          barbellLift = ReusableWidgets.lifts[exerciseSet.whichBarbellIndex];
        }
      }
      if (exerciseSet.whichLiftForPercentageofTMIndex != null) {
        if (exerciseSet.whichLiftForPercentageofTMIndex == -1 &&
            isBuildingNotUsing) {
          barbellLiftForPercentage = "Main";
        } else {
          barbellLiftForPercentage = ReusableWidgets
              .lifts[exerciseSet.whichLiftForPercentageofTMIndex];
        }
      }

      /*if (isBuildingNotUsing && exerciseSet.thisIsMainSet) {
        exerciseSet.title = "Main Lift (when picked)";
      }*/
      //showBarbellPicker = ReusableWidgets.lifts.contains(exerciseSet.title);

      //if (showBarbellPicker) {
      //barbellLift = exerciseSet.title;
      //}
    }
    if (exerciseSet.basedOnPercentageOfTM) {
      pctTrainingMaxFormField = _buildPctTMFormField();
    }

    fullForm = ExerciseForm(
        titleController: titleController,
        descriptionController: descriptionController,
        repsController: repsController,
        weightController: weightController,
        restController: restController,
        context: context,
        readOnlyTitle: exerciseSet.thisIsMainSet ?? false,
        exerciseSet: exerciseSet,
        isBuildingNotUsing: isBuildingNotUsing,
        scaffoldKey: scaffoldKey,
        key: _formEditKey,
        usingBarbell: exerciseSet.basedOnBarbellWeight,
        barbellLift: barbellLift,
        onValueUpdate: () {
          // this should not be necessary because it should go up from exerciseSet to exerciseDay... right?
          // a.k.a. we shouldnt really have made exerciseSet we should have done all exerciseSet editing functions at the day level...
          //Provider.of<ExerciseDay>(context, listen: false).tempNotify();
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
        floatingActionButton: _getDoneButton(context, exerciseSet),
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
                    value: exerciseSet.thisSetPRSet ?? false,
                    onChanged: (newValue) {
                      setState(() {
                        exerciseSet.thisSetPRSet = newValue;
                        // TODO: this is likely something we want, just not right now.
                        //exerciseSet.updateExercise(thisSetPRSet: newValue);
                      });
                    }),
                Visibility(
                  visible: (isBuildingNotUsing &&
                      (isExerciseFromMainLiftPRogram ?? false)),
                  child: SwitchListTile.adaptive(
                      title: Text("This is a 'Main' set"),
                      value: exerciseSet.thisIsMainSet ?? false,
                      onChanged: (newValue) {
                        setState(() {
                          exerciseSet.thisIsMainSet = newValue;
                          if (newValue == true) {
                            exerciseSet.title = 'Main Lift (when picked)';
                          }
                          // TODO: this is likely something we want, just not right now.
                          //exerciseSet.updateExercise(thisSetPRSet: newValue);
                        });
                      }),
                ),
                // TODO: make this actually happen?
                SwitchListTile.adaptive(
                    title: Text("If you get reps, increase lifter's 1RM max?"),
                    value: exerciseSet.thisSetProgressSet ?? false,
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
                    value: exerciseSet.thisIsRPESet ?? false,
                    onChanged: (newValue) {
                      setState(() {
                        exerciseSet.thisIsRPESet = newValue;
                        // if this is based on RPE, it is not based on weight nor % TM..
                        if (newValue == true) {
                          exerciseSet.weight = null;
                          exerciseSet.basedOnPercentageOfTM = false;
                          exerciseSet.percentageOfTM = null;
                          weightController.text = "";
                        }
                        // TODO: this is likely something we want, just not right now.
                        //exerciseSet.updateExercise(thisSetPRSet: newValue);
                      });
                    }),

                _getBarbellForWeight(
                  isNotForBarbellPercentage: false,
                  switchListLabel: "Calculate weight from % of a Main lift 1RM",
                  trailingChild: pctTrainingMaxFormField,
                ),
                SizedBox(
                  height: 12,
                ),
              ]),
            ),
          ),

          //_getDoneButton(context),
        ])));
  }
}
