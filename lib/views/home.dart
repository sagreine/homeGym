import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fling/flutter_fling.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:provider/provider.dart';
import 'package:home_gym/controllers/controllers.dart';

//sagre.HomeGymTV.player

// more of this should go in controller functions

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
  final _formkey = GlobalKey<FormState>();

  // i don't know if we need these? shouldn't, ideally..
  FlutterFling fling;
  ExerciseDay exerciseDay;
  String address;
  int port;

  @override
  void initState() {
    super.initState();
    fling = FlutterFling();
  }

  @override
  void dispose() async {
    await FlutterFling.stopDiscoveryController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Gym TV"),
        leading: Padding(
          padding: EdgeInsets.all(3),
          child: Image.asset("assets/images/pos_icon.png"),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (BuildContext context) => FlingFinder()),
              );
            },
          ),
        ],
      ),
      body: Consumer<FlingMediaModel>(
        builder: (context, flingy, child) {
          return SafeArea(
            child: Column(
              children: <Widget>[
                Text(
                    "Pick a cast in Settings, Enter set info, and record! Auto cloud backup and fling to TV from there"),
                Expanded(
                  child: Form(
                    key: _formkey,
                    // would want Consumer of Exercise here, to leverage Provider, but doing via controller for now...
                    child: ListView(
                      children: <Widget>[
                        SizedBox(height: 8.0),
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
                              borderSide: BorderSide(
                                  color: Colors.blueGrey, width: 1.0),
                            ),
                            labelText: "Exercise Title",
                          ),
                          autocorrect: true,
                          enableSuggestions: true,
                          controller: homeController.formControllerTitle,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Title can't be blank";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8.0),
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
                              borderSide: BorderSide(
                                  color: Colors.blueGrey, width: 1.0),
                            ),
                            labelText: "Description for this set",
                          ),
                          autocorrect: true,
                          enableSuggestions: true,
                          controller: homeController.formControllerDescription,
                          validator: (value) {
                            //homeController.formController.validator()
                            return null;
                          },
                        ),
                        SizedBox(height: 8.0),
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
                                    labelText: "Reps"),
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
                            SizedBox(
                              width: 2,
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
                                  labelText: "Weight",
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
                            SizedBox(
                              width: 2,
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
                                  labelText: "Rest after",
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
                        // we don't use the data here so it is wasteful to build a widget...
                        Consumer<ExerciseDay>(
                          builder: (context, thisDay, child) {
                            return RaisedButton(
                              onPressed: () async {
                                if (_formkey.currentState.validate()) {
                                  print("valid form");
                                  // make any updates that are necessary, check we have a fling device, then cast
                                  if (flingy.selectedPlayer != null) {
                                    // do it so it goes -> update exercise, getNextExercise(this updates what you see though?),
                                    // cast (them both)
                                    homeController.updateThisExercise(
                                      context,
                                    );
                                    // then get the next exercise's info into the form (not fully implemented of course)
                                    //homeController.updateExercise(context);
                                    // may need to await this, if it is updating our exercise that we're sending....
                                    await homeController.castMediaTo(
                                        flingy.selectedPlayer, context);
                                  } else {
                                    print(
                                        "form is valid but no fling player selected. launching settings");
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                          builder: (BuildContext context) =>
                                              FlingFinder()),
                                    );
                                  }
                                }
                              },
                              child: Text("Record and cast"),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RaisedButton(
                        child: Text('Get Exercises'),
                        onPressed: () {
                          homeController.getExercises(context);
                        }),
                    RaisedButton(
                        child: Text('Next Exercise'),
                        onPressed: () {
                          homeController.nextExercise(context);
                        }),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
