import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';

//
//TODO: implement dispose

//TODO make this actually a classs
//TODO we should absolutely not be passing context in to this.

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

// instead of returning a naked list, we need to return the display name and # weeks for each program
//TODO this is extremely sloppy. stop just making random lists and pass and parse an object
Future<List<PickedProgram>> getPrograms() async {
  List<PickedProgram> toReturn = List<PickedProgram>();

  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('PROGRAMS').get();
  List<QueryDocumentSnapshot> list = new List.from(querySnapshot.docs.toList());
  toReturn = new List<PickedProgram>.generate(list.length, (index) {
    PickedProgram pickedProgram = PickedProgram();
    pickedProgram.program = list[index].id;
    // we'll default to 1 if this value isn't set.
    pickedProgram.week = list[index].data()["numWeeks"] ?? 1;
    pickedProgram.type = list[index].data()["type"];
    return pickedProgram;
  })
    ..sort((e, f) => e.type.compareTo(f.type));

  return toReturn;
}

void updateBarWeightCloud(
    {@required int newWeight,
    @required String userID,
    @required String lift}) async {
  final databaseReference = FirebaseFirestore.instance;
  Map data = Map<String, dynamic>();
  data["weight"] = newWeight;

  await databaseReference
      .collection("USERDATA")
      .doc(userID)
      .collection("AVAILABLE_WEIGHTS")
      .doc("$lift" + "Bar")
      .set(data);
}

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

void updateBumpersCloud(
    {@required bool bumpers, @required String userID}) async {
  final databaseReference = FirebaseFirestore.instance;
  Map data = Map<String, dynamic>();
  data["bumpers"] = bumpers;
  await databaseReference
      .collection("USERDATA")
      .doc(userID)
      .collection("AVAILABLE_WEIGHTS")
      .doc("bumpers")
      .set(data);
}

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

Future<String> uploadToCloudStorage(
    {@required String userID,
    @required File fileToUpload,
    @required bool isVideo}) async {
  /*print("File size: " + fileToUpload.lengthSync().toString());
  MediaInfo mediaInfo = await VideoCompress.compressVideo(
    fileToUpload.path,
    quality: VideoQuality.MediumQuality,
    deleteOrigin: false, // It's false by default
  );
  print(
      "Compressed File size: " + File(mediaInfo.path).lengthSync().toString());
*/
  //print("userID is: $userID");
  final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(
      "user/$userID/${UniqueKey().toString()}${UniqueKey().toString()}${UniqueKey().toString()}_${isVideo ? "video" : "thumbnail"}");
  //.child("user/" + userID + "/" + UniqueKey().toString() + UniqueKey().toString() +UniqueKey().toString());
  StorageUploadTask uploadTask = firebaseStorageRef.putFile(fileToUpload);

  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  var downloadUrl = await storageSnapshot.ref.getDownloadURL();
  if (uploadTask.isComplete) {
    var url = downloadUrl.toString();
    return url;
  }
  return null;
}

Future<int> getBarWeightCloud(
    {@required String userID, @required String lift}) async {
  String docname = lift + "Bar";
  DocumentSnapshot barWeight = await FirebaseFirestore.instance
      .collection("USERDATA")
      .doc(userID)
      .collection('AVAILABLE_WEIGHTS')
      .doc(docname)
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
void getMaxesCloud(
    {@required context, @required String userID, bool dontNotify}) async {
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
      dontNotify: dontNotify,
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
      dontNotify: dontNotify,
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
      dontNotify: dontNotify,
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
      dontNotify: dontNotify,
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

Future<List<Pr>> getCurrentPRsCloud(
    {@required context, @required String userId, @required String lift}) async {
  QuerySnapshot prs = await FirebaseFirestore.instance
      .collection("USERDATA")
      .doc(userId)
      .collection("PRS")
      .doc(lift.toLowerCase())
      .collection("CURRENT_PRS")
      //.orderBy("weight", descending: true)
      //.limit(1)
      .get();
  List<QueryDocumentSnapshot> list = new List.from(prs.docs.toList());
  var toReturn;

  toReturn = new List<Pr>.generate(list.length, (index) {
    Pr _pr = Pr();
    _pr.reps = list[index].data()["reps"] ??
        0; //int.parse(list[index].id.substring(1, 2));
    // we'll default to 0 if this value isn't set.
    _pr.weight = list[index].data()["weight"] ?? 0;
    // becaus we dont need to store this in firestore but need it (for convenience) later
    // or i guess we could just have lift-specific PRs...
    _pr.lift = lift;
    _pr.dateTime = list[index].data()["dateTime"]?.toDate() ?? DateTime.now();
    return _pr;
  })
    ..sort((e, f) => e.reps.compareTo(f.reps));
  return toReturn;
}

// TODO: untested. obvviously not the right way to do this either, but fix it later.
Future<QuerySnapshot> getWhereQueriedAllPRsCloud(
    {@required context,
    @required String userId,
    @required String lift,
    @required String query}) async {
  QuerySnapshot prs = await FirebaseFirestore.instance
      .collection("USERDATA")
      .doc(userId)
      .collection("PRS")
      .doc(lift.toLowerCase())
      .collection("ALL_PRS")
      .where(query)
      .get();
  return prs;
}

// would make this private to this library/class
Future<void> addToAllPRsCloud(
    {@required String lift,
    @required String userId,
    @required Map<String, dynamic> data}) async {
  final databaseReference = FirebaseFirestore.instance;
  /*
  data["weight"] = lift.weight;
  data["reps"] = lift.dateTime;
  data["dateTime"] = lift.dateTime;
  */
  await databaseReference
      .collection("USERDATA")
      .doc(userId)
      .collection("PRS")
      .doc(lift.toLowerCase())
      .collection("ALL_PRS")
      .add(data);
}

Future<void> setRepPRCloud(
    {@required context,
    @required String userId,
    @required ExerciseSet lift}) async {
  final databaseReference = FirebaseFirestore.instance;
  //var exercise = Provider.of<ExerciseDay>(context, listen: false);
  Map data = Map<String, dynamic>();
  data["weight"] = lift.weight;
  data["reps"] = lift.reps;
  data["dateTime"] = lift.dateTime;
  // first, write this PR to the collection of all PRs
  await addToAllPRsCloud(data: data, userId: userId, lift: lift.title);
  // then, update the new rep PR
  await databaseReference
      .collection("USERDATA")
      .doc(userId)
      .collection("PRS")
      .doc(lift.title.toLowerCase())
      .collection("CURRENT_PRS")
      .doc(lift.reps.toString() + "RepPR")
      .set(data);
}

Future<void> setWeightPRCloud(
    {@required context,
    @required String userId,
    @required ExerciseSet lift}) async {
  final databaseReference = FirebaseFirestore.instance;
  //var exercise = Provider.of<ExerciseDay>(context, listen: false);
  Map data = Map<String, dynamic>();
  data["weight"] = lift.weight;
  data["dateTime"] = lift.dateTime;
  data["reps"] = lift.reps;
  // first, write this PR to the collection of all PRs
  await addToAllPRsCloud(data: data, userId: userId, lift: lift.title);
  // then, update the new rep PR
  await databaseReference
      .collection("USERDATA")
      .doc(userId)
      .collection("PRS")
      .doc(lift.title.toLowerCase())
      .collection("CURRENT_PRS")
      .doc(lift.weight.toString() + "WeightPR")
      .set(data);
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
    if (!result.id.contains("Bar") && result.id != "bumpers") {
      print("Plate pulled: ${result.id}" +
          "Count of plates: ${result.data()["count"]}");
      lifterWeightsController.updatePlate(
          context: context,
          plate: double.parse(result.id.substring(0, result.id.indexOf("_"))),
          plateCount: result.data()["count"]);
    }
    if (result.id == "bumpers") {
      print("person owns bumpers: ${result.data()["bumpers"]}");
      lifterWeightsController.updateBumpers(
          context: context, bumpers: result.data()["bumpers"]);
    }
  });
}

// this is very stupid to do this here. separate layers, return stuff to the non-cloud place to do this.
// like this defeats the whole purpose of having this layer almost.
Future<void> getExercisesCloud({
  @required context,
  @required String program,
  @required int week,
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
  List<int> reps = new List<int>.from(pctAndReps.data()["Reps"]);
  // a value of 100%, stored as 1, gets inferred as a int so need to deal with that.
  var tmp = pctAndReps.data()["week" + week.toString() + "Percentages"];
  List<double> percentages = List<double>.from(tmp.map((i) => i.toDouble()));
  List<String> lifts = new List<String>.from(pctAndReps.data()["LIft"]);
  // TODO: this means we have to set this array for every single program in the db. but if we don't want to do that, make it conditional here.
  List<int> prSets = new List<int>.from(pctAndReps.data()["prSets"]);
  //var exercise = Provider.of<ExerciseDay>(context, listen: false);
  await exerciseDayController.updateDay(
    updateMaxIfGetReps: pctAndReps.data()["update_max_if_get_reps"],
    lifts: lifts,
    program: program,
    context: context,
    reps: reps,
    prSets: prSets,
    prSetWeek: pctAndReps.data()["PRSetWeek"],
    percentages: percentages,
    progressSet: pctAndReps.data()["progressSet"],
    trainingMaxPct: pctAndReps.data()["trainingMaxPct"],
    /*
    assistanceCore: new List<String>.from(pctAndReps.data()["assistance_core"]),
    assistanceCoreReps:
        new List<int>.from(pctAndReps.data()["assistance_core_reps"]),
    assistancePull: new List<String>.from(pctAndReps.data()["assistance_pull"]),
    assistancePullReps:
        new List<int>.from(pctAndReps.data()["assistance_pull_reps"]),
    assistancePush: new List<String>.from(pctAndReps.data()["assistance_push"]),
    assistancePushReps:
        new List<int>.from(pctAndReps.data()["assistance_push_reps"]),*/
  );
}
