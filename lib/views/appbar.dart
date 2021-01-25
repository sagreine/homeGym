import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

class ReusableWidgets {
  static List<String> lifts = [
    "Squat",
    "Press",
    "Deadlift",
    "Bench",
  ];

  static getMainLiftPicker(
      {GlobalKey<ScaffoldState> scaffoldKey,
      String lift,
      Function(String, int, BuildContext) onItemSelectedListener}) {
    DirectSelectItem<String> getDropDownMenuItem(String value) {
      return DirectSelectItem<String>(
          itemHeight: 56,
          value: value,
          itemBuilder: (context, value) {
            return Text(value);
          });
    }

    _getDslDecoration() {
      return BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(width: 1, color: Colors.black12),
          top: BorderSide(width: 1, color: Colors.black12),
        ),
      );
    }

    return Card(
        child: Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
            child: Padding(
                child: DirectSelectList<String>(
                  values: lifts,
                  onUserTappedListener: () {
                    var snackBar =
                        SnackBar(content: Text('Hold and drag instead of tap'));
                    scaffoldKey.currentState.showSnackBar(snackBar);
                  },
                  defaultItemIndex: lifts.indexOf(lift),
                  itemBuilder: (String value) => getDropDownMenuItem(value),
                  focusedItemDecoration: _getDslDecoration(),
                  onItemSelectedListener: onItemSelectedListener,
                ),
                /*(item, index, context) {
                      setState(() {
                        lift = _lifts[index];
                        updateThisLifPrs(
                            prs: fullCurrentPrs, isRep: tabName == "Rep");
                      });
                    }),*/
                padding: EdgeInsets.only(left: 22))),
        Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(
              Icons.unfold_more,
              color: Colors.blueAccent,
            ))
      ],
    ));
  }

  static getAppBar({TabController tabController, List<Tab> tabs}) {
    return AppBar(
      title: Text("Home Gym TV"),
      bottom: tabController == null
          ? null
          : new TabBar(
              controller: tabController,
              tabs: tabs,
            ),
    );
  }

  static getDrawer(BuildContext context) {
    bool isNewRouteSameAsCurrent = false;
    String newRouteName;

    return Consumer<Muser>(builder: (context, user, child) {
      return Drawer(
        child: Column(children: [
          DrawerHeader(
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    //color: Colors.blueGrey[200],
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Color(0xFFCB8421), //Colors.brown.shade800,
                          backgroundImage: user.fAuthUser.photoURL == null ||
                                  user.fAuthUser.photoURL.isEmpty
                              ? AssetImage("assets/images/pos_icon.png")
                              : NetworkImage(user.getPhotoURL()),
                        ),
                        SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 35),
                            //Image.asset("assets/images/pos_icon.png"),
                            Text(user.getDisplayName()),
                            SizedBox(height: 10),
                            InkWell(
                              child: Text(
                                "View Profile",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              onTap: () {
                                newRouteName = "/profile";
                                Navigator.canPop(context);
                                // if the current route is the exact location we're at (first on the stack), mark that
                                Navigator.popUntil(context, (route) {
                                  if (route.settings.name == newRouteName) {
                                    isNewRouteSameAsCurrent = true;
                                  } else {
                                    isNewRouteSameAsCurrent = false;
                                  }
                                  return true;
                                });
                                // if it isn't, go to the new route
                                if (!isNewRouteSameAsCurrent) {
                                  Navigator.pushNamed(context, newRouteName);
                                }
                                // again if it is, just pop the drawer away
                                else {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                      //trailing: ,
                    ),
                  ),
                ),
                // ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView(children: [
              ListTile(
                  title: Text("Pick Lift"),
                  leading: Icon(Icons.fitness_center),
                  // TODO: this is yet messed up because login doesn't route to pick_day it builds it's own.... so breaks if we do this the first time through.
                  onTap: () {
                    newRouteName = "/pick_day";
                    // if the current route is the exact location we're at (first on the stack), mark that
                    Navigator.popUntil(context, (route) {
                      if (route.settings.name == newRouteName) {
                        isNewRouteSameAsCurrent = true;
                      } else {
                        isNewRouteSameAsCurrent = false;
                      }
                      return true;
                    });
                    // if it isn't, go to the new route
                    if (!isNewRouteSameAsCurrent) {
                      Navigator.pushNamed(context, newRouteName);
                    }
                    // again if it is, just pop the drawer away
                    else {
                      Navigator.pop(context);
                    }
                  }),
              ListTile(
                  title: Text("Do Lift"),
                  leading: Icon(Icons.directions_run),
                  // typical is icons, and need a similar iimage for all (image is bigger than icon) but to think about
                  //leading: Image.asset("assets/images/pos_icon.png"),
                  onTap: () {
                    newRouteName = "/today";
                    // if the current route is the exact location we're at (first on the stack), mark that
                    Navigator.popUntil(context, (route) {
                      if (route.settings.name == newRouteName) {
                        isNewRouteSameAsCurrent = true;
                      } else {
                        isNewRouteSameAsCurrent = false;
                      }
                      return true;
                    });
                    // if it isn't, go to the new route
                    if (!isNewRouteSameAsCurrent) {
                      Navigator.pushNamed(context, newRouteName);
                    }
                    // again if it is, just pop the drawer away
                    else {
                      Navigator.pop(context);
                    }
                  }),
              ListTile(
                  title: Text("My Weights"),
                  // rotate this icon
                  leading: RotatedBox(
                      //alignment: Alignment.center,
                      //transform: Matrix4.rotationX(pi),
                      quarterTurns: 3,
                      child: Icon(Icons.filter_list)),
                  onTap: () {
                    newRouteName = "/lifter_weights";
                    // if the current route is the exact location we're at (first on the stack), mark that
                    Navigator.popUntil(context, (route) {
                      if (route.settings.name == newRouteName) {
                        isNewRouteSameAsCurrent = true;
                      } else {
                        isNewRouteSameAsCurrent = false;
                      }
                      return true;
                    });
                    // if it isn't, go to the new route
                    if (!isNewRouteSameAsCurrent) {
                      Navigator.pushNamed(context, newRouteName);
                    }
                    // again if it is, just pop the drawer away
                    else {
                      Navigator.pop(context);
                    }
                  }),
              ListTile(
                  title: Text("My Maxes"),
                  //leading: Icon(Icons.description),
                  leading: Icon(Icons.format_list_bulleted),
                  onTap: () {
                    newRouteName = "/lifter_maxes";
                    // if the current route is the exact location we're at (first on the stack), mark that
                    Navigator.popUntil(context, (route) {
                      if (route.settings.name == newRouteName) {
                        isNewRouteSameAsCurrent = true;
                      } else {
                        isNewRouteSameAsCurrent = false;
                      }
                      return true;
                    });
                    // if it isn't, go to the new route
                    if (!isNewRouteSameAsCurrent) {
                      Navigator.pushNamed(context, newRouteName);
                    }
                    // again if it is, just pop the drawer away
                    else {
                      Navigator.pop(context);
                    }
                  }),
              ListTile(
                  title: Text("My PRs"),
                  //leading: Icon(Icons.description),
                  leading: Icon(Icons.trending_up), //whatshot_outlined
                  onTap: () {
                    newRouteName = "/prs";
                    // if the current route is the exact location we're at (first on the stack), mark that
                    Navigator.popUntil(context, (route) {
                      if (route.settings.name == newRouteName) {
                        isNewRouteSameAsCurrent = true;
                      } else {
                        isNewRouteSameAsCurrent = false;
                      }
                      return true;
                    });
                    // if it isn't, go to the new route
                    if (!isNewRouteSameAsCurrent) {
                      Navigator.pushNamed(context, newRouteName);
                    }
                    // again if it is, just pop the drawer away
                    else {
                      Navigator.pop(context);
                    }
                  }),
              ListTile(
                  title: Text("My Lifts"),
                  //leading: Icon(Icons.description),
                  leading: Icon(Icons.video_library),
                  onTap: () {
                    newRouteName = "/lifter_videos";
                    // if the current route is the exact location we're at (first on the stack), mark that
                    Navigator.popUntil(context, (route) {
                      if (route.settings.name == newRouteName) {
                        isNewRouteSameAsCurrent = true;
                      } else {
                        isNewRouteSameAsCurrent = false;
                      }
                      return true;
                    });
                    // if it isn't, go to the new route
                    if (!isNewRouteSameAsCurrent) {
                      Navigator.pushNamed(context, newRouteName);
                    }
                    // again if it is, just pop the drawer away
                    else {
                      Navigator.pop(context);
                    }
                  }),
              ListTile(
                  title: Text("My Programs"),
                  //leading: Icon(Icons.description),
                  leading: Icon(EvilIcons.archive),
                  onTap: () {
                    newRouteName = "/lifter_programs";
                    // if the current route is the exact location we're at (first on the stack), mark that
                    Navigator.popUntil(context, (route) {
                      if (route.settings.name == newRouteName) {
                        isNewRouteSameAsCurrent = true;
                      } else {
                        isNewRouteSameAsCurrent = false;
                      }
                      return true;
                    });
                    // if it isn't, go to the new route
                    if (!isNewRouteSameAsCurrent) {
                      Navigator.pushNamed(
                        context,
                        newRouteName,
                      );
                    }
                    // again if it is, just pop the drawer away
                    else {
                      Navigator.pop(context);
                    }
                  }),
              /*
              ListTile(
                  title: Text("Check Form Picture"),
                  //leading: Icon(Icons.description),
                  leading: Icon(Icons.accessibility),
                  onTap: () {
                    newRouteName = "/form_check";
                    // if the current route is the exact location we're at (first on the stack), mark that
                    Navigator.popUntil(context, (route) {
                      if (route.settings.name == newRouteName) {
                        isNewRouteSameAsCurrent = true;
                      } else {
                        isNewRouteSameAsCurrent = false;
                      }
                      return true;
                    });
                    // if it isn't, go to the new route
                    if (!isNewRouteSameAsCurrent) {
                      Navigator.pushNamed(context, newRouteName);
                    }
                    // again if it is, just pop the drawer away
                    else {
                      Navigator.pop(context);
                    }
                  }),
                  */ /*
              ListTile(
                  title: Text("Check Form Video"),
                  //leading: Icon(Icons.description),
                  leading: Icon(Icons.flash_auto), //auto_awesome or fix
                  onTap: () {
                    newRouteName = "/form_check_copy";
                    // if the current route is the exact location we're at (first on the stack), mark that
                    Navigator.popUntil(context, (route) {
                      if (route.settings.name == newRouteName) {
                        isNewRouteSameAsCurrent = true;
                      } else {
                        isNewRouteSameAsCurrent = false;
                      }
                      return true;
                    });
                    // if it isn't, go to the new route
                    if (!isNewRouteSameAsCurrent) {
                      Navigator.pushNamed(context, newRouteName);
                    }
                    // again if it is, just pop the drawer away
                    else {
                      Navigator.pop(context);
                    }
                  }),*/
              ListTile(
                  title: Text("Help"),
                  leading: Icon(Icons.help),
                  onTap: () {
                    newRouteName = "/help";
                    // if the current route is the exact location we're at (first on the stack), mark that
                    Navigator.popUntil(context, (route) {
                      if (route.settings.name == newRouteName) {
                        isNewRouteSameAsCurrent = true;
                      } else {
                        isNewRouteSameAsCurrent = false;
                      }
                      return true;
                    });
                    // if it isn't, go to the new route
                    if (!isNewRouteSameAsCurrent) {
                      Navigator.pushNamed(context, newRouteName);
                    }
                    // again if it is, just pop the drawer away
                    else {
                      Navigator.pop(context);
                    }
                  }),
              ListTile(
                title: Text("Settings"),
                leading: Icon(Icons.settings),
                onTap: () {
                  newRouteName = "/settings";
                  // if the current route is the exact location we're at (first on the stack), mark that
                  Navigator.popUntil(context, (route) {
                    if (route.settings.name == newRouteName) {
                      isNewRouteSameAsCurrent = true;
                    } else {
                      isNewRouteSameAsCurrent = false;
                    }
                    return true;
                  });
                  // if it isn't, go to the new route
                  if (!isNewRouteSameAsCurrent) {
                    Navigator.pushNamed(context, newRouteName);
                  }
                  // again if it is, just pop the drawer away
                  else {
                    Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                title: Text("Log Out"),
                leading: Icon(Icons.exit_to_app),
                onTap: () async {
                  // wait while we log the user out.
                  var exerciseDay =
                      Provider.of<ExerciseDay>(context, listen: false);
                  /*var prs = Provider.of<Prs>(context, listen: false);
                  if (prs.prs != null) {
                    prs.prs.clear();
                  }
                  prs.prs = null;*/
                  exerciseDay.lift = null;

                  await user.logout();

                  print("successfully logged out");
                  // pop until we get to the login page
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (Route<dynamic> route) => false,
                  );
                  //arguments: true); // this doesn't actually work because of static + on every page
                  // so clicking open the drawer fires events
                },
              ),
            ]),
          ),
        ]),
      );
    });
  }
}

// why not just extend form? whatevs
class ExerciseForm {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController restController = TextEditingController();

  Form form;
  //ExerciseSet _exerciseSet;

  /*void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    repsController.dispose();
    weightController.dispose();
    restController.dispose();
  }*/

  ExerciseForm({
    @required ExerciseSet exerciseSet,
    @required GlobalKey<ScaffoldState> scaffoldKey,
    @required GlobalKey key,
    @required BuildContext context,
    @required Function onValueUpdate,
    @required String barbellLift,
    @required bool readOnlyTitle,
    @required bool usingBarbell,
    @required bool isBuildingNotUsing,
    @required this.titleController,
    @required this.descriptionController,
    @required this.repsController,
    @required this.weightController,
    @required this.restController,
  }) {
    form = _getExerciseForm(
        exerciseSet: exerciseSet,
        scaffoldKey: scaffoldKey,
        key: key,
        context: context,
        usingBarbell: usingBarbell,
        barbellLift: barbellLift,
        onValueUpdate: onValueUpdate,
        isBuildingNotUsing: isBuildingNotUsing,
        readOnlyTitle: readOnlyTitle);
    /*this.titleController = titleController;
    this.descriptionController = descriptionController;
    this.repsController = repsController;
    this.weightController = weightController;
    this.restController = restController;*/
  }

  /// This should not be your default. Consider using _formEditKey.currentState.save() instead
  /// Only use this if that doesn't work for you, due to building/rebuilding outside of the form
  ///
  /// For example, if you just need to update form values based on other values in the form, then rebuild
  /// that function will safely do that for you.
  ///
  /// However, if for some reason you need to rebuild, then finalize weight and description, use this.
  /// An example of both of these is seen in exercise.dart. When we close the form, we use .save().
  /// But, when we need to update the form based on a value outside of the form, we have to reach
  /// into the form to call this function before rebuildling.
  void finalizeWeightsAndDescription({
    @required BuildContext context,
    @required ExerciseSet exerciseSet,
    @required bool usingBarbell,
    @required String barbellLift,
    @required GlobalKey<ScaffoldState> scaffoldKey,
    @required bool isBuildingNotUsing,
  }) {
    if (exerciseSet.weight != int.tryParse(weightController.text)) {
      exerciseSet.weight = int.tryParse(weightController.text);
    }

    /*if (_exerciseSet.reps != int.parse(repsController.text)) {
      _exerciseSet.reps = int.parse(repsController.text);
    }
    if (_exerciseSet.restPeriodAfter != int.parse(restController.text)) {
      _exerciseSet.restPeriodAfter = int.parse(restController.text);
    }
    if (_exerciseSet.title != titleController.text) {
      _exerciseSet.title = titleController.text;
    }
    if (_exerciseSet.description != descriptionController.text) {
      _exerciseSet.description = descriptionController.text;
    }*/

    // we dont need to update anything about barbells if they aren't using a barbell
    // TODO: RPE will need to be done here too. -> or just have a "notSettingWeight" flag?
    // we want this to be done in the using-the-program phase so they get the calculator, so use that bool
    if (!usingBarbell ||
        (exerciseSet.basedOnPercentageOfTM && isBuildingNotUsing)) {
      return;
    }
    // we dont need to update the description always, and we dont have to because the weight is the barbell at this point
    var lifterWeights = Provider.of<LifterWeights>(context, listen: false);
    if (exerciseSet.weight <
        lifterWeights.getbarWeight(barbellLift ?? "Squat")) {
      exerciseSet.weight = lifterWeights.getbarWeight(barbellLift ?? "Squat");

      // TODO this doesn't show on FAB press because we close right afterwards. make this function return a bool
      // and then either pass that to the Navigator or just delay and do it there.
      scaffoldKey.currentState.showSnackBar(
        //Scaffold.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Weight was less than weight to weight of the $barbellLift bar and you're using a bar, so set weight equal to it")),
      );
      return;
    }
    // if we set weights and barbells, need to adjust because we might not be able to get that exact weight.
    // so, take care of that here
    // first, update the weights and then, we may need to update the description. Both are affected based on the bar we chose

    // TODO: if we really wanted to, we could populate all 'we can get this weight' up front (on login) and store it and query it here
    // to reduce latency, rather than doing it lazily
    var closestWeight = lifterWeights.getPickedOverallTotal(
        lift: barbellLift ?? "Squat",
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
            lift: barbellLift ?? "Squat",
            targetWeight: exerciseSet.weight,
            notActuallyThisLift: true);

    //return false;
  }

  _pickAnything(
      {String lift,
      Function

          ///(dynamic value)
          /*(
              {String field,
              String exerciseSet,
              String value,
              bool updateFromSubmit})*/
          updateFunction,
      bool returnController,
      bool returnExerciseSetVariable}) {
    switch (lift.toUpperCase()) {
      case "WEIGHT":
        updateFunction?.call();

        if (returnController ?? false) {
          return weightController;
        }
        /*if(returnExerciseSetVariable ?? false) {
          return _exerciseSet.weight;
        }*/

        break;
      case "REPS":
        updateFunction?.call();
        if (returnController ?? false) {
          return repsController;
        }
        break;
      case "REST":
        updateFunction?.call();
        if (returnController ?? false) {
          return restController;
        }
    }
  }

  TextEditingController _pickController(String lift) {
    return _pickAnything(lift: lift, returnController: true);
  }
  /*dynamic _pickExerciseSetVariable(String lift) {
    return _pickAnything(lift: lift, returnController: false, returnExerciseSetVariable = true);
  }*/

  _updateValue(
      {String field,
      //ExerciseSet exerciseSet,
      //String value,
      bool updatingFromSubmit,
      Function updateFunction}) {
    _pickAnything(lift: field, updateFunction: updateFunction);
  }

  _buildFormField(
      {String field, ExerciseSet exerciseSet, Function onValueUpdate}) {
    return Expanded(
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            _updateValue(
                //exerciseSet: exerciseSet,
                field: field,
                updatingFromSubmit: false,
                updateFunction: onValueUpdate //() {
                //exerciseSet.weight = int.parse(weightController.text);
                //},
                );
            exerciseSet.updateExercise(thisSetPRSet: exerciseSet.thisSetPRSet);
            //onValueUpdate(value);

          }
        },
        //TextField
        child: TextFormField(
          //key: Key(exerciseSet.weight.toString()),
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
            labelText: field,
          ),
          // we don't allow editing of weight if this is based on a percentage...
          // TODO: RPE ... ?
          readOnly: exerciseSet.basedOnPercentageOfTM &&
              field.toUpperCase() == "WEIGHT",
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly,
          ],
          //initialValue: exerciseSet.weight.toString(),
          controller: _pickController(field),
          // here we directly update the value of exerciseSet as the field is changed
          // but we don't call any callbacks. that's why submitted and onfocus are necessary -
          // the callback is where we check the weight against available weights + description.
          // we have to do this, and not just do the validation withhin the form because they could change the form field
          // and hit the FAB to be done without saving, which doesn't fire onSubmit nor onFocusLost and we don't want that to lose changes.
          // using built-in form save we will have the same problem - how to pick the field from exerciseSet to update in each call of this func?
          // and if we're doing that already why not just do it first in onChanged too (except not overriding weight there)
          /*onChanged: (value) {
            _updateValue(
                //exerciseSet: exerciseSet,
                field: field,
                //value: value,
                updatingFromSubmit: false,
                updateFunction: (value) {
                  _pickController(field).text;
                });
          },*/
          onSaved: (value) {
            _updateValue(
                //exerciseSet: exerciseSet,
                field: field,
                updatingFromSubmit: false,
                updateFunction: onValueUpdate //() {
                //exerciseSet.weight = int.parse(weightController.text);
                //},
                );
            exerciseSet.updateExercise(thisSetPRSet: exerciseSet.thisSetPRSet);
          },
          onFieldSubmitted: //(value) => exerciseSet.weight = int.parse(value),
              (value) {
            _updateValue(
                //exerciseSet: exerciseSet,
                field: field,
                //value: value,
                updatingFromSubmit: true,
                updateFunction: onValueUpdate);
            exerciseSet.updateExercise(thisSetPRSet: exerciseSet.thisSetPRSet);
            //onValueUpdate(value);
          },
          enableSuggestions: true,
          validator: (value) {
            if (value.isEmpty) {
              return "$field can't be blank";
            }
            return null;
          },
        ),
      ),
    );
  }

// NOTE
// Description and Text are set to update when on changed.
// TODO: test that this isn't terrible given the controllers, or just remove the controllers entirely
  Form _getExerciseForm(
      {@required ExerciseSet exerciseSet,
      @required GlobalKey<FormState> key,
      @required GlobalKey<ScaffoldState> scaffoldKey,
      @required BuildContext context,
      @required Function onValueUpdate,
      @required bool isBuildingNotUsing,
      bool usingBarbell,
      String barbellLift,
      bool readOnlyTitle}) {
    /*if (_exerciseSet != exerciseSet) {
      _exerciseSet = exerciseSet;
    }*/
    if (titleController.text != exerciseSet.title) {
      titleController.text = exerciseSet.title;
    }
    if (descriptionController.text != exerciseSet.description) {
      descriptionController.text = exerciseSet.description;
    }
    if (repsController.text != exerciseSet.reps.toString()) {
      if (exerciseSet.reps != null) {
        repsController.text = exerciseSet.reps.toString();
      } else {
        repsController.text = ""; //0.toString();
      }
    }
    if (weightController.text != exerciseSet.weight.toString()) {
      if (exerciseSet.weight != null) {
        weightController.text = exerciseSet.weight.toString();
      } else {
        weightController.text = "";
        // 0.toString();
      }
    }
    if (restController.text != exerciseSet.restPeriodAfter.toString()) {
      if (exerciseSet.restPeriodAfter != null) {
        restController.text = exerciseSet.restPeriodAfter.toString();
      } else {
        restController.text = "";
        //0.toString();
      }
    }

    //Consumer<ExerciseSet>(builder: (context, exerciseSet, child) {

    return form = Form(
      autovalidate: true,

      key: key,
      // would want Consumer of Exercise here, to leverage Provider, but doing via controller for now...
      child: Column(
        children: [
          Text("Edit this set"),
          SizedBox(height: 8),
          TextFormField(
            textCapitalization: TextCapitalization.sentences,
            //initialValue: exerciseSet.title,
            controller: titleController,
            onChanged: (value) {
              exerciseSet.title = value;
              onValueUpdate(value);
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
              labelText: "Exercise for this set",
            ),
            validator: (value) {
              //homeController.formController.validator()
              if (value.isEmpty) {
                return "Title can't be blank";
              }
              return null;
            },
            //controller: homeController.formControllerTitle,
          ),
          SizedBox(height: 3),
          TextFormField(
            textCapitalization: TextCapitalization.sentences,
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
              labelText:
                  "Description [EDIT THIS LAST, CHANGING WEIGHT WILL OVERWRITE]",
            ),
            //initialValue: exerciseSet.description,
            controller: descriptionController,
            onChanged: (value) {
              exerciseSet.description = value;
              onValueUpdate();
            },
            autocorrect: true,
            enableSuggestions: true,
            /* controller:
                                  homeController.formControllerDescription,*/
            validator: (value) {
              //homeController.formController.validator()
              if (value.isEmpty) {
                return "Description can't be blank";
              }
              return null;
            },
          ),
          SizedBox(height: 8.0),
          Row(
            children: <Widget>[
              _buildFormField(
                  exerciseSet: exerciseSet,
                  field: "Reps",
                  onValueUpdate: () {
                    exerciseSet.reps = int.tryParse(repsController.text);
                    // TODO:
                    onValueUpdate();
                  }),
              SizedBox(
                width: 2,
              ),
              _buildFormField(
                  exerciseSet: exerciseSet,
                  field: "Weight",
                  onValueUpdate: () {
                    exerciseSet.weight = int.tryParse(weightController.text);
                    finalizeWeightsAndDescription(
                        context: context,
                        exerciseSet: exerciseSet,
                        usingBarbell: usingBarbell,
                        scaffoldKey: scaffoldKey,
                        barbellLift: barbellLift,
                        isBuildingNotUsing: isBuildingNotUsing);
                    /*if (barbellLift != null) {
                      var lifterWeights =
                          Provider.of<LifterWeights>(context, listen: false);
                      var closestWeight = lifterWeights.getPickedOverallTotal(
                          lift: barbellLift,
                          targetWeight: exerciseSet.weight,
                          notActuallyThisLift: true);
                      if (exerciseSet.weight != closestWeight.floor()) {
                        exerciseSet.weight = closestWeight.floor();
                      }

                      exerciseSet.description = "Plates: " +
                          lifterWeights.getPickedPlatesAsString(
                              lift: barbellLift,
                              targetWeight: exerciseSet.weight,
                              notActuallyThisLift: true);
                      
                    }*/
                    onValueUpdate();
                  }),
              SizedBox(
                width: 2,
              ),
              _buildFormField(
                  exerciseSet: exerciseSet,
                  field: "Rest",
                  onValueUpdate: () {
                    exerciseSet.restPeriodAfter =
                        int.tryParse(restController.text);
                    onValueUpdate();
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
