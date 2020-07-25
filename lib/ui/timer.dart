import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fling/remote_media_player.dart';
import 'package:home_gym/blocs/timer/timer_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fling/flutter_fling.dart';

//sagre.HomeGymTV.player

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

  @override
  void initState() {
    super.initState();
    fling = FlutterFling();
    getSelectedDevice();
  }

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

//String uri_to_try =  await rootBundle.loadString('assets/videos/science.mp4');

    await FlutterFling.play((state, condition, position) {
      setState(() {
        _mediaState = '$state';
        _mediaCondition = '$condition';
        _mediaPosition = '$position';
      });
    },
            player: _selectedPlayer,
            mediaUri: "https://i.imgur.com/ACgwkoh.mp4",
            //"https://i.imgur.com/USHrpMe.mp4",
            //"file:///android_asset/flutter_assets/assets/videos/science.mp4",
            //"https://ran.openstorage.host/dl/IJ4CGyOjKl1BjOyTAxFnGA/1565422242/889127646/5ca3772258fd44.44825533/D%20C%20Proper.mkv",
            //(Uri.dataFromString("assets/videos/science.mp4")).toString(),
            //uri_to_try,

            //(Uri.dataFromString("file:///android_asset/videos/science.mp4")).toString(),
            //Uri.   .fromFile(new File("file:///android_asset/videos/science.mp4"));

            mediaTitle:
                "{'title':'Sample Video for Mary :)', 'description': 'Scott benching, 12/2020', 'type': 'video/'}")
        .then((_) => getSelectedDevice());
  }

  @override
  void dispose() async {
    await FlutterFling.stopDiscoveryController();
    super.dispose();
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
            child: Text('Pause Cast'),
            onPressed: () async => await FlutterFling.pausePlayer(),
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
          RaisedButton(
            child: Text('Unmute Cast'),
            onPressed: () async => await FlutterFling.mutePlayer(false),
          ),
          RaisedButton(
            child: Text('Forward Cast'),
            onPressed: () async => await FlutterFling.seekForwardPlayer(),
          ),
          RaisedButton(
            child: Text('Back Cast'),
            onPressed: () async => await FlutterFling.seekBackPlayer(),
          ),
          RaisedButton(
            child: Text('Seek to 30sec'),
            onPressed: () async =>
                await FlutterFling.seekToPlayer(position: 30000),
          )
        ],
      ),
    );
  }
}

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
/*
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
}*/
