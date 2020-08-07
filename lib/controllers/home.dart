import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_fling/flutter_fling.dart';
import 'package:flutter_fling/remote_media_player.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class HomeController {
  TextEditingController formControllerTitle = new TextEditingController();
  TextEditingController formControllerDescription = new TextEditingController();
  TextEditingController formControllerReps = new TextEditingController();
  TextEditingController formControllerWeight = new TextEditingController();
  TextEditingController formControllerRestInterval =
      new TextEditingController();

  ExerciseDayController exerciseDayController = new ExerciseDayController();

  //TODO this doesn't bring in the other context / ExerciseSet values before uploading so look into that..
  Future<String> getVideo(bool isLocalTesting, BuildContext context) async {
    var exercise = Provider.of<ExerciseSet>(context, listen: false);
    var url;
    if (!isLocalTesting) {
      final picker = ImagePicker();
      // TODO: doesn't handle if they press back
      final pickedFile = await picker.getVideo(source: ImageSource.camera);
      url = await uploadToCloudStorage(File(pickedFile.path));
      exercise.videoPath = url;
      createDatabaseRecord(exercise);
    } else {
      url = "https://i.imgur.com/ACgwkoh.mp4";
    }
    return url;
  }

  // update our model.
  void updateThisExercise(context) {
    var thisSet = Provider.of<ExerciseSet>(context, listen: false);
    thisSet.updateExercise(
        title: formControllerTitle.text,
        description: formControllerDescription.text,
        reps: int.parse(formControllerReps.text),
        weight: int.parse(formControllerWeight.text),
        restPeriodAfter: int.parse(formControllerRestInterval.text));
  }

  // may eventually move to ExerciseDay is a collection of ExerciseSet objects...
  void updateExercise(context) {
    var exercise = Provider.of<ExerciseSet>(context, listen: false);
    var thisDay = Provider.of<ExerciseDay>(context, listen: false);
    exercise.updateExercise(
      // reps is a straight pull
      reps: thisDay.reps[thisDay.currentSet],
      // weight is percentage * trainingMax - for now just 100 lb.
      weight: ((thisDay.percentages[thisDay.currentSet]) * 100).toInt(),
    );
    //formControllerTitle
    //formControllerDescription
    formControllerReps.text = exercise.reps.toString();
    formControllerWeight.text = exercise.weight.toString();

    // then push to the next set
    //thisDay.nextSet();
    nextExercise(context);
  }

  void getExercises(BuildContext context) async {
    // would update the exercise model here so pass in context...
    // this needs to be a model.
    DocumentSnapshot pctAndReps;

    /*var percentAndReps = await Firestore.instance
        .collection('PROGRAMS')
        .where("id", isEqualTo: "bbbWeek1")
        .getDocuments();*/
    pctAndReps = await Firestore.instance
        .collection('PROGRAMS')
        .document("bbbWeek1")
        .get();
    List<int> reps = new List<int>.from(pctAndReps.data["reps"]);
    List<double> percentages =
        new List<double>.from(pctAndReps.data["percentages"]);
    //var exercise = Provider.of<ExerciseDay>(context, listen: false);
    exerciseDayController.updateDay(context, reps, percentages);

    //sets = pctAndReps.data[0].length;
    //print("pctAndReps = " + pctAndReps.toString());
    //print("sets = " + sets.toString());
    //.snapshots()
    //.listen((data) => data.documents.forEach((doc) => print(doc["title"])));
    //sets = ''
  }

  void nextExercise(BuildContext context) {
    exerciseDayController.nextSet(context);
  }

// see about this ---> pass in the next exercise? concatenate JSON...

  // or just don't wait? once we send the video there's nothing
  // stoppping us from retrieving and updating the app right?
  castMediaTo(RemoteMediaPlayer player, BuildContext context) async {
    var exercise = Provider.of<ExerciseSet>(context, listen: false);
    String thisExercise = json.encode(exercise.toJson());
    updateExercise(context);
    String nextExercise = json.encode(exercise.toJson());

    //String url = await getVideo(false, context);

    await FlutterFling.play(
      (state, condition, position) {
        //setState(() {
        /*
          _mediaState = '$state';
          _mediaCondition = '$condition';
          _mediaPosition = '$position';
          */

        // });
        print(state.toString());
        if (state.toString() == "MediaState.Finished") {
          print("context has finished");
          FlutterFling.stopPlayer();
        }
      },
      player: player,
      mediaUri: await getVideo(false, context), // url,
      mediaTitle: thisExercise + nextExercise, //json.encode(exercise.toJson()),
    ); //.then((_) => print("after the fact..."));

    //.then((_) => getSelectedDevice());
    ////// can't get this to work? not sure what it does?
    //
  }
}
