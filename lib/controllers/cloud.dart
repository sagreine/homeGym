import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:video_compress/video_compress.dart';

//TODO: this should be a class?
//TODO: implement dispose

Future<String> createDatabaseRecord(
    {@required ExerciseSet exercise, @required String userID}) async {
  // would put everyone in their own bucket and manage that via IAM
  final databaseReference = FirebaseFirestore.instance;
  DocumentReference documentReference = await databaseReference
      .collection("USERDATA")
      .doc(userID)
      .collection("LIFTS")
      .add(
        Map<String, dynamic>.from((exercise.toJson())),
      );
  return documentReference.id;
}

updateDatabaseRecordWithURL(
    {@required String dbDocID, @required String url, @required String userID}) {
  var db = FirebaseFirestore.instance;
  db
      .collection("USERDATA")
      .doc(userID)
      .collection("LIFTS")
      .doc(dbDocID)
      .update({"videoPath": url});
}

updateDatabaseRecordWithReps(
    {@required String dbDocID, @required int reps, @required String userID}) {
  var db = FirebaseFirestore.instance;
  db
      .collection("USERDATA")
      .doc(userID)
      .collection("LIFTS")
      .doc(dbDocID)
      .update({"reps": reps});
}

Future<List<String>> getPrograms() async {
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('PROGRAMS').get();
  List<QueryDocumentSnapshot> list = new List.from(querySnapshot.docs.toList());
  List<String> rtr = list.map((QueryDocumentSnapshot docSnapshot) {
    return docSnapshot.id.toString();
    // this is a first step towards how to get a step further for if/when we're not (stupidly) using the ID and want e.g. a display name.
    //return docSnapshot.data().entries.toString();
  }).toList();
  return rtr;
}

//TODO untested
void updateBarWeightCloud(
    {@required int newWeight, @required String userID}) async {
  final databaseReference = FirebaseFirestore.instance;
  Map data = Map<String, dynamic>();
  data["weight"] = newWeight;

  await databaseReference
      .collection("USERDATA")
      .doc(userID)
      .collection("AVAILABLE_WEIGHTS")
      .doc("bar")
      .set(data);
}

//TODO untested
void updatePlateCloud(
    {@required double plate,
    @required int plateCount,
    @required String userID}) async {
  final databaseReference = FirebaseFirestore.instance;
  Map data = Map<String, dynamic>();
  data["count"] = plateCount;
  await databaseReference
      .collection("USERDATA")
      .doc(userID)
      .collection("AVAILABLE_WEIGHTS")
      .doc(plate.toString() + "_POUNDS")
      .set(data);
}

//TODO: implement, test
void update1RepMaxCloud(
    {@required String lift,
    @required int newMax,
    @required String userID}) async {
  final databaseReference = FirebaseFirestore.instance;
  Map data = Map<String, dynamic>();
  data["currentMax"] = newMax;
  await databaseReference
      .collection("USERDATA")
      .doc(userID)
      .collection("MAXES")
      .doc(lift.toLowerCase())
      .set(data);
}

Future<String> uploadToCloudStorage(File fileToUpload) async {
  print("File size: " + fileToUpload.lengthSync().toString());
  MediaInfo mediaInfo = await VideoCompress.compressVideo(
    fileToUpload.path,
    quality: VideoQuality.MediumQuality,
    deleteOrigin: false, // It's false by default
  );
  print(
      "Compressed File size: " + File(mediaInfo.path).lengthSync().toString());

  final StorageReference firebaseStorageRef = FirebaseStorage.instance
      .ref()
      .child(UniqueKey().toString() +
          UniqueKey().toString() +
          UniqueKey().toString());
  StorageUploadTask uploadTask =
      firebaseStorageRef.putFile(File(mediaInfo.path));

  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  var downloadUrl = await storageSnapshot.ref.getDownloadURL();
  if (uploadTask.isComplete) {
    var url = downloadUrl.toString();
    return url;
  }
  return null;
}

Future<int> getBarWeightCloud({@required String userID}) async {
  DocumentSnapshot barWeight = await FirebaseFirestore.instance
      .collection("USERDATA")
      .doc(userID)
      .collection('AVAILABLE_WEIGHTS')
      .doc("bar")
      .get()
      .catchError((onError) {
    print("Could not retrieve users' bar weight. Returning 45 by default");
    return 45;
  });
  if (barWeight.exists) {
    return barWeight.data()["weight"];
  } else {
    print("Could not retrieve users' bar weight. Returning 45 by default");
    return 45;
  }
}

// should make this lazier
// not liking having the controller in here? would rather return a
// list to the page that then uses the controller or something.. also because if we delete that controller this function fails which is ... bad.
// TODO: if this returns nothing, we need to handle that.
void getMaxesCloud({@required context, @required String userID}) async {
  LifterMaxesController liftMaxController = new LifterMaxesController();
  QuerySnapshot maxes;
  maxes = await FirebaseFirestore.instance
      .collection("USERDATA")
      .doc(userID)
      .collection('MAXES')
      .get()
      .catchError((onError) {
    print(
        "Could not retrieve user's Max for lifts. ask them to generate them?");
    return;
  });
  if (maxes.docs.length != 4) {
    print("There werent' 4 values in Maxes, there were ${maxes.docs.length}. This might mean we just forgot to update how many to expect" +
        " (each is individually checked, so it shouldn't be broken) or it means one of these is using a default value)");
  }
  liftMaxController.update1RepMax(
      progression: false,
      context: context,
      lift: "bench",
      // if this vqalue doesn't exist, use a default value
      newMax: (maxes.docs.singleWhere((element) => element.id == "bench",
                  orElse: () => null)) !=
              null
          ? maxes.docs
              .elementAt(
                  maxes.docs.indexWhere((document) => document.id == "bench"))
              .data()["currentMax"]
          : 100);
  liftMaxController.update1RepMax(
      progression: false,
      context: context,
      lift: "deadlift",
      newMax: (maxes.docs.singleWhere((element) => element.id == "deadlift",
                  orElse: () => null)) !=
              null
          ? maxes.docs
              .elementAt(maxes.docs
                  .indexWhere((document) => document.id == "deadlift"))
              .data()["currentMax"]
          : 150);
  liftMaxController.update1RepMax(
      progression: false,
      context: context,
      lift: "squat",
      newMax: (maxes.docs.singleWhere((element) => element.id == "squat",
                  orElse: () => null)) !=
              null
          ? maxes.docs
              .elementAt(
                  maxes.docs.indexWhere((document) => document.id == "squat"))
              .data()["currentMax"]
          : 135);
  liftMaxController.update1RepMax(
      progression: false,
      context: context,
      lift: "press",
      newMax: (maxes.docs.singleWhere((element) => element.id == "press",
                  orElse: () => null)) !=
              null
          ? maxes.docs
              .elementAt(
                  maxes.docs.indexWhere((document) => document.id == "press"))
              .data()["currentMax"]
          : 90);
}

void getPlatesCloud({@required context, @required String userID}) async {
  LifterWeightsController lifterWeightsController =
      new LifterWeightsController();
  QuerySnapshot plates;
  plates = await FirebaseFirestore.instance
      .collection("USERDATA")
      .doc(userID)
      .collection("AVAILABLE_WEIGHTS")
      .get();

  plates.docs.forEach((result) {
    if (result.id != "bar") {
      print("Plate pulled: ${result.id}" +
          "Count of plates: ${result.data()["count"]}");
      lifterWeightsController.updatePlate(
          context: context,
          plate: double.parse(result.id.substring(0, result.id.indexOf("_"))),
          plateCount: result.data()["count"]);
    }
  });
}

// this is very stupid to do this here. separate layers, return stuff to the non-cloud place to do this.
// like this defeats the whole purpose of having this layer almost.
Future<void> getExercisesCloud({
  @required context,
  @required String program,
}) async {
  ExerciseDayController exerciseDayController = ExerciseDayController();
  // would update the exercise model here so pass in context...
  // this needs to be a model.
  DocumentSnapshot pctAndReps;

  /*var percentAndReps = await Firestore.instance
        .collection('PROGRAMS')
        .where("id", isEqualTo: "bbbWeek1")
        .getDocuments();*/
  // pull these from a .xml file
  pctAndReps = await FirebaseFirestore.instance
      .collection('PROGRAMS')
      .doc(program)
      .get();
  List<int> reps = new List<int>.from(pctAndReps.data()["reps"]);
  List<double> percentages =
      new List<double>.from(pctAndReps.data()["percentages"]);
  //var exercise = Provider.of<ExerciseDay>(context, listen: false);
  await exerciseDayController.updateDay(
    updateMaxIfGetReps: pctAndReps.data()["update_max_if_get_reps"],
    program: program,
    context: context,
    reps: reps,
    percentages: percentages,
    progressSet: pctAndReps.data()["progressSet"],
    trainingMaxPct: pctAndReps.data()["trainingMaxPct"],
    assistanceCore: new List<String>.from(pctAndReps.data()["assistance_core"]),
    assistanceCoreReps: pctAndReps.data()["assistance_core_reps"],
    assistancePull: new List<String>.from(pctAndReps.data()["assistance_pull"]),
    assistancePullReps: pctAndReps.data()["assistance_pull_reps"],
    assistancePush: new List<String>.from(pctAndReps.data()["assistance_push"]),
    assistancePushReps: pctAndReps.data()["assistance_push_reps"],
  );
}
