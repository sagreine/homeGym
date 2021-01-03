//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/gestures.dart';
import 'dart:math';

//import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fling/flutter_fling.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:confetti/confetti.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

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

  CountDownController _countDownController = CountDownController();
  bool startController;

  // temporary. and should be in MODEL for this page so we can save state via provider.. controller.
  bool doVideo;
// temporary. and should be in controller.
  bool doCast;

  bool _noDayPickedOnEntry;
  bool hasVibration;
  bool hasCustomVibration;
  bool justRemovedPR = false; //afal;//'fff

  //Container banner;

  SnackBar _lastSetShareSnackBar() {
    return SnackBar(
      content: Text("Nice workout! Click to review and share your videos",
          style: TextStyle(color: Colors.purple[300])),
      action: SnackBarAction(
        label: 'Go!',
        onPressed: () {
          Navigator.pushNamed(context, "/lifter_videos");
        },
      ),
      elevation: 5,
      backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
    );
  }

  _vibin() async {
    hasVibration = await Vibration.hasVibrator();
    hasCustomVibration = await Vibration.hasCustomVibrationsSupport();
  }

  CircularCountDownTimer _countDownTimer({@required int seconds}) {
    var settings = Provider.of<Settings>(context, listen: false);
    return CircularCountDownTimer(
      // Countdown duration in Seconds
      duration: seconds,

      // Controller to control (i.e Pause, Resume, Restart) the Countdown
      controller: _countDownController,

      // Width of the Countdown Widget
      width: MediaQuery.of(context).size.width / 2,

      // Height of the Countdown Widget
      height: MediaQuery.of(context).size.height / 2,

      // Default Color for Countdown Timer
      color: Theme.of(context).textTheme.bodyText1.color,

      // Filling Color for Countdown Timer
      fillColor: Colors.blueGrey,

      // Background Color for Countdown Widget
      backgroundColor: null,

      // Border Thickness of the Countdown Circle
      strokeWidth: 10.0,

      // Begin and end contours with a flat edge and no extension
      strokeCap: StrokeCap.round,

      // Text Style for Countdown Text
      textStyle: TextStyle(
          fontSize: 22.0,
          color: Theme.of(context).textTheme.bodyText1.color,
          fontWeight: FontWeight.bold),

      // true for reverse countdown (max to 0), false for forward countdown (0 to max)
      isReverse: true,

      // true for reverse animation, false for forward animation
      isReverseAnimation: false,

      // Optional [bool] to hide the [Text] in this widget.
      isTimerTextShown: true,

      // Function which will execute when the Countdown Ends
      onComplete: () {
        // Here, do whatever you want
        //await _vibin();
        if (settings.timerVibrate) {
          if (hasVibration) {
            if (hasCustomVibration) {
              Vibration.vibrate(
                  pattern: [100, 100, 100, 100, 100, 100],
                  intensities: [1, 255]);
            } else {
              Vibration.vibrate();
            }
          }
        }

        print('Countdown Ended');
        startController = false;
      },
    );
    //_countDownController.restart();
  }

  SnackBar _progressSetShareSnackBar(
      {@required String lift, @required int reps}) {
    return SnackBar(
      content: Text("If you get $reps reps, your max $lift will go up!",
          style: TextStyle(color: Colors.purple[300])),
      elevation: 5,
      backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
    );
  }

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
                  "You didn't pick a program, so using a basic Squat day for now. Please pick a day and program."),
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

  /*bool _isLastExercise() {
    return homeController.justDidLastSet;
  }*/
///////
  @override
  void initState() {
    super.initState();

    fling = FlutterFling();
    doVideo = false;
    doCast = false;
    _noDayPickedOnEntry = false;
    startController = false;
    // this is bad, but whatever.
    homeController.formControllerRestInterval.text = "90";
    // this is stupid spaghetti code.

    _vibin();

    //Admob.requestTrackingAuthorization();

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
      //exerciseDay.lift = "Squat";
      PickDayController pickDayController = PickDayController();
      await pickDayController.getExercises(context, "Advanced Prep", 1);
      exerciseDay = Provider.of<ExerciseDay>(context, listen: false);
    }
    exercise = exerciseDay.exercises[exerciseDay.currentSet];
    homeController.displayInExerciseInfo(
        exercise: exercise, justRemovedPR: false);
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
                                  setState(() {
                                    doCast = true;
                                  });
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

  Future showNewUserFlingDialog() {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AlertDialog(
                title: Text("To cast"),
                content: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            "First, use your phone or computer to download the free companion TV app HomeGymTV available in the Amazon App Store. For FireStick: ",
                      ),
                      TextSpan(
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue),
                        text: "click this link.",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final url =
                                'https://www.amazon.com/dp/B08P9TKSPL/ref=mp_s_a_1_1?dchild=1&keywords=homegymtv&qid=1608494257&s=mobile-apps&sr=1-1 ';
                            if (await canLaunch(url)) {
                              await launch(
                                url,
                                forceSafariVC: false,
                              );
                            }
                          },
                      ),
                      TextSpan(
                        text: " for user manual with further instructions",
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.done),
                    onPressed: () => {
                      Navigator.pop(context),
                    },
                  ),
                ]));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool startBuildWithPR = false;
    if (homeController.formControllerReps.text.contains("PR")) {
      startBuildWithPR = true;
    }
    //Vibration.vibrate(pattern: [500, 1000, 500, 2000], intensities: [1, 255]);
    //var exerciseDay = Provider.of<ExerciseDay>(context, listen: false);
    //exercise = exerciseDay.exercises[exerciseDay.currentSet];
    //homeController.displayInExerciseInfo(exercise: exercise);
    return Consumer<FlingMediaModel>(builder: (context, flingy, child) {
      return SafeArea(
          child: Stack(children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: homeController.confettiController,
            blastDirection: pi / 2, // don't specify a direction, blast randomly
            shouldLoop: false,
            maxBlastForce: 3, // set a lower max blast force
            minBlastForce: 1, // set a lower min blast force
            emissionFrequency: 0.9,
            numberOfParticles: 10, // a lot of particles at once
            gravity: .7,
          ),
        ),
        Positioned.fill(
          child: ListView(
            children: <Widget>[
              Consumer<ExerciseDay>(builder: (context, exerciseDay, child) {
                // this is very stupid but necessary because we didn't do MVC right. protects us from building
                // if we haven't picked a day yet, while elsewhere we populate a default day.
                if (exerciseDay.lift == null) {
                  return Container();
                }

                // because we're not doing MVC correctly, we re-set the exercise on each build?
                // manually because the controllers are not part of the model but hold the text values that are displayed here.
                // sure i guess. almost 10000% certainly this is repeating work. multiple times on each build, and then re-building when-
                // -ever we build anything at all on the page is gigantically wasteful. just text i guess.. is what we'll tell ourselves.
                // but having this check up front prevents us from re-pulling the exercise info just because of changes we made on this page
                // we could do that, but it moves the cursor if you are rebuilding because you clicked into editing a form field, which is annoying
                // also it would be very wasteful.
                if (exercise != exerciseDay.exercises[exerciseDay.currentSet]) {
                  exercise = exerciseDay.exercises[exerciseDay.currentSet];
                  homeController.displayInExerciseInfo(
                      exercise: exercise, justRemovedPR: justRemovedPR); //. ;
                }
                return Column(
                  children: <Widget>[
                    // if they didn't pick a day on the way in, yell at them about it here.
                    _showBanner(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 300,
                          child: TextField(
                            readOnly: true,
                            style: TextStyle(fontSize: 30),
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
                    SizedBox(height: 10),
                    Column(children: [
                      Form(
                        autovalidate: true,
                        key: _formkey,
                        // would want Consumer of Exercise here, to leverage Provider, but doing via controller for now...
                        child: Column(
                          children: [
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
                                  borderSide: BorderSide(
                                      color: Colors.blueGrey, width: 1.0),
                                ),
                                labelText: "Description for this set",
                              ),
                              onChanged: (value) =>
                                  exercise.description = value,
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
                                              color: Colors.blueGrey,
                                              width: 1.0),
                                        ),
                                        labelText: "Reps"),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      WhitelistingTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: (value) {
                                      // if when we built this we had PR and now we don't, we don't want to add it back in.
                                      if (!value.contains("PR") &&
                                          startBuildWithPR) {
                                        justRemovedPR = true;
                                      }
                                      exercise.reps = int.parse(value);
                                    },
                                    enableSuggestions: true,
                                    controller:
                                        homeController.formControllerReps,
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
                                    onChanged: (value) =>
                                        exercise.weight = int.parse(value),
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
                                    onChanged: (value) => exercise
                                        .restPeriodAfter = int.parse(value),
                                    autocorrect: true,
                                    enableSuggestions: true,
                                    controller: homeController
                                        .formControllerRestInterval,
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
                      Consumer<Muser>(builder: (context, user, child) {
                        return SwitchListTile.adaptive(
                          value: doCast,
                          //TODO: or do we want to make them pick a cast device every time?
                          // that's what other apps do.... annoying to otherwise have to go to settings
                          // vs. annoying bcuz people probably only have 1 cast device.
                          onChanged: (newValue) async {
                            if (newValue && user.isNewUser) {
                              await showNewUserFlingDialog();
                            }
                            if (newValue) {
                              // if we don't have any fling devices, try to get one
                              bool showPicker = false;
                              if (flingy.flingDevices == null ||
                                  flingy.flingDevices.length == 0) {
                                await flingController.getCastDevices(context);
                                showPicker = true;
                              }
                              if (flingy.selectedPlayer == null || showPicker) {
                                await showCastDevicePickerDialog();
                              }
                            }
                            setState(() {
                              doCast = newValue;
                            });
                          },
                          secondary: doCast
                              ? Icon(Icons.cast_connected)
                              : Icon(Icons.cast),
                          title: Text("Cast to TV"),
                        );
                      }),
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
                      Consumer<ExerciseDay>(
                          builder: (context, exerciseDay, child) {
                        // use model & provider to do this, doesn't work right now!
                        return RaisedButton(
                          splashColor: Colors.blueGrey,
                          onPressed:
                              //_isLastExercise()
                              //homeController.justDidLastSet
                              exerciseDay.justDidLastSet
                                  ? null
                                  : () async {
                                      if (_formkey.currentState.validate()) {
                                        print("valid form");
                                        // make any updates that are necessary, check we have a fling device, then cast

                                        if (doCast &&
                                            (flingy.selectedPlayer == null ||
                                                flingy.flingDevices == null ||
                                                flingy.flingDevices.length ==
                                                    0)) {
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
                                        var exerciseDay =
                                            Provider.of<ExerciseDay>(context,
                                                listen: false);
                                        exercise = exerciseDay
                                            .exercises[exerciseDay.currentSet];
                                        if (exercise.thisSetProgressSet) {
                                          Scaffold.of(context).showSnackBar(
                                              _progressSetShareSnackBar(
                                                  lift: exercise.title,
                                                  reps: exercise.reps));
                                        }
                                        // TODO: ideally we'd want to have tracked if we've recorded any videos today and condition on that too
                                        if (exerciseDay.justDidLastSet) {
                                          Scaffold.of(context).showSnackBar(
                                              _lastSetShareSnackBar());
                                        }
                                        if (startController) {
                                          _countDownController.restart(
                                              duration: int.parse(homeController
                                                      .formControllerRestInterval
                                                      .text) ??
                                                  exercise.restPeriodAfter ??
                                                  60);
                                        }
                                        setState(() {
                                          startController = true;
                                        });
                                      }
                                    },
                          child: ListTile(
                            leading: doCast
                                ? Icon(Icons.cast_connected)
                                : SizedBox(width: 5),
                            title: Text("Record and cast"),
                            trailing: exercise.thisSetProgressSet
                                ? Icon(Icons.star)
                                : Container(
                                    height: 0,
                                    width: 0,
                                  ),
                          ),
                        );
                      }),
                      Visibility(
                          visible: startController,
                          child: Center(
                              heightFactor: .75,
                              child: _countDownTimer(
                                  seconds: int.parse(homeController
                                          .formControllerRestInterval.text) ??
                                      exercise.restPeriodAfter ??
                                      60))),
                    ]),
                  ],
                );
              }),
            ],
          ),
        ),
      ]));
    });
  }
}
