import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:video_compress/video_compress.dart';

//TODO: this should be a class?
//TODO: implement dispose

void createDatabaseRecord(ExerciseSet exercise) async {
  // would put everyone in their own bucket and manage that via IAM
  final databaseReference = Firestore.instance;
  await databaseReference.collection("VIDEOS").add(
        Map<String, dynamic>.from((exercise.toJson())),
      );
}

Future getPrograms() async {
  //List<String> programs = new List<String>();
/*
  await Firestore.instance.collection('PROGRAMS').getDocuments().then((value) {
    value.documents.forEach((element) {
      programs.add(element.documentID);
    });
    return programs;
  });
*/
  QuerySnapshot abc =
      await Firestore.instance.collection('PROGRAMS').getDocuments();
  return abc;
}

void updateBarWeightCloud(double newWeight) async {
  final databaseReference = Firestore.instance;
  Map data = Map<String, dynamic>();
  data["weight"] = newWeight;

  await databaseReference
      .collection("AVAILABLE_WEIGHTS")
      .document("bar")
      .setData(data);
}

void updatePlateCloud(double _plate, int _plateCount) async {
  final databaseReference = Firestore.instance;
  Map data = Map<String, dynamic>();
  data["count"] = _plateCount;
  await databaseReference
      .collection("AVAILABLE_WEIGHTS")
      .document(_plate.toString() + "_POUNDS")
      .setData(data);
}

void updateTrainingMaxCloud(String lift, double newMax) async {}
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

Future<double> getBarWeightCloud() async {
  DocumentSnapshot barWeight = await Firestore.instance
      .collection('AVAILABLE_WEIGHTS')
      .document("bar")
      .get();
  return barWeight.data["weight"];
}

// should make this lazier
// not liking having the controller in here. would rather return a
// list to the page that then uses the controller or something..
void getMaxesCloud(context) async {
  LiftMaxController liftMaxController = new LiftMaxController();
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

void getPlatesCloud(context) async {
  LifterWeightsController lifterWeightsController =
      new LifterWeightsController();
  QuerySnapshot plates;
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
}
