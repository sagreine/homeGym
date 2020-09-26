//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/gestures.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fling/flutter_fling.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:confetti/confetti.dart';

//sagre.HomeGymTV.player

// more of this should go in controller functions

class DoLiftView extends StatefulWidget {
  @override
  _DoLiftViewState createState() => _DoLiftViewState();
}

class _DoLiftViewState extends State<DoLiftView>
    with AutomaticKeepAliveClientMixin<DoLiftView> {
  /*static const TextStyle timerTextStyle = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.bold,
  );*/
  // put this in the parent class and pass through, now that there is a parent class....
  // and/or etc. to have the state tracked.
  HomeController homeController = HomeController();
  ExerciseSet exercise;

  final _formkey = GlobalKey<FormState>();

  // i don't know if we need these? shouldn't, ideally..
  FlutterFling fling;
  FlingController flingController = FlingController();

  // temporary. and should be in MODEL for this page so we can save state via provider.. controller.
  bool doVideo;
// temporary. and should be in controller.
  bool doCast;

  bool _noDayPickedOnEntry;

  //Container banner;

  Container _showBanner() {
    if (_noDayPickedOnEntry) {
      return Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[500]))),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 8, right: 24, top: 16),
              child: Text(
                  "You didn't pick a program, so using a default Squat program for now. Please pick a day and program."),
            ),
            ButtonBar(
              children: [
                FlatButton(
                  child: Text(
                    "DISMISS",
                    style: TextStyle(color: Colors.purple[300], fontSize: 16),
                  ),
                  onPressed: () {
                    setState(() {
                      _noDayPickedOnEntry = false;
                    });
                  },
                ),
                FlatButton(
                  child: Text(
                    "PICK A PROGRAM",
                    style: TextStyle(color: Colors.purple[300], fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, "/pick_day");
                  },
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    fling = FlutterFling();
    doVideo = false;
    doCast = false;
    _noDayPickedOnEntry = false;
    // this is bad, but whatever.
    homeController.formControllerRestInterval.text = "90";
    //homeController.serverListen();

    //confettiController
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    var exerciseDay = Provider.of<ExerciseDay>(context, listen: false);

    // if they came here without picking a day first, pick squat by default and tell them about it.
    // TODO this should definitely not be in the UI though...
    if (exerciseDay.lift == null) {
      _noDayPickedOnEntry = true;
      exerciseDay.lift = "Squat";
      PickDayController pickDayController = PickDayController();
      await pickDayController.getExercises(context, "widowmaker3_2");
      exerciseDay = Provider.of<ExerciseDay>(context, listen: false);
    }

    exercise = exerciseDay.exercises[exerciseDay.currentSet];
    homeController.displayInExerciseInfo(exercise: exercise);
  }

  @override
  void dispose() async {
    super.dispose();
    await FlutterFling.stopDiscoveryController();
    homeController.dispose();
  }

  @override
  bool get wantKeepAlive {
    return true;
  }

  Future showCastDevicePickerDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Consumer<FlingMediaModel>(builder: (context, flingy, child) {
            return WillPopScope(
                // I think you just return true, not pop yourself....
                onWillPop: () async {
                  setState(() {
                    doCast = false;
                  });
                  return true;
                }, // async => false,
                child: AlertDialog(
                    scrollable: true,
                    title: Text("Cast to"),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: double.maxFinite,
                          height: 100,
                          child: ListView.builder(
                            //shrinkWrap: true,
                            itemCount: flingy.flingDevices == null
                                ? 0
                                : flingy.flingDevices.length,
                            // should check to rebuild? this could be out of date.
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: Icon(Icons.tv),
                                title: Text(
                                    flingy.flingDevices.elementAt(index).name),
                                onTap: () {
                                  // or check here before we let them select it..
                                  flingController.selectPlayer(context,
                                      flingy.flingDevices.elementAt(index));
                                  doCast = true;
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ))
                    ]),
                    actions: [
                      FlatButton(
                        child: Text("Don't cast"),
                        onPressed: () {
                          setState(() {
                            doCast = false;
                          });
                          Navigator.of(context).pop();
                        },
                      )
                    ]));
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //var exerciseDay = Provider.of<ExerciseDay>(context, listen: false);
    //final DoLiftView args = ModalRoute.of(context).settings.arguments;
    return Consumer<FlingMediaModel>(builder: (context, flingy, child) {
      return SafeArea(
        child: (Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: homeController.confettiController,
                blastDirection:
                    pi / 2, // don't specify a direction, blast randomly
                shouldLoop: false,
                maxBlastForce: 3, // set a lower max blast force
                minBlastForce: 1, // set a lower min blast force
                emissionFrequency: 0.9,
                numberOfParticles: 10, // a lot of particles at once
                gravity: .7,
              ),
            ),
            Column(
              children: <Widget>[
                // if they didn't pick a day on the way in, yell at them about it here.
                _showBanner(),
                Row(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 280,
                      child: TextField(
                        readOnly: true,
                        style: TextStyle(fontSize: 24),
                        textAlign: TextAlign.center,
                        enabled: false,
                        // remove border and center
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        controller: homeController.formControllerTitle,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView(children: <Widget>[
                    Form(
                      autovalidate: true,
                      key: _formkey,
                      // would want Consumer of Exercise here, to leverage Provider, but doing via controller for now...
                      child: Column(
                        children: [
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
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 1.0),
                              ),
                              labelText: "Description for this set",
                            ),
                            autocorrect: true,
                            enableSuggestions: true,
                            controller:
                                homeController.formControllerDescription,
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
                              Expanded(
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
                                        borderSide: BorderSide(
                                            color: Colors.blueGrey, width: 1.0),
                                      ),
                                      labelText: "Reps"),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    WhitelistingTextInputFormatter.digitsOnly,
                                  ],
                                  enableSuggestions: true,
                                  controller: homeController.formControllerReps,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Reps can't be blank";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Expanded(
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
                                      borderSide: BorderSide(
                                          color: Colors.blueGrey, width: 1.0),
                                    ),
                                    labelText: "Weight",
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    WhitelistingTextInputFormatter.digitsOnly,
                                  ],
                                  enableSuggestions: true,
                                  controller:
                                      homeController.formControllerWeight,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Weight can't be blank";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Expanded(
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
                                      borderSide: BorderSide(
                                          color: Colors.blueGrey, width: 1.0),
                                    ),
                                    labelText: "Rest after",
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    WhitelistingTextInputFormatter.digitsOnly,
                                  ],
                                  autocorrect: true,
                                  enableSuggestions: true,
                                  controller:
                                      homeController.formControllerRestInterval,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Can't be blank";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    // this should be in a controller
                    SwitchListTile.adaptive(
                      value: doCast,
                      //TODO: or do we want to make them pick a cast device every time?
                      // that's what others do.... annoying to otherwise have to go to settings
                      // vs. annoying bcuz people probably only have 1 cast device.
                      onChanged: (newValue) async {
                        if (newValue && flingy.selectedPlayer == null) {
                          await showCastDevicePickerDialog();
                        } else {
                          setState(() {
                            doCast = newValue;
                          });
                        }
                      },
                      secondary: doCast
                          ? Icon(Icons.cast_connected)
                          : Icon(Icons.cast),
                      title: Text("Cast to TV"),
                    ),
                    SwitchListTile.adaptive(
                      title: Text("Record Video"),
                      secondary: doVideo
                          ? Icon(Icons.videocam)
                          : Icon(Icons.videocam_off),
                      value: doVideo,
                      onChanged: (newValue) {
                        setState(() {
                          doVideo = newValue;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.platform,
                    ),
                    //Consumer<ExerciseDay>(
                    //builder: (context, exerciseDay, child) {
                    // use model & provider to do this, doesn't work right now!
                    RaisedButton(
                      onPressed: homeController
                              .justDidLastSet //exerciseDay.areWeOnLastSet()
                          ? null
                          : () async {
                              if (_formkey.currentState.validate()) {
                                print("valid form");
                                // make any updates that are necessary, check we have a fling device, then cast

                                if (doCast && flingy.selectedPlayer == null) {
                                  await showCastDevicePickerDialog();
                                }

                                // if we made manual updates via the form, put them in!
                                homeController.updateThisExercise(
                                  thisSet: exercise,
                                );
                                // then get the next exercise's info into the form (not fully implemented of course)
                                //homeController.updateExercise(context);
                                // may need to await this, if it is updating our exercise that we're sending....
                                await homeController.castMediaTo(
                                    player: flingy.selectedPlayer,
                                    context: context,
                                    doCast: doCast,
                                    doVideo: doVideo,
                                    exercise: exercise);

                                // TODO: this is a consequence of not using a model. the controller progresses but nobody told the UI's data
                                // so we have to tell it too. that's pretty stupid, eh? do it right instead and you won't have to worry about it.
                                var exerciseDay = Provider.of<ExerciseDay>(
                                    context,
                                    listen: false);
                                exercise = exerciseDay
                                    .exercises[exerciseDay.currentSet];
                              }
                            },
                      child: ListTile(
                        leading: doCast
                            ? Icon(Icons.cast_connected)
                            : SizedBox(width: 5),
                        title: Text("Record and cast"),
                      ),
                      //);
                      //},
                    ),
                  ]),
                ),
              ],
            )
          ],
        )),
      );
    });
  }
}
