import 'dart:convert';
import 'dart:io';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fling/flutter_fling.dart';
import 'package:flutter_fling/remote_media_player.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:get_ip/get_ip.dart';
import 'package:http_server/http_server.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
//http://10.0.0.76:8080/

//NetworkAssetBundle

class EncodingProvider {
  static final FlutterFFmpeg _encoder = FlutterFFmpeg();
  static final FlutterFFprobe _probe = FlutterFFprobe();
  static final FlutterFFmpegConfig _config = FlutterFFmpegConfig();

  static Future<Map<dynamic, dynamic>> getMediaInformation(String path) async {
    return await _probe.getMediaInformation(path);
  }

  static double getAspectRatio(Map<dynamic, dynamic> info) {
    final int width = info['streams'][0]['width'];
    final int height = info['streams'][0]['height'];
    final double aspect = height / width;
    return aspect;
  }

  static int getDuration(Map<dynamic, dynamic> info) {
    return info['duration'];
  }

  static Future<String> encodeHLS(videoPath, outDirPath) async {
    assert(File(videoPath).existsSync());

    final arguments = '-y -i $videoPath ' +
        '-preset ultrafast -g 48 -sc_threshold 0 ' +
        '-map 0:0 -map 0:1 -map 0:0 -map 0:1 ' +
        '-c:v:0 libx264 -b:v:0 2000k ' +
        '-c:v:1 libx264 -b:v:1 365k ' +
        '-c:a copy ' +
        '-var_stream_map "v:0,a:0 v:1,a:1" ' +
        '-master_pl_name master.m3u8 ' +
        '-f hls -hls_time 6 -hls_list_size 0 ' +
        '-hls_segment_filename "$outDirPath/%v_fileSequence_%d.ts" ' +
        '$outDirPath/%v_playlistVariant.m3u8';

    final int rc = await _encoder.execute(arguments);
    assert(rc == 0);

    return outDirPath;
  }
}

Future<String> _server() async {
  //final StreamController<String> onCode = new StreamController();
  //HttpServer server = await HttpServer.bind('10.0.0.148', 8080);
  HttpServer server = await HttpServer.bind('0.0.0.0', 8080);
  //HttpServer server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print("listening to ${server.address} on port: ${server.port}");
  server.listen((HttpRequest request) async {
    print("request received");
    //final String code = request.uri.queryParameters["code"];
    request.response
      ..statusCode = 200
      ..headers.set("Content-Type", ContentType.html.mimeType)
      ..write("<html><h1>You can now close this window</h1></html>");

    await request.response.close();
    await server.close(force: true);
    //onCode.add(code);
    //await onCode.close();
  });
  //return onCode.stream;
  return await GetIp.ipAddress;
}

WebViewController webViewController;
Future<void> loadHtmlFromAssets(
    String filename, WebViewController controller) async {
  String fileText = await rootBundle.loadString(filename);
  controller.loadUrl(Uri.dataFromString(fileText,
          mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
      .toString());
}

// this has a file that exists, and passes an http:// path to the fling device
// that is a local path e.g. 10.0.0.76:4040 that should then return the file
// as being served here. but that doesn't happen? the http link is passed directly to the fling device
// but we don't register anything on listen here... if you go to a browser it will play though.
// regular fling (cloud) is also broken, but this breaks first so it's not the URL i think
// look at comparing the logs as a next step / step through 1 by 1. might be a timing thing.
/*Future<String> _server2(String _targetFile) async {
  VirtualDirectory staticFiles = VirtualDirectory('.')
    ..followLinks = true
    ..allowDirectoryListing = true
    ..jailRoot = false;
  var serverRequests =
      //await HttpServer.bind(InternetAddress.loopbackIPv4, 4040);
      await HttpServer.bind('0.0.0.0', 4040);
  print(
      "listening to ${serverRequests.address} address and port: ${serverRequests.port}");
  serverRequests.listen((event) async {
    print(
        "request received to ${serverRequests.address} address and port: ${serverRequests.port}");
    print("1");
    print("2");
    print("3");
    print("14");
    print("5");
    print("6");
    print("7");
    print("8");
    print("9");
    print("10");
    print("11");
    print("12");
    print("13");
    print("14");
    print("15");
    File targetFile = File(_targetFile);
    //void abc(File rawVideoFile) async {
    final videoName = "abc";
    final Directory extDir = await getApplicationDocumentsDirectory();
    final outDirPath = '${extDir.path}/Videos/$videoName';

    ////////////////////////// use this, cuz you're not right now
    final videosDir = new Directory(outDirPath);

    final rawVideoPath = targetFile.path;
    final info = await EncodingProvider.getMediaInformation(rawVideoPath);
    //final aspectRatio = EncodingProvider.getAspectRatio(info);

    final encodedFilesDir =
        await EncodingProvider.encodeHLS(rawVideoPath, videosDir);

    targetFile = File(encodedFilesDir + 'master.m3u8');
    assert(await targetFile.exists());
    //File targetFile = File("public/index.html");
    //await loadHtmlFromAssets("public/index.html", webViewController);
    staticFiles.serveFile(targetFile, event);
    //staticFiles.serveRequest(event);
    //await event.response.close();
  });
  return "http://" +
      (await GetIp.ipAddress) +
      "/" +
      serverRequests.port.toString();
}*/

Future<String> _server21(String _targetFile) async {
  VirtualDirectory staticFiles = VirtualDirectory('.')
    ..followLinks = true
    ..allowDirectoryListing = true
    ..jailRoot = false;
  var serverRequests =
      //await HttpServer.bind(InternetAddress.loopbackIPv4, 4040);
      await HttpServer.bind('0.0.0.0', 4040);
  print(
      "listening to ${serverRequests.address} address and port: ${serverRequests.port}");
  serverRequests.listen((event) async {
    print(
        "request received to ${serverRequests.address} address and port: ${serverRequests.port}");
    print("1");
    print("2");
    print("3");
    print("14");
    print("5");
    print("6");
    print("7");
    print("8");
    print("9");
    print("10");
    print("11");
    print("12");
    print("13");
    print("14");
    print("15");
    File targetFile = File(_targetFile + 'master.m3u8');
    //void abc(File rawVideoFile) async {

    //targetFile = File(encodedFilesDir );
    assert(await targetFile.exists());
    //File targetFile = File("public/index.html");
    //await loadHtmlFromAssets("public/index.html", webViewController);
    staticFiles.serveFile(targetFile, event);
    //staticFiles.serveRequest(event);
    //await event.response.close();
  });
  return "http://" +
      (await GetIp.ipAddress) +
      "/" +
      serverRequests.port.toString();
}

// for this i can't seem to get a local html file to be served.
Future<String> _server3(String _targetFile) async {
  String toreturn;
  //await HttpServer.bind(InternetAddress.loopbackIPv4, 4040);
  HttpServer.bind('0.0.0.0', 4040).then((HttpServer server) {
    VirtualDirectory staticFiles = VirtualDirectory('.')
      ..followLinks = true
      ..allowDirectoryListing = true
      ..jailRoot = false;
    //staticFiles.serve(server);

    server.listen((event) async {
      print(
          "request received to ${server.address} address and port: ${server.port}");
      //File targetFile = File(_targetFile);
      File targetFile = File("public/index.html");
      assert(await targetFile.exists());
      //await loadHtmlFromAssets("public/index.html", webViewController);
      staticFiles.serveFile(targetFile, event);
      //staticFiles.serveRequest(event);

      //await event.response.close();
    });

    toreturn = server.port.toString();
  });
  return "http://" + (await GetIp.ipAddress) + "/" + toreturn;
}

//TODO: implement dispose
//TODO: this is all kind of just thrown in here for now. some is from startup that isn't created yet.
class HomeController {
  TextEditingController formControllerTitle = new TextEditingController();
  TextEditingController formControllerDescription = new TextEditingController();
  TextEditingController formControllerReps = new TextEditingController();
  TextEditingController formControllerRepsCorrection =
      new TextEditingController();
  TextEditingController formControllerWeight = new TextEditingController();
  TextEditingController formControllerRestInterval =
      new TextEditingController();

  ExerciseDayController exerciseDayController = new ExerciseDayController();
  LifterMaxesController lifterMaxesController = new LifterMaxesController();

  ConfettiController confettiController =
      ConfettiController(duration: const Duration(seconds: 1));

  bool justDidLastSet = false;

  Future<String> getVideo(bool recordNewVideo, BuildContext context) async {
    var url;
    if (recordNewVideo) {
      final picker = ImagePicker();
      final pickedFile = await picker.getVideo(source: ImageSource.camera);
      //return pickedFile.path;
      final videoName = "abc";
      final Directory extDir = await getTemporaryDirectory();
      final outDirPath = '${extDir.path}/Videos/$videoName';
      final videosDir = new Directory(outDirPath);

      final rawVideoPath = pickedFile.path;
      //final info = await EncodingProvider.getMediaInformation(rawVideoPath);
      //final aspectRatio = EncodingProvider.getAspectRatio(info);

      final encodedFilesDir =
          await EncodingProvider.encodeHLS(rawVideoPath, videosDir.path);
      return encodedFilesDir;

      if (pickedFile == null) {
        return null;
      }
      var user = Provider.of<Muser>(context, listen: false);
      // restrict to videos under a certain size for a given set - this is ~6 min video on my camera
      // but obviously we need to be careful here.
      print(File(File(pickedFile.path).resolveSymbolicLinksSync())
          .lengthSync()
          .toString());
      if (File(File(pickedFile.path).resolveSymbolicLinksSync()).lengthSync() <
          983977033) {
        url = await uploadToCloudStorage(
            userID: user.fAuthUser.uid, fileToUpload: File(pickedFile.path));
      } else {
        url = "https://i.imgur.com/ACgwkoh.mp4";
        print(
            "SAGREHOMEGYM: You elected to record a video, but it is too large");
      }
    } else {
      url =
          "https://firebasestorage.googleapis.com/v0/b/sagrehomegym.appspot.com/o/animation_1.mkv?alt=media&token=95062198-8a3a-4cba-8de4-6fcb8cb0bf22"; //https://i.imgur.com/ACgwkoh.mp4";
    }
    return url;
  }

  Future<bool> logout(BuildContext context) async {
    var result = await Provider.of<Muser>(context, listen: false).logout();
    return result;
  }

  // update our model with changes manually input on the form, if any.
  void updateThisExercise({@required ExerciseSet thisSet}) {
    //var thisSet = Provider.of<ExerciseSet>(context, listen: false);
    thisSet.updateExercise(
        title: formControllerTitle.text,
        description: formControllerDescription.text,
        reps: int.parse(formControllerReps.text),
        weight: int.parse(formControllerWeight.text),
        restPeriodAfter: int.parse(formControllerRestInterval.text));
  }

  // may eventually move to ExerciseDay is a collection of ExerciseSet objects...
  // but for now staying away from relational stuff.
  ExerciseSet getNextExercise({@required BuildContext context}) {
    ExerciseDayController exerciseDayController = new ExerciseDayController();
    ExerciseSet toReturn;
    // if this was the last set, set it so in the description
    if (exerciseDayController.areWeOnLastSet(context)) {
      toReturn = new ExerciseSet(
          title: "That was the last set",
          description: "No description",
          reps: 0,
          weight: 0,
          restPeriodAfter: 100);
      justDidLastSet = true;
    }
    //otherwise advance to the next set and display it
    else {
      toReturn = exerciseDayController.nextSet(context);
    }
    return toReturn;
  }

  void displayInExerciseInfo({ExerciseSet exercise}) {
    //var exercise = Provider.of<ExerciseSet>(context, listen: false);
    formControllerTitle.text = exercise.title;
    formControllerDescription.text = exercise.description;
    formControllerReps.text = exercise.reps.toString();
    formControllerWeight.text = exercise.weight.toString();
  }

// see about this ---> pass in the next exercise? concatenate JSON...

  // or just don't wait? once we send the video there's nothing
  // stoppping us from retrieving and updating the app right?
  castMediaTo({
    RemoteMediaPlayer player,
    BuildContext context,
    @required bool doCast,
    @required bool doVideo,
    @required ExerciseSet exercise,
  }) async {
    //var exercise = Provider.of<ExerciseSet>(context, listen: false);
    var thisDay = Provider.of<ExerciseDay>(context, listen: false);
    var user = Provider.of<Muser>(context, listen: false);

    // TODO: pull do video out of here? either way is kind of stupid...
    String url = await getVideo(doVideo, context);
    // if they hit the back button we need to stop in our tracks.
    if (url == null) {
      return;
    } else {
      exercise.videoPath = url;
    }
    url = await _server21(url);
    //print(ip);
    //String final_rul = ip + "/" + url.substring(url.lastIndexOf("/") + 1);

    // at this point we have a URL (possibly garbage though?) for the video, so update the cloud record with that information
    //....so could check for the garbage (default) URLs before updating this..
    // make the firestore record for this exercise. (dangerous, they can still back out of video.....)
    String origExerciseID = await createDatabaseRecord(
        exercise: exercise, userID: user.firebaseUser.uid);
    //updateDatabaseRecordWithURL(
    //dbDocID: origExerciseID, url: url, userID: user.firebaseUser.uid);

    //var thisMaxes = Provider.of<LifterMaxes>(context, listen: false);
    String thisExercise = json.encode(exercise.toJson());

    bool progressAfter = false;

    /////// dangerous, for sure. make a copy of the next exercise don't do this.
    ///e.g. below we try to reference values of the current exercise and it breaks everything.
    ///
    /// should flow like:
    /// 1) form has the current exercise (E1)
    /// 2) if casting, need to cast the next exercise (E2) too, so how to get it?
    /// 3) After the lift is performed, need to check reps for E1 and populate form with E2 info
    ///
    /// So, considerations
    /// 1) Business-side, I can live with the form being already-populated
    ///     a) not casting, no video -> doesn't care at all, just feels like you hit button when done
    ///     b) not casting, video -> video hides it aside from a brief splash, so weights already set up. back button on video though, which is a very reasonable thing....
    ///     c) casting, video -> same as above
    ///     d) casting, no video -> this is annoying, but the cast will have it correct
    /// 2) Implementation-side the 'issue' is safety within this function call
    ///    a) the ShowDialog needs to know which set this is, and it is looking at the next one already
    ///       which is problematic since we'd need to peek into member variables we shouldn't be able to see
    ///     ...could get around this one by storing it before updating..., but easy to forget that.
    ///    b) if they hit the back button during video, we've already advanced....
    ///    b) we keep the URL safe with careful ordering, but easy to forget that
    ///
    ///
    ExerciseSet nextSet = getNextExercise(context: context);
    String nextExercise = json.encode(nextSet.toJson());
    // below is needed for dispalying assistance on screen - remove if not doing anymore
    String thisDayJSON = json.encode(thisDay.toJson());

    // TODO: do we want to delay cast at all if not recording?
    // that is, give them time to do the actual exercise?
    // do we need to await? think rest period...
    if (doCast) {
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
        mediaUri: url, // url,
        mediaTitle: thisExercise +
            nextExercise +
            thisDayJSON, //json.encode(exercise.toJson()),
      );
    }
// move the UI components to....the UI
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AssetGiffyDialog(
              buttonCancelText: Text("Yes"),
              buttonOkText: Text("No"),
              buttonOkColor: Colors.grey[700],
              buttonCancelColor: Colors.green[500],
              image: Image.asset('assets/images/animation_1.gif'),
              title: Text(
                'Did you get ${exercise.reps} reps?',
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
              ),
              description: Text(
                'If no, hit no and enter how many you got',
                textAlign: TextAlign.center,
                style: TextStyle(),
              ),
              entryAnimation: EntryAnimation.DEFAULT,
              onOkButtonPressed: () => {
                Navigator.pop(context),
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => AlertDialog(
                            title: Text("Reps you got"),
                            content: TextFormField(
                              decoration: new InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.greenAccent,
                                      width: 1.0,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.blueGrey, width: 1.0),
                                  ),
                                  labelText: "Reps"),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly,
                              ],
                              enableSuggestions: true,
                              controller: formControllerRepsCorrection,
                              validator: (value) {
                                if (value.isEmpty) {
                                  formControllerRepsCorrection.text = "0";
                                  return "Reps cannot be empty";
                                }
                                //homeController.formController.validator()
                                return null;
                              },
                            ),
                            actions: [
                              IconButton(
                                icon: Icon(Icons.done),
                                onPressed: () => {
                                  Navigator.pop(context),
                                  // need to use controller here...

                                  updateDatabaseRecordWithReps(
                                      userID: user.firebaseUser.uid,
                                      dbDocID: origExerciseID,
                                      reps: int.parse(
                                          formControllerRepsCorrection.text)),
                                  // if we are updating because we got >= the target, say so
                                  if (int.parse(
                                          formControllerRepsCorrection.text) >=
                                      exercise.reps)
                                    {
                                      if (thisDay.updateMaxIfGetReps &&
                                          //thisDay.areWeOnLastSet()
                                          thisDay.currentSet ==
                                              thisDay.progressSet)
                                        {
                                          progressAfter = true,
                                        },

                                      // should only confetti if it is the last set of a week that tests/progresses?
                                      confettiController.play(),
                                    },
                                  // update the reps for this exercise? for the timeline i guess is the thought, but not sure
                                  // if that's what we'd want from the biz side or not really...
                                  // i say no actaully, just keep the target there (which do update).
                                },
                              ),
                            ]))
              },
              //on 'Yes i got the reps'
              onCancelButtonPressed: () => {
                Navigator.pop(context),
                if (thisDay.updateMaxIfGetReps &&
                    //thisDay.areWeOnLastSet()
                    thisDay.currentSet == thisDay.progressSet)
                  {
                    progressAfter = true,
                  },

                // should only confetti if it is the last set of a week that tests/progresses?
                confettiController.play()
              },
            ));
    displayInExerciseInfo(exercise: nextSet);
    // if we passed on the week that we were told to pass on, progress at the end.
    // TODO: this is also broken when the last set is the test set AND might update twice (second to last set and actual last set)
    if (progressAfter && exerciseDayController.areWeOnLastSet(context)) {
      lifterMaxesController.update1RepMax(
          context: context,
          // TODO: be careful with this, since we're updating/progressing to the next exercise above this point.
          lift: exercise.title,
          progression: true,
          updateCloud: true);
    }
  }
}
