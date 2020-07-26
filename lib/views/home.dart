import 'package:flutter/material.dart';
import 'package:flutter_fling/flutter_fling.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:provider/provider.dart';
import 'package:home_gym/controllers/controllers.dart';

//sagre.HomeGymTV.player

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /*static const TextStyle timerTextStyle = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.bold,
  );*/
  HomeController homeController = HomeController();

  FlutterFling fling;
  String address;
  int port;

  @override
  void initState() {
    super.initState();
    //_initServer();

    fling = FlutterFling();
    //getSelectedDevice();
  }

  @override
  void dispose() async {
    await FlutterFling.stopDiscoveryController();
    super.dispose();
    //appServer.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FlingMediaModel>(
        builder: (context, flingy, child) {
          return Column(
            children: <Widget>[
              FlatButton(
                child: Text("Find all fling devices and pick one"),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (BuildContext context) => FlingFinder()));
                },
              ),
              Consumer<ExerciseSet>(
                builder: (context, thisSet, child) {
                  thisSet.description = "mvc description";
                  thisSet.title = "mvc title";
                  thisSet.restPeriodAfter = 2833;
                  thisSet.type = "video/";
                  return FlatButton(
                    onPressed: () {
                      homeController.castMediaTo(
                          flingy.selectedPlayer, context);
                    },
                    child: Text("Record and cast"),
                  );
                },
              ),
              FlatButton(
                child: Text("Save video to cloud"),
                onPressed: () {},
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
                    //controller.flingDevices = null;
                  });
                },
              ),
              RaisedButton(
                child: Text('Mute Cast'),
                onPressed: () async => await FlutterFling.mutePlayer(true),
              ),
            ],
          );
        },
      ),
    );
  }
}
