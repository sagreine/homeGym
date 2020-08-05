import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:home_gym/models/models.dart';
import 'package:video_compress/video_compress.dart';

//TODO: this should be a class?

void createDatabaseRecord(ExerciseSet exercise) async {
  // would put everyone in their own bucket and manage that via IAM
  final databaseReference = Firestore.instance;
  await databaseReference.collection("VIDEOS").add(
        Map<String, dynamic>.from((exercise.toJson())),
      );
}

//TODO: use title of video or something, not sample_video
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
