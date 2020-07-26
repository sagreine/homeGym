import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:home_gym/models/models.dart';

void createDatabaseRecord(ExerciseSet exercise) async {
  /*await databaseReference.collection("VIDEOS").document("2").setData({
      'title': 'Mastering Flutter',
      'description': 'Programming Guide for Dart',
      'videoItself': pickedFile,
    });*/

  //untested
  final databaseReference = Firestore.instance;
  await databaseReference.collection("VIDEOS").add(
        Map<String, dynamic>.from((exercise.toJson())),

        //'title': 'Flutter in Action',
        //'description': 'Complete Programming Guide to learn Flutter'
      );
}

Future<String> uploadToCloudStorage(File fileToUpload) async {
  final StorageReference firebaseStorageRef =
      FirebaseStorage.instance.ref().child("sample_video");
  StorageUploadTask uploadTask = firebaseStorageRef.putFile(fileToUpload);
  StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
  var downloadUrl = await storageSnapshot.ref.getDownloadURL();
  if (uploadTask.isComplete) {
    var url = downloadUrl.toString();
    return url;
  }
  return null;
}
