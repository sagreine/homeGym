import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/appbar.dart';
import 'package:provider/provider.dart';

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

Future<DocumentReference> saveProgramCloud(
    {@required PickedProgram program,
    @required String userID,
    @required bool anyProgramsToUpdate}) async {
  var db = FirebaseFirestore.instance;

  print("saving program to cloud!");
  DocumentReference docRef;
  docRef = db
      .collection("USERDATA")
      .doc(userID)
      .collection("CUSTOMPROGRAMS")
      .doc(program.id);

  // first update the program if necessary
  if (anyProgramsToUpdate) {
    await docRef.set(program.toJson());
  }

// then upsert each exerciseDay
  var batch = db.batch();

  for (int i = 0; i < program.exerciseDays.length; ++i) {
    for (int j = 0; j < program.exerciseDays[i].exercises.length; ++j) {
      if (program.exerciseDays[i].exercises[j].hasBeenUpdated) {
        var tag = docRef
            .collection("Weeks")
            .doc("Week" + i.toString())
            .collection("Lifts")
            .doc(program.exerciseDays[i].exercises[j].id);
        // we need to set this back to the ID. otherwise, if we just made the program this session,
        // all of the exercises will not have an ID. that is, if we edit it several times, they'll get added as new sets
        program.exerciseDays[i].exercises[j].id = tag.id;
        //.doc(i.toString())
        //.set(;
        batch.set(tag, program.exerciseDays[i].exercises[j].toJson());
      }
    }
  }
  await batch.commit();

  return docRef;
}

// instead of returning a naked list, we need to return the display name and # weeks for each program
//TODO this is extremely sloppy. stop just making random lists and pass and parse an object
Future<List<PickedProgram>> getPrograms({
  String userID,
}) async {
  List<PickedProgram> toReturn = List<PickedProgram>();
  //toReturn =
  toReturn.addAll(await _getDefaultPrograms());

  // this is untested, but the idea is to sort these then return
  //..addAll(iterable)
  if (userID != null) {
    toReturn.addAll(await _getCustomPrograms(userID: userID));
  }
  toReturn.sort((e, f) => e.type.compareTo(f.type));

  return toReturn;
}

Future<List<PickedProgram>> _getDefaultPrograms() async {
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
    pickedProgram.isMainLift = list[index].data()["isMainLift"];
    pickedProgram.trainingMaxPct = list[index].data()["trainingMaxPct"];
    pickedProgram.isCustom = false;

    //hasMainLifts = ... from cloud
    return pickedProgram;
  });
  return toReturn;
}

// TODO: not yet implemented.
Future<List<PickedProgram>> _getCustomPrograms({
  @required String userID,
}) async {
  List<PickedProgram> toReturn = List<PickedProgram>();
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("USERDATA")
      .doc(userID)
      .collection("CUSTOMPROGRAMS")
      .get();
  List<QueryDocumentSnapshot> list = new List.from(querySnapshot.docs.toList());
  toReturn = new List<PickedProgram>.generate(list.length, (index) {
    PickedProgram pickedProgram = PickedProgram();
    //pickedProgram.program = list[index].id;
    // we'll default to 1 if this value isn't set.
    pickedProgram.week = list[index].data()["week"] ?? 1;
    pickedProgram.program = list[index].data()["program"];
    pickedProgram.type = list[index].data()["type"];
    pickedProgram.isMainLift = list[index].data()["isMainLift"] ?? false;
    pickedProgram.trainingMaxPct = list[index].data()["trainingMaxPct"];
    pickedProgram.potentialProgressWeek =
        list[index].data()["potentialProgressWeek"];
    //pickedProgram.hasMainLifts = list[index].data()[
    pickedProgram.id = list[index].data()["id"] ?? list[index].id;
    pickedProgram.isAnewCopy = false;
    pickedProgram.neverTouched = false;
    pickedProgram.isCustom = true;
    return pickedProgram;
  });
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
    {@required context,
    @required String userId,
    @required String lift,
    @required bool isRep}) async {
  // get rep RPS
  QuerySnapshot prs = await FirebaseFirestore.instance
      .collection("USERDATA")
      .doc(userId)
      .collection("PRS")
      .doc(lift.toLowerCase())
      .collection(isRep ? "CURRENT_REP_PRS" : "CURRENT_WEIGHT_PRS")
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
Future<List<Pr>> getAllPRsCloud(
    {@required context,
    @required String userId,
    @required String lift,
    //@required String query,
    @required bool isRep}) async {
  QuerySnapshot prs = await FirebaseFirestore.instance
      .collection("USERDATA")
      .doc(userId)
      .collection("PRS")
      .doc(lift.toLowerCase())
      .collection(isRep ? "ALL_REP_PRS" : "ALL_WEIGHT_PRS")
      //.where(query)
      .get();
  List<QueryDocumentSnapshot> list = new List.from(prs.docs.toList());
  var toReturn = new List<Pr>.generate(list.length, (index) {
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

// would make this private to this library/class
Future<void> addToAllPRsCloud(
    {@required String lift,
    @required String userId,
    @required Map<String, dynamic> data,
    @required bool isRep}) async {
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
      .collection(isRep ? "ALL_REP_PRS" : "ALL_WEIGHT_PRS")
      .add(data);
}

// why aren't we setting the PR here?
Future<void> setPRCloud(
    {@required context,
    @required String userId,
    @required ExerciseSet lift,
    @required bool isRep}) async {
  final databaseReference = FirebaseFirestore.instance;
  //var exercise = Provider.of<ExerciseDay>(context, listen: false);
  Map data = Map<String, dynamic>();
  data["weight"] = lift.weight;
  data["reps"] = lift.reps;
  data["dateTime"] = lift.dateTime;
  // first, write this PR to the collection of all PRs
  await addToAllPRsCloud(
      data: data, userId: userId, lift: lift.title, isRep: isRep);
  // then, update the new rep PR
  await databaseReference
      .collection("USERDATA")
      .doc(userId)
      .collection("PRS")
      .doc(lift.title.toLowerCase())
      .collection("CURRENT_${isRep ? 'REP' : 'WEIGHT'}_PRS")
      .doc((isRep
              ? (lift.reps.toString() + "Rep")
              : (lift.weight.toString() + "Weight")) +
          "PR")
      .set(data);
}

/*
Future<void> setWeightPRCloud(
    {@required context,
    @required String userId,
    @required ExerciseSet lift,
    @required bool isRep}) async {
  final databaseReference = FirebaseFirestore.instance;
  //var exercise = Provider.of<ExerciseDay>(context, listen: false);
  Map data = Map<String, dynamic>();
  data["weight"] = lift.weight;
  data["dateTime"] = lift.dateTime;
  data["reps"] = lift.reps;
  // first, write this PR to the collection of all PRs
  await addToAllPRsCloud(
      data: data, userId: userId, lift: lift.title, isRep: isRep);
  // then, update the new rep PR
  await databaseReference
      .collection("USERDATA")
      .doc(userId)
      .collection("PRS")
      .doc(lift.title.toLowerCase())
      .collection("CURRENT_${isRep ? 'REP' : 'WEIGHT'}REP_PRS")
      .doc(lift.weight.toString() + "WeightPR")
      .set(data);
}
*/
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
  @required PickedProgram program,
  @required int week,
  @required bool isCustom,
  @required String userID,
  ExerciseDay exerciseDay,
}) async {
  if (isCustom) {
    assert(userID != null);
    await getExercisesCustomCloud(
        context: context,
        program: program,
        week: week,
        userID: userID,
        exerciseDay: exerciseDay);
  } else {
    await getExercisesDefaultCloud(
        context: context,
        program: program,
        week: week,
        exerciseDay: exerciseDay);
  }
}

Future<void> getExercisesCustomCloud(
    {@required context,
    @required PickedProgram program,
    @required int week,
    ExerciseDay exerciseDay,
    @required String userID}) async {
  ExerciseDayController exerciseDayController = ExerciseDayController();
  //DocumentSnapshot
  QuerySnapshot allSets;
  allSets = await FirebaseFirestore.instance
      .collection("USERDATA")
      .doc(userID)
      .collection("CUSTOMPROGRAMS")
      .doc(program.id)
      .collection("Weeks")
      .doc("Week${week - 1}")
      .collection("Lifts")
      .get();
  List<ExerciseSet> exerciseSets = List<ExerciseSet>();

  allSets.docs.forEach((lift) {
    var isMain = lift.data()["thisIsMainSet"] ?? false;
    var barbellPctIndex = lift.data()["whichLiftForPercentageofTMIndex"];
    var barbellIndex = lift.data()["whichBarbellIndex"];
    // for sets that are Main sets, check if their index was set to 0 (which, for Main sets, is 'Main')
    // if they were, set them to whatever lift we have selected for the day.
    // if it wasn't, we still need to account for 'Main' not being there by sliding up one
    if (isMain) {
      if (barbellPctIndex == -1) {
        barbellPctIndex = ReusableWidgets.lifts
            .indexOf(Provider.of<ExerciseDay>(context, listen: false).lift);
      }
      // thuis modification is needed here and on the other one if we populated against (4 lifts + Main) when we set this
      /*else if (barbellPctIndex != null) {
        barbellPctIndex--;
      }*/
      if (barbellIndex == -1) {
        barbellIndex = ReusableWidgets.lifts
            .indexOf(Provider.of<ExerciseDay>(context, listen: false).lift);
      }
      /*else if (barbellIndex != null) {
        barbellIndex--;
      }*/
    }

    exerciseSets.add(ExerciseSet.fromCustom(
      context: context,
      title: isMain
          ? Provider.of<ExerciseDay>(context, listen: false).lift ??
              lift.data()["title"]
          : lift.data()["title"],
      lift: Provider.of<ExerciseDay>(context, listen: false).lift,
      // this might be set or it might not be. limit by bool of it is should be, then set to 100 if not or missing...
      // if that bool is set, use it, else it is false
      percentageOfTM: ((lift.data()["basedOnPercentageOfTM"] ?? false)
              // if the bool is true, use the percentage, otherwise null
              ? lift.data()["percentageOfTM"]
              : null) ??
          // if it is null (not set because it isn't based on it, or it should've been but wasn't, use 100%)
          100.toDouble(),
      thisSetProgressSet: lift.data()["thisSetProgressSet"],
      thisSetPRSet: lift.data()["thisSetPRSet"],
      reps: lift.data()["reps"],
      weight: lift.data()["weight"],
      id: lift.id,
      thisIsMainSet: isMain,
      rpe: lift.data()["rpe"],
      thisIsRPESet: lift.data()["thisIsRPESet"],
      whichLiftForPercentageofTMIndex: barbellPctIndex,
      whichBarbellIndex: barbellIndex,
      indexForOrdering: lift.data()["indexForOrdering"],
      isMainLift: program.isMainLift,
      description: lift.data()["description"],
      basedOnPercentageOfTM: lift.data()["basedOnPercentageOfTM"],
      restPeriodAfter: lift.data()["restPeriodAfter"],
      basedOnBarbellWeight: lift.data()["basedOnBarbellWeight"],
    ));
  });
  exerciseDayController.buildCustomProgramDay(
    context: context,
    exerciseDay: exerciseDay,
    exerciseSets: exerciseSets,
  );
/*
  List<int> reps = new List<int>.from(pctAndReps.data()["Reps"]);
  // a value of 100%, stored as 1, gets inferred as a int so need to deal with that.
  var tmp = pctAndReps.data()["week" + week.toString() + "Percentages"];
  List<double> percentages = List<double>.from(tmp.map((i) => i.toDouble()));
  List<String> lifts = new List<String>.from(pctAndReps.data()["LIft"]);
  // TODO: this means we have to set this array for every single program in the db. but if we don't want to do that, make it conditional here.
  List<int> prSets = new List<int>.from(pctAndReps.data()["prSets"]);*/
  //var exercise = Provider.of<ExerciseDay>(context, listen: false);
}

Future<void> getExercisesDefaultCloud({
  @required context,
  @required PickedProgram program,
  ExerciseDay exerciseDay,
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
      .doc(program.program)
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
    program: program.program,
    context: context,
    exerciseDay: exerciseDay,
    reps: reps,
    prSets: prSets,
    prSetWeek: pctAndReps.data()["PRSetWeek"],
    percentages: percentages,
    progressSet: pctAndReps.data()["progressSet"],
  );
}
