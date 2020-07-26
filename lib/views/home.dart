import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _formkey = GlobalKey<_HomeState>();

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
          return SafeArea(
            child: Column(
              children: <Widget>[
                RaisedButton(
                  child: Text("Find all fling devices and pick one"),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (BuildContext context) => FlingFinder()));
                  },
                ),
                Form(
                  key: _formkey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: new InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.greenAccent,
                              width: 1.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blueGrey, width: 1.0),
                          ),
                          labelText:
                              homeController.formControllerTitle.text == null
                                  ? "Enter Exercise Title"
                                  : "Edit Exercise Title",
                        ),
                        autocorrect: true,
                        enableSuggestions: true,
                        controller: homeController.formControllerTitle,
                        validator: (value) {
                          //homeController.formController.validator()
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: new InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.greenAccent,
                              width: 1.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blueGrey, width: 1.0),
                          ),
                          labelText: homeController
                                      .formControllerDescription.text ==
                                  null
                              ? "Enter a description for the exercise or video"
                              : "Edit a description for the exercise or video",
                        ),
                        autocorrect: true,
                        enableSuggestions: true,
                        controller: homeController.formControllerDescription,
                        validator: (value) {
                          //homeController.formController.validator()
                          return null;
                        },
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
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
                                labelText:
                                    homeController.formControllerReps.text ==
                                            null
                                        ? "Enter Reps"
                                        : "Edit Reps",
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly,
                              ],
                              autocorrect: true,
                              enableSuggestions: true,
                              controller: homeController.formControllerReps,
                              validator: (value) {
                                //homeController.formController.validator()
                                return null;
                              },
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
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
                                labelText:
                                    homeController.formControllerWeight.text ==
                                            null
                                        ? "Enter Weight"
                                        : "Edit Weight",
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly,
                              ],
                              autocorrect: true,
                              enableSuggestions: true,
                              controller: homeController.formControllerWeight,
                              validator: (value) {
                                //homeController.formController.validator()
                                return null;
                              },
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
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
                                labelText: homeController
                                            .formControllerRestInterval.text ==
                                        null
                                    ? "Enter Weight"
                                    : "Edit Weight",
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly,
                              ],
                              autocorrect: true,
                              enableSuggestions: true,
                              controller:
                                  homeController.formControllerRestInterval,
                              validator: (value) {
                                //homeController.formController.validator()
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      Consumer<ExerciseSet>(
                        builder: (context, thisSet, child) {
                          thisSet.description =
                              homeController.formControllerDescription.text;
                          thisSet.title =
                              homeController.formControllerTitle.text;
                          // first time through set to 0, otherwise parse the int.
                          thisSet.restPeriodAfter =
                              homeController.formControllerRestInterval.text ==
                                      ""
                                  ? 0
                                  : int.parse(homeController
                                      .formControllerRestInterval.text);
                          thisSet.weight =
                              homeController.formControllerWeight.text == ""
                                  ? 0
                                  : int.parse(
                                      homeController.formControllerWeight.text);
                          thisSet.type = "video/";
                          return RaisedButton(
                            onPressed: () {
                              homeController.castMediaTo(
                                  flingy.selectedPlayer, context);
                            },
                            child: Text("Record and cast"),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                RaisedButton(
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
                      flingy.flingDevices = null;
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
        },
      ),
    );
  }
}
