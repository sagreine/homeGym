import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class ExerciseForm {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController restController = TextEditingController();
  Form form;

  ExerciseForm(
      {@required ExerciseSet exerciseSet,
      @required GlobalKey key,
      @required BuildContext context,
      @required Function onValueUpdate,
      String barbellLift,
      bool readOnlyTitle}) {
    form = _getExerciseForm(
        exerciseSet: exerciseSet,
        key: key,
        context: context,
        barbellLift: barbellLift,
        onValueUpdate: onValueUpdate,
        readOnlyTitle: readOnlyTitle);
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
      bool returnController}) {
    switch (lift.toUpperCase()) {
      case "WEIGHT":
        if (updateFunction != null) {
          updateFunction();
        }
        if (returnController ?? false) {
          return weightController;
        }

        break;
      case "REPS":
        if (updateFunction != null) {
          updateFunction();
        }
        if (returnController ?? false) {
          return repsController;
        }
        break;
      case "REST":
        if (updateFunction != null) {
          updateFunction();
        }
        if (returnController ?? false) {
          return restController;
        }
    }
  }

  TextEditingController _pickController(String lift) {
    return _pickAnything(lift: lift, returnController: true);
  }

  _updateValue(
      {String field,
      //ExerciseSet exerciseSet,
      //String value,
      bool updatingFromSubmit,
      Function updateFunction}) {
    _pickAnything(lift: field, updateFunction: updateFunction);

/*
    switch (field.toUpperCase()) {
      case "WEIGHT":
        if (updatingFromSubmit) {
          exerciseSet.weight = int.parse(value);
        } else {
          exerciseSet.weight = int.parse(weightController.text);
        }
        break;
      case "REPS":
        if (updatingFromSubmit) {
          exerciseSet.reps = int.parse(value);
        } else {
          exerciseSet.reps = int.parse(repsController.text);
        }
        break;
      case "REST":
        if (updatingFromSubmit) {
          exerciseSet.restPeriodAfter = int.parse(value);
        } else {
          exerciseSet.restPeriodAfter = int.parse(restController.text);
        }
        break;
        /*case "Title":
        if (updatingFromSubmit) {
          exerciseSet.title = value;
        } else {
          exerciseSet.title = titleController.text;
        }
        break;
      case "Description":
        if (updatingFromSubmit) {
          exerciseSet.description = value;
        } else {
          exerciseSet.description = descriptionController.text;
        }*/
        break;
    }*/
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
            //onValueUpdate(value);

            // do stuff
            /*switch (field) {
              case "weight":
                exerciseSet.weight = int.parse(weightController.text);
                break;
              case "reps":
                exerciseSet.reps = int.parse(value);
                break;
              case "rest":
                exerciseSet.restPeriodAfter = int.parse(value),
                break;
              case "title":
                exerciseSet.weight = int.parse(weightController.text);
                break;
              case "description":
                exerciseSet.weight = int.parse(weightController.text);
                break;
            }*/
          }
        },
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
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly,
          ],
          //initialValue: exerciseSet.weight.toString(),
          controller: _pickController(field),
          onFieldSubmitted: //(value) => exerciseSet.weight = int.parse(value),
              (value) {
            _updateValue(
                //exerciseSet: exerciseSet,
                field: field,
                //value: value,
                updatingFromSubmit: true,
                updateFunction: onValueUpdate);
            /*() {
                  exerciseSet.weight = int.parse(weightController.text);
                });*/
/*
                    exerciseSet.updateExerciseFull(
                      context: context,
                      setPct
                      reps:
        // reps is a straight pull
        //reps: reps,
        //thisSetPRSet: thisSetPRSet,
        //thisSetProgressSet: thisSetProgressSet,
        weight: int.parse(value),
        description: "Plates: " +
            (thisWeights.getPickedPlatesAsString(
                targetWeight: targetWeight, lift: exerciseSet.title)));
*/
            onValueUpdate(value);
          },
          enableSuggestions: true,
          /*controller:
                                        homeController.formControllerWeight,*/
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
  _getExerciseForm(
      {@required ExerciseSet exerciseSet,
      @required GlobalKey key,
      @required BuildContext context,
      @required Function onValueUpdate,
      String barbellLift,
      bool readOnlyTitle}) {
    titleController.text = exerciseSet.title;
    descriptionController.text = exerciseSet.description;
    repsController.text = exerciseSet.reps.toString();
    weightController.text = exerciseSet.weight.toString();
    restController.text = exerciseSet.restPeriodAfter.toString();
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
              /*Expanded(
                  child: TextFormField(
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
                        labelText: "Reps"),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                    //initialValue: exerciseSet.reps.toString(),
                    controller: repsController,
                    onChanged: (value) {
                      // if when we built this we had PR and now we don't, we don't want to add it back in.
                      /*if (!value.contains("PR") &&
                                          startBuildWithPR) {
                                        justRemovedPR = true;
                                      }*/
                      exerciseSet.reps = int.parse(value);
                      onValueUpdate(value);
                    },
                    enableSuggestions: true,
                    /*controller:
                                        homeController.formControllerReps,*/
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Reps can't be blank";
                      }
                      return null;
                    },
                  ),
                ),*/
              _buildFormField(
                  exerciseSet: exerciseSet,
                  field: "Reps",
                  onValueUpdate: () {
                    exerciseSet.reps = int.parse(repsController.text);
                    // TODO:
                    //exerciseSet.prescribedReps = int.parse(repsController.text);
                    onValueUpdate();
                  }),
              SizedBox(
                width: 2,
              ),
              _buildFormField(
                  exerciseSet: exerciseSet,
                  field: "Weight",
                  onValueUpdate: () {
                    exerciseSet.weight = int.parse(weightController.text);
                    if (barbellLift != null) {
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
                      /*exerciseSet.description = "Plates: " +
                          Provider.of<LifterWeights>(context, listen: false)
                              .getPickedPlatesAsString(
                                  lift: barbellLift,
                                  targetWeight: exerciseSet.weight);*/
                      onValueUpdate();
                    }
                  }),
              SizedBox(
                width: 2,
              ),
              _buildFormField(
                  exerciseSet: exerciseSet,
                  field: "Rest",
                  onValueUpdate: () {
                    exerciseSet.restPeriodAfter =
                        int.parse(restController.text);
                    onValueUpdate();
                  }),

              /*Expanded(
                  child: TextFormField(
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
                      labelText: "Rest after",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                    //initialValue: exerciseSet.restPeriodAfter.toString() ?? "40",
                    controller: restController,
                    onChanged: (value) =>
                        exerciseSet.restPeriodAfter = int.parse(value),
                    autocorrect: true,
                    enableSuggestions: true,
                    /*controller: homeController
                                        .formControllerRestInterval,*/
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Can't be blank";
                      }
                      return null;
                    },
                  ),
                ),*/
            ],
          ),
        ],
      ),
    );
    //});
  }
}
