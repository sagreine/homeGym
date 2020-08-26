import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  void initState() {
    super.initState();
    homeController.displayInExerciseInfo(context: context);
    _selectedTitle = widget.exercise;
    fling = FlutterFling();
    doVideo = false;
  }

  @override
  void dispose() async {
    super.dispose();
    await FlutterFling.stopDiscoveryController();
  }

  String getDisplayName() {
    String displayName = FirebaseAuth.instance.currentUser.displayName;

    //user.firebaseUser.user.getDisplayName();
    if (displayName != null && displayName != "") {
      return displayName;
    }

    for (UserInfo userInfo in FirebaseAuth.instance.currentUser.providerData) {
      if (userInfo.displayName != null && userInfo.displayName != "") {
        return userInfo.displayName;
      }
    }

    return "Unnamed User";
  }

  // careful, URL vs Uri
  String getPhotoURL() {
    String getPhotoURL = FirebaseAuth.instance.currentUser.photoURL;

    //user.firebaseUser.user.getDisplayName();
    if (getPhotoURL != null && getPhotoURL != "") {
      return getPhotoURL;
    }

    for (UserInfo userInfo in FirebaseAuth.instance.currentUser.providerData) {
      if (userInfo.photoURL != null && userInfo.photoURL != "") {
        return userInfo.photoURL;
      }
    }

    return null;
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
                  /*
                  Padding(
                    padding: EdgeInsets.all(3),
                    child: Image.asset("assets/images/pos_icon.png"),
                  ),
*/
                  //SizedBox(
//                    height: 200,
                  //                  child:
                  Row(
                    //dense: true,
                    //isThreeLine: true,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.brown.shade800,
                        backgroundImage: user.firebaseUser.photoUri.isEmpty
                            ? AssetImage("assets/images/pos_icon.png")
                            : NetworkImage(getPhotoURL()),
                      ),
                      SizedBox(width: 10),
                      Column(
                        children: [
                          //Image.asset("assets/images/pos_icon.png"),
                          Text(getDisplayName()),
                          SizedBox(height: 10),
                          Text(user.firebaseUser.email),
                        ],
                      ),
                    ],
                    //trailing: ,
                  ),
                  // ),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            Text("Pick Lift"),
            Text("Do Lift"),
            Text("Help"),
            Text("Send feedback"),
            Text("Features Coming soon"),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) => Settings()),
                );
              },
            ),
            Text("Settings"),
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
              CheckboxListTile(
                title: Text("Record Video"),
                value: doVideo,
                onChanged: (newValue) {
                  setState(() {
                    doVideo = newValue;
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
                          recordNewVideo: doVideo);
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
                child: Text("Record and cast"),
              ),
            ]),
          );
        },
      ),
    );
  }
}
