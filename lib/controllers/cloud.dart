import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
