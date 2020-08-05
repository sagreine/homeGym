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

  // this needs to be a model.
  DocumentSnapshot pctAndReps;

  //TODO this doesn't bring in the other context / ExerciseSet values so look into that..
  Future<String> getVideo(bool isLocalTesting, BuildContext context) async {
    var exercise = Provider.of<ExerciseSet>(context, listen: false);
    var url;
    if (!isLocalTesting) {
      final picker = ImagePicker();
      final pickedFile = await picker.getVideo(source: ImageSource.camera);
      url = await uploadToCloudStorage(File(pickedFile.path));
      exercise.videoPath = url;
      createDatabaseRecord(exercise);
    } else {
      url = "https://i.imgur.com/ACgwkoh.mp4";
    }
    return url;
  }

  void updateExercise() {
    //exercise.videoPath = url;
    //print(json.encode(exercise.toJson()));
    //
  }

  void getExercises() async {
    // would update the exercise model here so pass in context...

    /*var percentAndReps = await Firestore.instance
        .collection('PROGRAMS')
        .where("id", isEqualTo: "bbbWeek1")
        .getDocuments();*/
    pctAndReps = await Firestore.instance
        .collection('PROGRAMS')
        .document("bbbWeek1")
        .get();
    sets = pctAndReps.data[0].length;
    print("pctAndReps = " + pctAndReps.toString());
    print("sets = " + sets.toString());
    //.snapshots()
    //.listen((data) => data.documents.forEach((doc) => print(doc["title"])));
    //sets = ''
  }

  void nextExercise() {}

  castMediaTo(RemoteMediaPlayer player, BuildContext context) async {
    var exercise = Provider.of<ExerciseSet>(context, listen: false);

    await FlutterFling.play(
      (state, condition, position) {
        //setState(() {
        /*
          _mediaState = '$state';
          _mediaCondition = '$condition';
          _mediaPosition = '$position';
          */

        // });
      },
      player: player,
      mediaUri: await getVideo(false, context),
      mediaTitle: json.encode(exercise.toJson()),
    );
    ////// can't get this to work? not sure what it does?
    //.then((_) => getSelectedDevice());
  }
}
