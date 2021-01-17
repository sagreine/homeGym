import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:flutter/material.dart';
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
  //Form _form;
  final _formEditKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//_formEditKey.

  bool showBarbellPicker;
  ExerciseSet exerciseSet;
  ExerciseForm fullForm;

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
      showBarbellPicker = ReusableWidgets.lifts.contains(exerciseSet.title);
      if (showBarbellPicker) {
        barbellLift = exerciseSet.title;
      }
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
        scaffoldKey: scaffoldKey,
        key: _formEditKey,
        usingBarbell: showBarbellPicker,
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
                    title: Text("Is this a xPR set?"),
                    value: exerciseSet.thisSetPRSet,
                    onChanged: (newValue) {
                      setState(() {
                        exerciseSet.thisSetPRSet = newValue;
                        // TODO: this is likely something we want, just not right now.
                        //exerciseSet.updateExercise(thisSetPRSet: newValue);
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
                        //_updateToMinBarbellWeight(context, newValue);
                        _formEditKey.currentState.save();
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
                                  barbellLift = item;
                                  //_updateToMinBarbellWeight(context, showBarbellPicker);

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
                                  //setState(() {});
                                  //_formEditKey.currentState.save();
                                  fullForm.finalizeWeightsAndDescription(
                                      context: context,
                                      exerciseSet: exerciseSet,
                                      usingBarbell: showBarbellPicker,
                                      barbellLift: barbellLift,
                                      scaffoldKey: scaffoldKey);
                                  setState(() {});
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
