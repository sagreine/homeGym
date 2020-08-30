//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/gestures.dart';
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
  final String program;
  final String exercise;
  Home({Key key, this.program, this.exercise});
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
  String _selectedTitle;

  // temporary. and should be in controller.
  bool doVideo;
// temporary. and should be in controller.
  bool doCast;

  @override
  void initState() {
    super.initState();
    homeController.displayInExerciseInfo(context: context);
    _selectedTitle = widget.exercise;
    fling = FlutterFling();
    doVideo = false;
    doCast = false;
    // this is bad, but whatever.
    homeController.formControllerRestInterval.text = "90";
  }

  @override
  void dispose() async {
    super.dispose();
    await FlutterFling.stopDiscoveryController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Gym TV"),
      ),
      drawer: Consumer<Muser>(builder: (context, user, child) {
        return Drawer(
          child: Column(children: [
            DrawerHeader(
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.brown.shade800,
                          backgroundImage: user.firebaseUser.photoUri.isEmpty
                              ? AssetImage("assets/images/pos_icon.png")
                              : NetworkImage(user.getPhotoURL()),
                        ),
                        SizedBox(width: 10),
                        Column(
                          children: [
                            SizedBox(height: 35),
                            //Image.asset("assets/images/pos_icon.png"),
                            Text(user.getDisplayName()),
                            SizedBox(height: 10),
                            Text(user.firebaseUser.email),
                            SizedBox(height: 10),
                            InkWell(
                              child: Text(
                                "View Profile",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          ProfileView()),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                      //trailing: ,
                    ),
                  ),
                  // ),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView(children: [
                ListTile(
                    title: Text("Pick Lift"),
                    leading: Icon(Icons.fitness_center),
                    // TODO: Not tested at all.
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) => PickDay()),
                      );
                    }),
                ListTile(
                    title: Text("Do Lift"),
                    leading: Icon(Icons.directions_run),
                    // typical is icons, and need a similar iimage for all (image is bigger than icon) but to think about
                    //leading: Image.asset("assets/images/pos_icon.png"),
                    onTap: () {
                      //TODO: popAndPushNamed once ready for that
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute<void>(
                          builder: (BuildContext context) => Home()));
                    }),
                ListTile(
                    title: Text("My Weights"),
                    leading: Icon(Icons.filter_list),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                LifterWeightsView()),
                      );
                    }),
                ListTile(
                    title: Text("My Maxes"),
                    //leading: Icon(Icons.description),
                    leading: Icon(Icons.format_list_bulleted),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                LifterMaxesView()),
                      );
                    }),
                ListTile(
                    title: Text("Help"),
                    leading: Icon(Icons.help),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) => HelpView()),
                      );
                    }),
                ListTile(
                  title: Text("Settings"),
                  leading: Icon(Icons.settings),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (BuildContext context) => Settings()),
                    );
                  },
                ),
                ListTile(
                  title: Text("Log Out"),
                  leading: Icon(Icons.exit_to_app),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await homeController.logout(context);
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (BuildContext context) => Login()),
                    );
                  },
                ),
              ]),
            ),
          ]),
        );
      }),
      body: Consumer<FlingMediaModel>(
        builder: (context, flingy, child) {
          return SafeArea(
            child: Column(children: <Widget>[
              Text(
                  "Pick a cast in Settings, Enter set info, and record! Auto cloud backup and fling to TV from there"),
              Expanded(
                child: Form(
                  autovalidate: true,
                  key: _formkey,
                  // would want Consumer of Exercise here, to leverage Provider, but doing via controller for now...
                  child: ListView(
                    children: <Widget>[
                      new DropdownButton<String>(
                        hint: _selectedTitle == null
                            ? Text('Main exercise for the day')
                            : SizedBox(
                                width: 50,
                                child: TextFormField(
                                  controller:
                                      homeController.formControllerTitle,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Title can't be blank";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                        //might want to force them back insead of allowing this...
                        items: <String>['Squat', 'Press', 'Deadlift', 'Bench']
                            .map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        value: _selectedTitle,
                        onChanged: (_) {
                          setState(() {
                            homeController.formControllerTitle.text = _;
                            _selectedTitle = _;
                          });
                        },
                      ),
                      SizedBox(height: 8.0),
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
                            borderSide:
                                BorderSide(color: Colors.blueGrey, width: 1.0),
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
                                if (value.isEmpty) {
                                  return "Can't be blank";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // this should be in a controller
              CheckboxListTile(
                title: Text("Cast to TV"),
                secondary:
                    doCast ? Icon(Icons.cast_connected) : Icon(Icons.cast),
                value: doCast,
                onChanged: (newValue) {
                  setState(() {
                    doCast = newValue;
                    if (newValue == false) {
                      doVideo = false;
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text("With Video"),
                secondary:
                    doVideo ? Icon(Icons.videocam) : Icon(Icons.videocam_off),
                value: doCast ? doVideo : false,
                onChanged: (newValue) {
                  setState(() {
                    if (doCast) {
                      doVideo = newValue;
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.platform,
              ),
              // could make thid disabled when not valid, but headache to setState everywhere
              RaisedButton(
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
                            player: flingy.selectedPlayer,
                            context: context,
                            doCast: doCast,
                            doVideo: doVideo);
                      } else {
                        print(
                            "form is valid but no fling player selected. launching settings");
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              builder: (BuildContext context) => Settings()),
                        );
                      }
                    }
                  },
                  // TODO: cast v cast selected = do we have a cast device selected...
                  child: ListTile(
                    leading: doCast
                        ? Icon(Icons.cast_connected)
                        : SizedBox(width: 5),
                    title: Text("Record and cast"),
                  )),
            ]),
          );
        },
      ),
    );
  }
}
