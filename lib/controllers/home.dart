import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_fling/flutter_fling.dart';
import 'package:flutter_fling/remote_media_player.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';

//TODO: implement dispose
// shouldn't really be raw querying in here...
//TODO: this is all kind of just thrown in here for now. some is from startup that isn't created yet.
class HomeController {
  TextEditingController formControllerTitle = new TextEditingController();
  TextEditingController formControllerDescription = new TextEditingController();
  TextEditingController formControllerReps = new TextEditingController();
  TextEditingController formControllerWeight = new TextEditingController();
  TextEditingController formControllerRestInterval =
      new TextEditingController();

  ExerciseDayController exerciseDayController = new ExerciseDayController();
  LiftMaxController liftMaxController = new LiftMaxController();
  LifterWeightsController lifterWeightsController =
      new LifterWeightsController();

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
    var thisWeights = Provider.of<LifterWeights>(context, listen: false);
    int trainingMax = 100;
    switch (exercise.title.toLowerCase()) {
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
    double targetWeight =
        ((thisDay.percentages[thisDay.currentSet]) * trainingMax);

    exercise.updateExercise(
      // reps is a straight pull
      reps: thisDay.reps[thisDay.currentSet],
      // weight is percentage * trainingMax - for now just 100 lb.
      weight: targetWeight.toInt(),
      description: "Weight each side: " +
          thisWeights.pickPlates(targetWeight: targetWeight)[0].toString(),
    );
    //formControllerTitle
    formControllerDescription.text = exercise.description;
    formControllerReps.text = exercise.reps.toString();
    formControllerWeight.text = exercise.weight.toString();

    // then push to the next set
    // this is a hack for now.
    if (!nextExercise(context)) {
      formControllerDescription.text += "- Last set!";
    }
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
      context: context,
      reps: reps,
      percentages: percentages,
      trainingMaxPct: pctAndReps.data["trainingMaxPct"],
      assistanceCore: new List<String>.from(pctAndReps.data["assistance_core"]),
      assistanceCoreReps: pctAndReps.data["assistance_core_reps"],
      assistancePull: new List<String>.from(pctAndReps.data["assistance_pull"]),
      assistancePullReps: pctAndReps.data["assistance_pull_reps"],
      assistancePush: new List<String>.from(pctAndReps.data["assistance_push"]),
      assistancePushReps: pctAndReps.data["assistance_push_reps"],
    );
    getMaxes(context);
    getBarWeight(context);
    getPlates(context);
  }

  void getBarWeight(BuildContext context) async {
    DocumentSnapshot barWeight;
    barWeight = await Firestore.instance
        .collection('AVAILABLE_WEIGHTS')
        .document("bar")
        .get();
    var liftweights = Provider.of<LifterWeights>(context, listen: false);
    liftweights.barWeight = barWeight.data["weight"];
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

  // very stupid. rearrange db organization instead of doing this.
  void getPlates(BuildContext context) async {
    QuerySnapshot plates;

    //await Firestore.instance.collection('AVAILABLE_WEIGHTS').getDocuments();
    plates =
        await Firestore.instance.collection("AVAILABLE_WEIGHTS").getDocuments();

    plates.documents.forEach((result) {
      if (result.documentID != "bar") {
        print(result.data["count"]);
        lifterWeightsController.updatePlate(
            context,
            double.parse(
                result.documentID.substring(0, result.documentID.indexOf("_"))),
            result.data["count"]);
      }
    });

    //var liftweights = Provider.of<LifterWeights>(context, listen: false);
  }

  bool nextExercise(BuildContext context) {
    return exerciseDayController.nextSet(context);
  }

  void showWarmup() {
    //castMediaTo
    Map<String, String> jsonToSend;
    jsonToSend["title"] = "Warmups!";
    ExerciseSet ex = new ExerciseSet(
      type: "video/",
      title: "",
      description: "",
      reps: 5,
      weight: 5,
      videoPath: "",
      restPeriodAfter: 5,
    );
  }

// see about this ---> pass in the next exercise? concatenate JSON...

  // or just don't wait? once we send the video there's nothing
  // stoppping us from retrieving and updating the app right?
  castMediaTo(
      {RemoteMediaPlayer player,
      BuildContext context,
      Map<String, dynamic> jsonHardcode}) async {
    String jsonToSend;
    if (context != null && jsonHardcode == null) {
      var exercise = Provider.of<ExerciseSet>(context, listen: false);
      var thisDay = Provider.of<ExerciseDay>(context, listen: false);
      String thisExercise = json.encode(exercise.toJson());
      updateExercise(context);
      String nextExercise = json.encode(exercise.toJson());
      String thisDayJSON = json.encode(thisDay.toJson());
      jsonToSend = thisExercise + nextExercise + thisDayJSON;
    } else if (context == null && jsonHardcode != null) {
      jsonToSend = json.encode(jsonHardcode.toString());
    } else {
      print("this should never happen");
    }

    //String url = await getVideo(false, context);
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
      mediaUri: await getVideo(false, context), // url,
      mediaTitle: jsonToSend, //json.encode(exercise.toJson()),
    );
  }
}
