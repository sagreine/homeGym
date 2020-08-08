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

//TODO: implement dispose
// shouldn't really be raw querying in here...
class HomeController {
  TextEditingController formControllerTitle = new TextEditingController();
  TextEditingController formControllerDescription = new TextEditingController();
  TextEditingController formControllerReps = new TextEditingController();
  TextEditingController formControllerWeight = new TextEditingController();
  TextEditingController formControllerRestInterval =
      new TextEditingController();

  ExerciseDayController exerciseDayController = new ExerciseDayController();
  LiftMaxController liftMaxController = new LiftMaxController();

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
  // but for now staying away from relational stuff.
  void updateExercise(context) {
    var exercise = Provider.of<ExerciseSet>(context, listen: false);
    var thisDay = Provider.of<ExerciseDay>(context, listen: false);
    var thisMax = Provider.of<LiftMaxes>(context, listen: false);
    int trainingMax = 100;
    switch (exercise.title) {
      case "deadlift":
        trainingMax =
            (thisMax.deadliftMax.toDouble() * thisDay.trainingMax).toInt();
        break;
      case "bench":
        trainingMax =
            (thisMax.benchMax.toDouble() * thisDay.trainingMax).toInt();
        break;
      case "press":
        trainingMax =
            (thisMax.pressMax.toDouble() * thisDay.trainingMax).toInt();
        break;
      case "squat":
        trainingMax =
            (thisMax.squatMax.toDouble() * thisDay.trainingMax).toInt();
        break;
    }

    exercise.updateExercise(
      // reps is a straight pull
      reps: thisDay.reps[thisDay.currentSet],
      // weight is percentage * trainingMax - for now just 100 lb.
      weight: ((thisDay.percentages[thisDay.currentSet]) * trainingMax).toInt(),
    );
    //formControllerTitle
    //formControllerDescription
    formControllerReps.text = exercise.reps.toString();
    formControllerWeight.text = exercise.weight.toString();

    // then push to the next set
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
    // pull these from a .xml file
    pctAndReps = await Firestore.instance
        .collection('PROGRAMS')
        .document("bbbWeek1")
        .get();
    List<int> reps = new List<int>.from(pctAndReps.data["reps"]);
    List<double> percentages =
        new List<double>.from(pctAndReps.data["percentages"]);

    //var exercise = Provider.of<ExerciseDay>(context, listen: false);
    exerciseDayController.updateDay(
        context, reps, percentages, pctAndReps.data["trainingMaxPct"]);
    getMaxes(context);
  }

  // should make this lazier
  void getMaxes(BuildContext context) async {
    QuerySnapshot maxes;
    maxes = await Firestore.instance.collection('MAXES').getDocuments();

    liftMaxController.updateMax(
        context: context,
        lift: "bench",
        newMax: maxes.documents
            .elementAt(maxes.documents
                .indexWhere((document) => document.documentID == "bench"))
            .data["currentMax"]);
    liftMaxController.updateMax(
        context: context,
        lift: "deadlift",
        newMax: maxes.documents
            .elementAt(maxes.documents
                .indexWhere((document) => document.documentID == "deadlift"))
            .data["currentMax"]);
    liftMaxController.updateMax(
        context: context,
        lift: "squat",
        newMax: maxes.documents
            .elementAt(maxes.documents
                .indexWhere((document) => document.documentID == "squat"))
            .data["currentMax"]);
    liftMaxController.updateMax(
        context: context,
        lift: "press",
        newMax: maxes.documents
            .elementAt(maxes.documents
                .indexWhere((document) => document.documentID == "press"))
            .data["currentMax"]);
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
        print(state.toString());
        if (state.toString() == "MediaState.Finished") {
          print("context has finished");
          FlutterFling.stopPlayer();
        }
      },
      player: player,
      mediaUri: await getVideo(false, context), // url,
      mediaTitle: thisExercise + nextExercise, //json.encode(exercise.toJson()),
    );
  }
}
