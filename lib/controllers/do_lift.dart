import 'dart:convert';
import 'dart:io';

import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fling/flutter_fling.dart';
import 'package:flutter_fling/remote_media_player.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

//TODO: implement dispose
//TODO: this is all kind of just thrown in here for now. some is from startup that isn't created yet.
class HomeController {
  TextEditingController formControllerTitle = new TextEditingController();
  TextEditingController formControllerDescription = new TextEditingController();
  TextEditingController formControllerReps = new TextEditingController();
  TextEditingController formControllerRepsCorrection =
      new TextEditingController();
  TextEditingController formControllerWeight = new TextEditingController();
  TextEditingController formControllerRestInterval =
      new TextEditingController();

  ExerciseDayController exerciseDayController = new ExerciseDayController();
  LifterMaxesController lifterMaxesController = new LifterMaxesController();

  ConfettiController confettiController =
      ConfettiController(duration: const Duration(seconds: 1));

  Future<String> getVideo(bool recordNewVideo, BuildContext context) async {
    var url;
    if (recordNewVideo) {
      final picker = ImagePicker();
      // TODO: doesn't handle if they press back
      final pickedFile = await picker.getVideo(source: ImageSource.camera);

      // restrict to videos under a certain size for a given set - this is ~6 min video on my camera
      // but obviously we need to be careful here.
      print(File(File(pickedFile.path).resolveSymbolicLinksSync())
          .lengthSync()
          .toString());
      if (File(File(pickedFile.path).resolveSymbolicLinksSync()).lengthSync() <
          983977033) {
        url = await uploadToCloudStorage(File(pickedFile.path));
      } else {
        url = "https://i.imgur.com/ACgwkoh.mp4";
        print(
            "SAGREHOMEGYM: You elected to record a video, but it is too large");
      }
    } else {
      url =
          "https://firebasestorage.googleapis.com/v0/b/sagrehomegym.appspot.com/o/animation_1.mkv?alt=media&token=95062198-8a3a-4cba-8de4-6fcb8cb0bf22"; //https://i.imgur.com/ACgwkoh.mp4";
    }
    return url;
  }

  Future<bool> logout(BuildContext context) async {
    var result = await Provider.of<Muser>(context, listen: false).logout();
    return result;
  }

  // update our model with changes manually input on the form, if any.
  void updateThisExercise(BuildContext context) {
    var thisSet = Provider.of<ExerciseSet>(context, listen: false);
    thisSet.updateExercise(
        title: formControllerTitle.text,
        description: formControllerDescription.text,
        reps: int.parse(formControllerReps.text),
        weight: int.parse(formControllerWeight.text),
        restPeriodAfter: int.parse(formControllerRestInterval.text));
  }

  // may eventually move to ExerciseDay is a collection of ExerciseSet objects...
  // but for now staying away from relational stuff.
  void updateExercise({BuildContext context}) {
    ExerciseController exerciseController = ExerciseController();
    exerciseController.updateExercise(context: context);
    displayInExerciseInfo(context: context);
  }

  void displayInExerciseInfo({BuildContext context}) {
    var exercise = Provider.of<ExerciseSet>(context, listen: false);
    formControllerTitle.text = exercise.title;
    formControllerDescription.text = exercise.description;
    formControllerReps.text = exercise.reps.toString();
    formControllerWeight.text = exercise.weight.toString();
  }

// see about this ---> pass in the next exercise? concatenate JSON...

  // or just don't wait? once we send the video there's nothing
  // stoppping us from retrieving and updating the app right?
  castMediaTo(
      {RemoteMediaPlayer player,
      BuildContext context,
      @required bool doCast,
      @required bool doVideo}) async {
    var exercise = Provider.of<ExerciseSet>(context, listen: false);
    var thisDay = Provider.of<ExerciseDay>(context, listen: false);
    var user = Provider.of<Muser>(context, listen: false);
    //var thisMaxes = Provider.of<LifterMaxes>(context, listen: false);
    String thisExercise = json.encode(exercise.toJson());
    // make the firestore record for this exercise. (dangerous, they can still back out of video.....)
    String origExerciseID = await createDatabaseRecord(
        exercise: exercise, userID: user.firebaseUser.uid);

    bool progressAfter = false;

    /////// dangerous, for sure. make a copy of the next exercise don't do this.
    ///e.g. below we try to reference values of the current exercise and it breaks everything.
    ///
    /// should flow like:
    /// 1) form has the current exercise (E1)
    /// 2) if casting, need to cast the next exercise (E2) too, so how to get it?
    /// 3) After the lift is performed, need to check reps for E1 and populate form with E2 info
    ///
    /// So, considerations
    /// 1) Business-side, I can live with the form being already-populated
    ///     a) not casting, no video -> doesn't care at all, just feels like you hit button when done
    ///     b) not casting, video -> video hides it aside from a brief splash, so weights already set up. back button on video though, which is a very reasonable thing....
    ///     c) casting, video -> same as above
    ///     d) casting, no video -> this is annoying, but the cast will have it correct
    /// 2) Implementation-side the 'issue' is safety within this function call
    ///    a) the ShowDialog needs to know which set this is, and it is looking at the next one already
    ///       which is problematic since we'd need to peek into member variables we shouldn't be able to see
    ///     ...could get around this one by storing it before updating..., but easy to forget that.
    ///    b) if they hit the back button during video, we've already advanced....
    ///    b) we keep the URL safe with careful ordering, but easy to forget that
    ///
    ///
    updateExercise(context: context);
    String nextExercise = json.encode(exercise.toJson());
    String thisDayJSON = json.encode(thisDay.toJson());

    // TODO: pull do video out of here? either way is kind of stupid...
    String url = await getVideo(doVideo, context);

    // at this point we have a URL (possibly garbage though?) for the video, so update the cloud record with that information
    //....so could check for the garbage (default) URLs before updating this..
    updateDatabaseRecordWithURL(
        dbDocID: origExerciseID, url: url, userID: user.firebaseUser.uid);

    // TODO: do we want to delay cast at all if not recording?
    // that is, give them time to do the actual exercise?
    // do we need to await? think rest period...
    if (doCast) {
      await FlutterFling.play(
        (state, condition, position) {
          // not sure we need this
          print(state.toString());
          if (state.toString() == "MediaState.Finished") {
            print("context has finished");
            FlutterFling.stopPlayer();
          }
        },
        player: player,
        mediaUri: url, // url,
        mediaTitle: thisExercise +
            nextExercise +
            thisDayJSON, //json.encode(exercise.toJson()),
      );
    }
// move the UI components to....the UI
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AssetGiffyDialog(
              buttonCancelText: Text("Yes"),
              buttonOkText: Text("No"),
              buttonOkColor: Colors.grey[700],
              buttonCancelColor: Colors.green[500],
              image: Image.asset('assets/images/animation_1.gif'),
              title: Text(
                'Did you get the reps?',
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
              ),
              description: Text(
                'If no, hit no and enter how many you got',
                textAlign: TextAlign.center,
                style: TextStyle(),
              ),
              entryAnimation: EntryAnimation.DEFAULT,
              onOkButtonPressed: () => {
                Navigator.pop(context),
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => AlertDialog(
                            title: Text("Reps you got"),
                            content: TextFormField(
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
                              controller: formControllerRepsCorrection,
                              validator: (value) {
                                if (value.isEmpty) {
                                  formControllerRepsCorrection.text = "0";
                                  return "Reps cannot be empty";
                                }
                                //homeController.formController.validator()
                                return null;
                              },
                            ),
                            actions: [
                              IconButton(
                                icon: Icon(Icons.done),
                                onPressed: () => {
                                  Navigator.pop(context),
                                  updateDatabaseRecordWithReps(
                                      userID: user.firebaseUser.uid,
                                      dbDocID: origExerciseID,
                                      reps: int.parse(
                                          formControllerRepsCorrection.text)),
                                },
                              ),
                            ]))
              },
              onCancelButtonPressed: () => {
                Navigator.pop(context),
                if (thisDay.updateMaxIfGetReps &&
                    //thisDay.areWeOnLastSet()
                    thisDay.currentSet == thisDay.progressSet)
                  {
                    progressAfter = true,
                  },

                // should only confetti if it is the last set of a week that tests/progresses?
                confettiController.play()
              },
            ));

    // if we passed on the week that we were told to pass on, progress at the end.
    // TODO: this is also broken when the last set is the test set AND might update twice (second to last set and actual last set)
    if (progressAfter && thisDay.currentSet + 1 == thisDay.sets) {
      lifterMaxesController.update1RepMax(
          context: context,
          // TODO: be careful with this, since we're updating/progressing to the next exercise above this point.
          lift: exercise.title,
          progression: true,
          updateCloud: true);
    }
  }
}
