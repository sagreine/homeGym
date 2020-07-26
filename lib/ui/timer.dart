//import 'dart:io';
//import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fling/remote_media_player.dart';
//import 'package:home_gym/blocs/timer/timer_bloc.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fling/flutter_fling.dart';
//import 'package:home_gym/blocs/video/video_bloc.dart';
import 'package:home_gym/widgets/widgets.dart';
import 'package:home_gym/models/models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:mime/mime.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart' show rootBundle;

//sagre.HomeGymTV.player

///This class allows you to create a simple server on `http://localhost:[port]/` in order to be able to load your assets file on a server. The default [port] value is `8080`.
/*
class InAppLocalhostServer {
  HttpServer _server;
  int _port = 8080;

  InAppLocalhostServer({int port = 8080}) {
    this._port = port;
  }
*/
///Starts a server on http://localhost:[port]/.
///
///**NOTE for iOS**: For the iOS Platform, you need to add the `NSAllowsLocalNetworking` key with `true` in the `Info.plist` file (See [ATS Configuration Basics](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW35)):
///```xml
///<key>NSAppTransportSecurity</key>
///<dict>
///    <key>NSAllowsLocalNetworking</key>
///    <true/>
///</dict>
///```
///The `NSAllowsLocalNetworking` key is available since **iOS 10**.
/*
  Future<void> start() async {
    if (this._server != null) {
      throw Exception('Server already started on http://localhost:$_port');
    }

    var completer = Completer();

    //runZoned(() {
    HttpServer.bind('127.0.0.1', _port).then((server) {
      print('Server running on http://localhost:' + _port.toString());

      this._server = server;

      server.listen((HttpRequest request) async {
        var body = List<int>();
        var path = request.requestedUri.path;
        path = (path.startsWith('/')) ? path.substring(1) : path;
        //path += (path.endsWith('/')) ? 'index.html' : '';

        final directory = await getApplicationDocumentsDirectory();
        path = directory.path + "/video1.txt";
        print(path);

        String path2 = "http://localhost:8080/video1.txt";
        print(path2);
        //File('$path/video1.txt');

        try {
          body = (await File(path).readAsBytes()).buffer.asUint8List();
          //body = (await rootBundle.load(path))
          //.buffer
          //.asUint8List();
        } catch (e) {
          print(e.toString());
          request.response.close();
          return;
        }

        var contentType = ['text', 'html'];
        if (!request.requestedUri.path.endsWith('/') &&
            request.requestedUri.pathSegments.isNotEmpty) {
          var mimeType =
              lookupMimeType(request.requestedUri.path, headerBytes: body);
          if (mimeType != null) {
            contentType = mimeType.split('/');
          }
        }

        request.response.headers.contentType =
            ContentType(contentType[0], contentType[1], charset: 'utf-8');
        request.response.add(body);
        request.response.close();
      });

      completer.complete();
    });
    //}, onError: (e, stackTrace) => print('Error: $e $stackTrace'));

    return completer.future;
  }

  ///Closes the server.
  Future<void> close() async {
    if (this._server != null) {
      await this._server.close(force: true);
      print('Server running on http://localhost:$_port closed');
      this._server = null;
    }
  }
}*/

class Timer extends StatefulWidget {
  @override
  _MyTimerState createState() => _MyTimerState();
}

class _MyTimerState extends State<Timer> {
  static const TextStyle timerTextStyle = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.bold,
  );

  List<RemoteMediaPlayer> _flingDevices;
  RemoteMediaPlayer _selectedPlayer;
  String _mediaState = "null";
  String _mediaCondition = "null";
  String _mediaPosition = "null";
  FlutterFling fling;
  String address;
  int port;
  //InAppLocalhostServer appServer; // = new InAppLocalhostServer();

  final databaseReference = Firestore.instance;
//  final storageReference = FirebaseStorage.instance;

  // ExcericseSet exercise
  void createDatabaseRecord(ExerciseSet exercise) async {
    /*await databaseReference.collection("VIDEOS").document("2").setData({
      'title': 'Mastering Flutter',
      'description': 'Programming Guide for Dart',
      'videoItself': pickedFile,
    });*/

    DocumentReference ref = await databaseReference.collection("VIDEOS").add({
      'title': 'Flutter in Action',
      'description': 'Complete Programming Guide to learn Flutter'
    });

    //untested
    await databaseReference.collection("VIDEOS").add(
          Map<String, dynamic>.from((exercise.toJson())),

          //'title': 'Flutter in Action',
          //'description': 'Complete Programming Guide to learn Flutter'
        );
    print(ref.documentID);
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

  @override
  void initState() {
    super.initState();
    //_initServer();

    fling = FlutterFling();
    getSelectedDevice();
  }
/*
  _initServer() async {
    final server = new LocalAssetsServer(
      address: InternetAddress.loopbackIPv4,
      assetsBasePath: (await getApplicationDocumentsDirectory()).toString(),
    );

    final address = await server.serve();
    String p = await readCounter();
    print("read back value is: " + p);

    setState(() {
      this.address = address.address;
      port = server.boundPort;
    });
  }*/

  getCastDevices() async {
    FlutterFling.startDiscoveryController((status, player) {
      _flingDevices = List();
      if (status == PlayerDiscoveryStatus.Found) {
        setState(() {
          _flingDevices.add(player);
        });
      } else {
        setState(() {
          _flingDevices.remove(player);
        });
      }
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
    //final directory = 'http://$address:$port';
    //return directory;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/video1.txt');
  }

  Future<File> writeCounter(String counter) async {
    final file = await _localFile;

    // Write the file.
    return file.writeAsString(counter);
  }

  Future<String> readCounter() async {
    try {
      final file = await _localFile;
      print(file.path.toString());

      // Read the file
      String contents = await file.readAsString();
      print(contents);
      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "error it didn't work";
    }
  }

  getSelectedDevice() async {
    RemoteMediaPlayer selectedDevice;
    try {
      selectedDevice = await FlutterFling.selectedPlayer;
    } on PlatformException {
      print('Failed to get selected device');
    }
    setState(() {
      _selectedPlayer = selectedDevice;
    });
  }

  castMediaTo(RemoteMediaPlayer player) async {
    _selectedPlayer = player;
    var exercise = Provider.of<ExerciseSet>(context, listen: false);

//String uri_to_try =  await rootBundle.loadString('assets/videos/science.mp4');

    await FlutterFling.play(
      (state, condition, position) {
        setState(() {
          _mediaState = '$state';
          _mediaCondition = '$condition';
          _mediaPosition = '$position';
        });
      },
      player: _selectedPlayer,

// this code will be used to https-isize and to not include json vars we don't want to send if the jsonkey Ignore doesn't work
/*
Map<String dynamic> mappedVehicle = vehicle.toJson();

  vehicle.remove("tires");
  vehicle.remove("seats");
  // This will remove the fields 

  var finalVehicle = jsonEncode(mappedVehicle);

  final Response response = await put(
      Uri.https(apiEndpoint, {"auth": authKey}),
      headers: headers,
      body: finalVehicle);
*/

      mediaUri: await getVideo(), //exercise.videoPath,
      //"https://i.imgur.com/ACgwkoh.mp4",
      //"https://i.imgur.com/USHrpMe.mp4",
      //"file:///android_asset/flutter_assets/assets/videos/science.mp4",
      //"https://ran.openstorage.host/dl/IJ4CGyOjKl1BjOyTAxFnGA/1565422242/889127646/5ca3772258fd44.44825533/D%20C%20Proper.mkv",
      //(Uri.dataFromString("assets/videos/science.mp4")).toString(),
      //uri_to_try,

      //(Uri.dataFromString("file:///android_asset/videos/science.mp4")).toString(),
      //Uri.   .fromFile(new File("file:///android_asset/videos/science.mp4"));

      mediaTitle: json.encode(exercise.toJson()),
    )
        //"{'title':'Sample Video for Mary :)', 'description': 'Scott benching, 12/2020', 'type': 'video/'}")
        .then((_) => getSelectedDevice());
  }

  @override
  void dispose() async {
    await FlutterFling.stopDiscoveryController();
    super.dispose();
    //appServer.close();
  }

  Future<String> getVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getVideo(source: ImageSource.camera);
    var exercise = Provider.of<ExerciseSet>(context, listen: false);
    // placeholders for now.

    exercise.title = "sample_video23456";
    exercise.description = 'Scott benching, 12-2020';
    exercise.restPeriodAfter = 6;
    exercise.type = 'video/';
    var url = await uploadToCloudStorage(File(pickedFile.path));
    exercise.videoPath = url;
    print(json.encode(exercise.toJson()));
    createDatabaseRecord(exercise);
    return url;

    //String p = await readCounter();
    //print("read back value is: " + p);
    //print('http://$address:$port');
    //.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Gym')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Media State: $_mediaState'),
          Text('Media Condition: $_mediaCondition'),
          Text('Media Position: $_mediaPosition'),
          Text(
              'Selected Device: ${_selectedPlayer != null ? _selectedPlayer.name : 'null'}'),
          Text("Fire devices: "),
          _flingDevices == null
              ? Text('Try casting something')
              : _flingDevices.isEmpty
                  ? Text('None nearby')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _flingDevices.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_flingDevices[index].name),
                          subtitle: Text(_flingDevices[index].uid),
                          onTap: () => castMediaTo(_flingDevices[index]),
                        );
                      },
                    )
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          RaisedButton(
            child: Text('Search'),
            onPressed: () => getCastDevices(),
          ),
          RaisedButton(
            child: Text('Dispose Controller'),
            onPressed: () async {
              await FlutterFling.stopDiscoveryController();
              setState(() {
                _flingDevices = List();
                _mediaState = 'null';
                _mediaCondition = 'null';
                _mediaPosition = '0';
                _selectedPlayer = null;
              });
            },
          ),
          RaisedButton(
            child: Text('Play Cast'),
            onPressed: () async => await FlutterFling.playPlayer(),
          ),
          RaisedButton(
            child: Text('Stop Cast'),
            onPressed: () async {
              await FlutterFling.stopPlayer();
              setState(() {
                _flingDevices = null;
              });
            },
          ),
          RaisedButton(
            child: Text('Mute Cast'),
            onPressed: () async => await FlutterFling.mutePlayer(true),
          ),
        ],
      ),
    );
  }
}

/*
    return BlocBuilder<VideoBloc, VideoState>(builder: (context, state) {
      final video = (state as VideoInitial);
      return Scaffold(
        body: Center(
          child: FlatButton(
            child: Text("lallala"),
            onPressed: () {
              BlocProvider.of<VideoBloc>(context).add(VideoRecordStart());
            },
          ),
        ),
      );
    });
*/
/*
    
  
  }
}
*/
/*Stack(children: [
        //Background(),
       Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 100.0),
            child: Center(
              child: BlocBuilder<TimerBloc, TimerState>(
                builder: (context, state) {
                  final String minutesStr = ((state.duration / 60) % 60)
                      .floor()
                      .toString()
                      .padLeft(2, '0');
                  final String secondsStr =
                      (state.duration % 60).floor().toString().padLeft(2, '0');
                  return Text(
                    '$minutesStr:$secondsStr',
                    style: Timer.timerTextStyle,
                  );
                },
              ),
            ),
          ),
          BlocBuilder<TimerBloc, TimerState>(
            buildWhen: (previousState, state) =>
                state.runtimeType != previousState.runtimeType,
            builder: (context, state) => Actions(),
          ),
        ],
      ),
      ],
      ),
    );
  }
}*/
/*
class Actions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _mapStateToActionButtons(
        timerBloc: BlocProvider.of<TimerBloc>(context),
      ),
    );
  }

  List<Widget> _mapStateToActionButtons({
    TimerBloc timerBloc,
  }) {
    final TimerState currentState = timerBloc.state;
    if (currentState is TimerInitial) {
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () =>
              timerBloc.add(TimerStarted(duration: currentState.duration)),
        ),
      ];
    }
    if (currentState is TimerRunInProgress) {
      return [
        FloatingActionButton(
          child: Icon(Icons.pause),
          onPressed: () => timerBloc.add(TimerPaused()),
        ),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(TimerReset()),
        ),
      ];
    }
    if (currentState is TimerRunPause) {
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () => timerBloc.add(TimerResumed()),
        ),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(TimerReset()),
        ),
      ];
    }
    if (currentState is TimerRunComplete) {
      return [
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(TimerReset()),
        ),
      ];
    }
    return [];
  }
}

class Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WaveWidget(
      config: CustomConfig(
        gradients: [
          [
            Color.fromRGBO(72, 74, 126, 1),
            Color.fromRGBO(125, 170, 206, 1),
            Color.fromRGBO(184, 189, 245, 0.7)
          ],
          [
            Color.fromRGBO(72, 74, 126, 1),
            Color.fromRGBO(125, 170, 206, 1),
            Color.fromRGBO(172, 182, 219, 0.7)
          ],
          [
            Color.fromRGBO(72, 73, 126, 1),
            Color.fromRGBO(125, 170, 206, 1),
            Color.fromRGBO(190, 238, 246, 0.7)
          ],
        ],
        durations: [19440, 10800, 6000],
        heightPercentages: [0.03, 0.01, 0.02],
        gradientBegin: Alignment.bottomCenter,
        gradientEnd: Alignment.topCenter,
      ),
      size: Size(double.infinity, double.infinity),
      waveAmplitude: 25,
      backgroundColor: Colors.blue[50],
    );
  }
}
*/
