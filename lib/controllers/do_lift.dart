import 'dart:convert';
import 'dart:io';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fling/flutter_fling.dart';
import 'package:flutter_fling/remote_media_player.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get_ip/get_ip.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:http_server/http_server.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';

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
  PrsController prsController = new PrsController();

  ConfettiController confettiController =
      ConfettiController(duration: const Duration(seconds: 1));

  //var thumbnail;
  File targetFile;
  bool justDidLastSet = false;

  dispose() {
    // delete the targetfile when we're done.
    if (targetFile != null) {
      targetFile.delete();
    }
  }

  Future<void> serverListen(context) async {
    // we only listen once.
    var _serverRequest = Provider.of<FlingMediaModel>(context, listen: false);
    if (_serverRequest.isListening) {
      return;
    }
    _serverRequest.isListening = true;
    VirtualDirectory staticFiles = VirtualDirectory('.')
      ..followLinks = true
      ..allowDirectoryListing = true
      ..jailRoot = false;
    //serverRequests.drain();

    //int abc = _serverRequest.httpServer.connectionsInfo().total;
    _serverRequest.httpServer.listen((event) async {
      print(
          "request received to ${_serverRequest.httpServer.address} address and port: ${_serverRequest.httpServer.port}");
      //File targetFile2 = File(targetFile);
      assert(await targetFile.exists());
      staticFiles.serveFile(targetFile, event);
    });
  }

  Future<PickedFile> getVideo(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 300),
    );
    if (pickedFile == null) {
      return null;
    }
    return pickedFile;
  }

  Future<String> compressVideo(
      BuildContext context, PickedFile pickedFile) async {
    // my internet and/or device is way to slow for this
    // which is unfortunate because it casts almosts immediately.
    //return pickedFile.path;
    MediaInfo mediaInfo = await VideoCompress.compressVideo(
      pickedFile.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: true, // It's false by default
      includeAudio: false,

      frameRate: 24,
    );
    return mediaInfo.path;
  }

  Future<String> uploadVideoToCloud(
      BuildContext context, String filePath) async {
    var url;
    var user = Provider.of<Muser>(context, listen: false);
    // restrict to videos under a certain size for a given set - this is ~6 min video on my camera
    // but obviously we need to be careful here.
    /*print(File(File(filePath).resolveSymbolicLinksSync())
        .lengthSync()
        .toString());*/
    if (File(File(filePath).resolveSymbolicLinksSync()).lengthSync() <
        983977033) {
      //cloudUrl =
      url = uploadToCloudStorage(
        userID: user.fAuthUser.uid,
        fileToUpload: File(filePath),
        isVideo: true,
      );
    } else {
      //cloudUrl = "https://i.imgur.com/ACgwkoh.mp4";
      GallerySaver.saveVideo(filePath);
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              "This video is too big for us to store in the cloud right now :(. Storing it locally on your phone")));
      print("SAGREHOMEGYM: You elected to record a video, but it is too large");
    }
    return url;
  }

  Future<String> uploadThumbnailToCloud(
      BuildContext context, String filePath) async {
    var user = Provider.of<Muser>(context, listen: false);
    var thumbnail = await VideoCompress.getFileThumbnail(
        filePath); //VideoCompress.getMediaInfo(path).
    return uploadToCloudStorage(
      userID: user.fAuthUser.uid,
      fileToUpload: thumbnail,
      isVideo: false,
    );
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
        // keep only the digits parts of the reps
        reps: int.parse(
            formControllerReps.text.replaceAll(new RegExp(r'[^0-9]'), '')),
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
      //exerciseDayController.justDidLastSet(context);
    }
    //otherwise advance to the next set and display it
    else {
      toReturn = exerciseDayController.nextSet(context);
    }
    return toReturn;
  }

  void displayInExerciseInfo(
      {ExerciseSet exercise, @required bool justRemovedPR}) {
    //var exercise = Provider.of<ExerciseSet>(context, listen: false);
    formControllerTitle.text = exercise.title;
    formControllerDescription.text = exercise.description;

    formControllerReps.text = exercise.reps.toString();
    if (exercise.thisSetPRSet && !justRemovedPR) {
      formControllerReps.text += "xPR";
    }
    formControllerWeight.text = exercise.weight.toString();
  }

  // why is this here and why aren't we try catching it or at least handling errors..
  Future cast(
      {@required BuildContext context,
      @required RemoteMediaPlayer player,
      @required String url,
      @required String mediaTitle}) async {
    await serverListen(context);
    await FlutterFling.stopPlayer();
    // TODO: check if the player is connected first
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
      mediaUri: url,
      mediaTitle: mediaTitle,
    );
  }

  // or just don't wait? once we send the video there's nothing
  // stoppping us from retrieving and updating the app right?
  Future<bool> castMediaTo({
    RemoteMediaPlayer player,
    BuildContext context,
    @required bool doCast,
    @required bool doVideo,
    @required ExerciseSet exercise,
  }) async {
    //var exercise = Provider.of<ExerciseSet>(context, listen: false);
    var thisDay = Provider.of<ExerciseDay>(context, listen: false);
    var flingy = Provider.of<FlingMediaModel>(context, listen: false);
    var user = Provider.of<Muser>(context, listen: false);
    var settings = Provider.of<Settings>(context, listen: false);

    String url =
        "https://firebasestorage.googleapis.com/v0/b/sagrehomegym.appspot.com/o/animation_1.mkv?alt=media&token=95062198-8a3a-4cba-8de4-6fcb8cb0bf22";

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
    bool firstExercise = thisDay.currentSet == 0;
    var pickedFile;
    // if we didn't record the video and said we were going to, like by pressing back, back all the way out
    if (doVideo) {
      // 1a) get video
      pickedFile = await getVideo(context);
      // if we didn't record the video and said we were going to, like by pressing back, back all the way out
      if (pickedFile == null) {
        return false;
      }
    }
    ExerciseSet nextSet = getNextExercise(context: context);
    String nextExercise = json.encode(nextSet.toJson());
    // will tell the TV if we need to start a timer on fling
    bool startTimerCast = true;

    // if we're doing the video, do these steps (since casting the recorded video directly doesn't work)
    // 1a) get the video
    // 1c) ask if they got the reps, correct it if not.
    // 2a) start a timer while we compress, so we can cast the 'correct' timer start value
    // 2b) cast a placeholder while we wait, so the next lift instructions get there right away
    // 2c) TBD, but ask them about reps at this point?
    // 3) compress the video
    // 4) cast the compressed video
    // 5) reset to the original rest period value
    // 6) if they want us to, save to local and or cloud
    if (doVideo) {
      // 1a) get video
      /*var pickedFile = await getVideo(context);
      
      if (pickedFile == null) {
        return false;
      }*/
      // 1c)
      showDialog(
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
                                    // update this exercise's reps to reps
                                    exercise.reps = int.parse(
                                        formControllerRepsCorrection.text),
                                    // if we are updating because we got >= the target, say so
                                    if (int.parse(formControllerRepsCorrection
                                            .text) >=
                                        exercise.prescribedReps)
                                      {
                                        if (thisDay.updateMaxIfGetReps &&
                                            //thisDay.areWeOnLastSet()
                                            exercise.thisSetProgressSet)
                                          {
                                            progressAfter = true,
                                            Scaffold.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(Quotes().getQuote(
                                                  greatnessQuote: true)),
                                            )),
                                          },

                                        // should only confetti if it is the last set of a week that tests/progresses?
                                        confettiController.play(),
                                      }
                                    // only holler about failure if it is set up that way.
                                    else if (settings.meanQuotes)
                                      {
                                        Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(Quotes()
                                              .getQuote(greatnessQuote: false)),
                                        ))
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
                      exercise.thisSetProgressSet)
                    {
                      progressAfter = true,
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(Quotes().getQuote(greatnessQuote: true)),
                      )),
                    },

                  // should only confetti if it is the last set of a week that tests/progresses?
                  confettiController.play()
                },
              ));

      // 2b cast placeholder - ONLY send firstExercise exactly once, so only sending it here.
      if (doCast) {
        cast(
          url: url,
          player: player,
          mediaTitle: thisExercise +
              nextExercise +
              '{"startTimerCast":' +
              startTimerCast.toString() +
              "}"
                  '{"firstExercise":' +
              firstExercise.toString() +
              "}",
          context: context,
        );
      }
      // 3 compress video
      var targetFilePath = await compressVideo(context, pickedFile);
      // 4 cast the compressed video
      if (doCast) {
        // if we've already casted, delete the old file :)
        if (targetFile != null) {
          targetFile.delete();
        }
        // this is the file we'll serve to anyone who visits the URL
        targetFile = File(targetFilePath);
        // we pass this URL to the cast device, it visits it and gets the target file
        url = "http://" +
            (await GetIp.ipAddress) +
            ":" +
            flingy.httpServer.port.toString();
        // store the original rest period
        var origRestPeriod = exercise.restPeriodAfter;
        // we don't want to cast a timer this time, so set it to false.
        startTimerCast = false;
        cast(
          url: url,
          player: player,
          mediaTitle: thisExercise +
              nextExercise +
              '{"startTimerCast":' +
              startTimerCast.toString() +
              "}"
                  '{"firstExercise":' +
              firstExercise.toString() +
              "}",
          context: context,
        );
        // put the rest period back to what the user knows.
        exercise.restPeriodAfter = origRestPeriod;
      }
      // regardless of cast, here, we need to handle the video
      if (settings.saveCloud) {
        // upload the compressed video to cloud storage. could change to a upload then update model to not need to wait.

        exercise.videoPath = await uploadVideoToCloud(context, targetFilePath);
        exercise.thumbnailPath =
            await uploadThumbnailToCloud(context, targetFilePath);
        var mediaInfo = await VideoCompress.getMediaInfo(targetFilePath);
        exercise.aspectRatio = mediaInfo.height / mediaInfo.width;
        exercise.duration = mediaInfo.duration;
        print(exercise.videoPath);
      }
      if (settings.saveLocal) {
        GallerySaver.saveVideo(targetFilePath);
      }
    }
    // even if no video, we can still advance, so do that.
    else {
      if (thisDay.updateMaxIfGetReps &&
          //thisDay.areWeOnLastSet()

          exercise.thisSetProgressSet) {
        // if we got the reps..
        // but is this the next set already....
        if (int.tryParse(formControllerReps.text
                .replaceAll(new RegExp(r'[^0-9]'), '')) >=
            exercise.prescribedReps) {
          progressAfter = true;
        }
      }
      // holler about failure or greatness depending on if they got it or not.

      // but only holler if they got the reps OR they are set to get mean quotes.
      if (int.tryParse(formControllerReps.text
                  .replaceAll(new RegExp(r'[^0-9]'), '')) >=
              exercise.prescribedReps ||
          settings.meanQuotes) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(Quotes().getQuote(
              // if you passed
              greatnessQuote: int.parse(formControllerReps.text
                      .replaceAll(new RegExp(r'[^0-9]'), '')) >=
                  exercise.prescribedReps)),
        ));
      }
    }
    // no need to ask about REPS if not recording video, because they can just edit it directly in the form
    // before hitting the button. a bit annoying i guess, and not expected.
    //show the next execise
    displayInExerciseInfo(exercise: nextSet, justRemovedPR: false);

    // at this point we have a URL (possibly garbage though?) for the video, so update the cloud record with that information
    //....so could check for the garbage (default) URLs before updating this..
    // make the firestore record for this exercise. (dangerous, they can still back out of video.....)
    //String origExerciseID =
    //await
    createDatabaseRecord(exercise: exercise, userID: user.fAuthUser.uid);
    // otherwise we'll cast the default video.
    if (doCast & !doVideo) {
      cast(
        url: url,
        player: player,
        mediaTitle: thisExercise +
            nextExercise +
            '{"startTimerCast":' +
            startTimerCast.toString() +
            "}"
                '{"firstExercise":' +
            firstExercise.toString() +
            "}",
        context: context,
      );
    }

    // check for PRs and upload them if so.
    await prsController
        .setPotentialPR(context: context, lift: exercise, isRep: true)
        .then((value) {
      if (value) {
        exercise.wasRepPRSet = true;
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("New ${exercise.title} rep record set!"),
        ));
      }
    });

    /// TODO: TEST WITH 5XPR
    /// - TRY SBUMITTING WITH IT.
    /// - ALSO, WHEN YOU SUBMIT, IT ADDS XPR BACK IN
    await prsController
        .setPotentialPR(context: context, lift: exercise, isRep: false)
        .then((value) {
      if (value) {
        exercise.wasWeightPRSet = true;
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("New ${exercise.title} weight record set!"),
        ));
      }
    });

// could do this before the casting and saving and save some round trips. more logical, puts correct info on the TV for end user too...
    // if we passed on the week that we were told to pass on, progress at the end.
    // TODO: this is also broken when the last set is the test set

    if (progressAfter) // && exerciseDayController.areWeOnLastSet(context)) {
    {
      lifterMaxesController.update1RepMax(
          context: context,
          // TODO: be careful with this, since we're updating/progressing to the next exercise above this point.
          lift: exercise.title,
          progression: true,
          updateCloud: true);
    }
    return true;
  }
}
