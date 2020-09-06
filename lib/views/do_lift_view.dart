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
  final ExerciseSet exercise;
  DoLiftView({
    Key key,
    @required this.exercise,
  });
  @override
  _DoLiftViewState createState() => _DoLiftViewState();
}

class _DoLiftViewState extends State<DoLiftView> {
  /*static const TextStyle timerTextStyle = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.bold,
  );*/
  // put this in the parent class and pass through, now that there is a parent class....
  // and/or etc. to have the state tracked.
  HomeController homeController = HomeController();

  final _formkey = GlobalKey<FormState>();

  // i don't know if we need these? shouldn't, ideally..
  FlutterFling fling;
  FlingController flingController = FlingController();

  // temporary. and should be in controller.
  bool doVideo;
// temporary. and should be in controller.
  bool doCast;

  @override
  void initState() {
    super.initState();
    homeController.displayInExerciseInfo(exercise: widget.exercise);
    fling = FlutterFling();
    doVideo = false;
    doCast = false;
    // this is bad, but whatever.
    homeController.formControllerRestInterval.text = "90";

    //confettiController
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() async {
    super.dispose();
    await FlutterFling.stopDiscoveryController();
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
                    content: Container(
                        width: double.maxFinite,
                        height: 60,
                        child: ListView.builder(
                          //shrinkWrap: true,
                          itemCount: flingy.flingDevices == null
                              ? 0
                              : flingy.flingDevices.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(Icons.tv),
                              title: Text(
                                  flingy.flingDevices.elementAt(index).name),
                              onTap: () {
                                flingController.selectPlayer(context,
                                    flingy.flingDevices.elementAt(index));
                                doCast = true;
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        )),
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
            Column(children: <Widget>[
              Text("Do the lift!"),
              Expanded(
                child: Form(
                  autovalidate: true,
                  key: _formkey,
                  // would want Consumer of Exercise here, to leverage Provider, but doing via controller for now...
                  child: ListView(
                    children: <Widget>[
                      Text(widget.exercise.title),
                      SizedBox(height: 16),
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
                            borderSide:
                                BorderSide(color: Colors.blueGrey, width: 1.0),
                          ),
                          labelText: "Description for this set",
                        ),
                        autocorrect: true,
                        enableSuggestions: true,
                        controller: homeController.formControllerDescription,
                        validator: (value) {
                          //homeController.formController.validator()
                          if (value.isEmpty) {
                            return "Title can't be blank";
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
                                //homeController.formController.validator()
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
                              controller: homeController.formControllerWeight,
                              validator: (value) {
                                //homeController.formController.validator()
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
              ),
              // this should be in a controller
              CheckboxListTile(
                title: Text("Cast to TV"),
                secondary:
                    doCast ? Icon(Icons.cast_connected) : Icon(Icons.cast),
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
              ),
              CheckboxListTile(
                title: Text("Record Video"),
                secondary:
                    doVideo ? Icon(Icons.videocam) : Icon(Icons.videocam_off),
                value: doVideo,
                onChanged: (newValue) {
                  setState(() {
                    doVideo = newValue;
                  });
                },
                controlAffinity: ListTileControlAffinity.platform,
              ),
              // could make thid disabled when not valid, but headache to setState everywhere
              RaisedButton(
                  onPressed: () async {
                    if (_formkey.currentState.validate()) {
                      print("valid form");
                      // make any updates that are necessary, check we have a fling device, then cast

                      if (doCast && flingy.selectedPlayer == null) {
                        await showCastDevicePickerDialog();
                      }

                      // if we made manual updates via the form, put them in!
                      homeController.updateThisExercise(
                        thisSet: widget.exercise,
                      );
                      // then get the next exercise's info into the form (not fully implemented of course)
                      //homeController.updateExercise(context);
                      // may need to await this, if it is updating our exercise that we're sending....
                      await homeController.castMediaTo(
                          player: flingy.selectedPlayer,
                          context: context,
                          doCast: doCast,
                          doVideo: doVideo,
                          exercise: widget.exercise);
                    }
                  },
                  // TODO: cast v cast selected = do we have a cast device selected...
                  child: ListTile(
                    leading: doCast
                        ? Icon(Icons.cast_connected)
                        : SizedBox(width: 5),
                    title: Text("Record and cast"),
                  )),
            ]),
          ],
        )),
      );
    });
  }
}
