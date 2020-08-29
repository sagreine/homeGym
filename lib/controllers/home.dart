import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_fling/flutter_fling.dart';
import 'package:flutter_fling/remote_media_player.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

//TODO: implement dispose
//TODO: put raw querying in cloud layer...
//TODO: this is all kind of just thrown in here for now. some is from startup that isn't created yet.
class HomeController {
  TextEditingController formControllerTitle = new TextEditingController();
  TextEditingController formControllerDescription = new TextEditingController();
  TextEditingController formControllerReps = new TextEditingController();
  TextEditingController formControllerWeight = new TextEditingController();
  TextEditingController formControllerRestInterval =
      new TextEditingController();

  ExerciseDayController exerciseDayController = new ExerciseDayController();

  Future<String> getVideo(bool recordNewVideo, BuildContext context) async {
    var exercise = Provider.of<ExerciseSet>(context, listen: false);
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
        exercise.videoPath = url;
        createDatabaseRecord(exercise);
      } else {
        print(
            "SAGREHOMEGYM: You elected to record a video, but it is too large");
      }
    } else {
      url = "https://i.imgur.com/ACgwkoh.mp4";
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
    String thisExercise = json.encode(exercise.toJson());
    updateExercise(context: context);
    String nextExercise = json.encode(exercise.toJson());
    String thisDayJSON = json.encode(thisDay.toJson());

    // TODO: do we want to delay at all if not recording?
    // that is, give them time to do the actual exercise?
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
        mediaUri: await getVideo(doVideo, context), // url,
        mediaTitle: thisExercise +
            nextExercise +
            thisDayJSON, //json.encode(exercise.toJson()),
      );
    }
  }
}
