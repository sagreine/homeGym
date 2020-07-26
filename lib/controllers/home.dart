import 'dart:convert';
import 'dart:io';

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

  Future<String> getVideo(bool isLocalTesting) async {
    // placeholders for now.
    /*
  exercise.title = "sample_video23456";
  exercise.description = 'Scott benching, 12-2020';
  exercise.restPeriodAfter = 625;
  exercise.type = 'video/';
  */
    var url;

    if (!isLocalTesting) {
      final picker = ImagePicker();
      final pickedFile = await picker.getVideo(source: ImageSource.camera);
      url = await uploadToCloudStorage(File(pickedFile.path));
    } else {
      url = "https://i.imgur.com/ACgwkoh.mp4";
    }
    return url;
  }

  void updateExercise() {
    //exercise.videoPath = url;
    //print(json.encode(exercise.toJson()));
    //createDatabaseRecord(exercise);
  }

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
      mediaUri: await getVideo(true),
      mediaTitle: json.encode(exercise.toJson()),
    );
    ////// can't get this to work? not sure what it does?
    //.then((_) => getSelectedDevice());
  }
}
