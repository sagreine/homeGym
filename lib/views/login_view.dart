import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fAuth;
import 'package:firebase_auth_ui/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:home_gym/views/views.dart';

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

// maybe we can cover this stuff with a splash screen in the end, for those logged in already?

class _LoginViewState extends State<LoginView> {
  LoginController loginController = LoginController();

  //this part we could do in gcp functions instead of code
  LifterMaxesController lifterMaxesController = LifterMaxesController();
  LifterWeightsController lifterWeightsController = LifterWeightsController();

  //FirebaseUser _firebaseUser;
  //User _user;
  // TODO model not view....
  Muser _user;
  String error;
  bool result;
  // this flag is to prevent the auth listener from calling twice unnecessarily - when assigned, and when changed.
  // we only want one call, and if we already have a signed in user we can avoid multiple calls.
  var authFlag;

/*
  @override
  void initState() {
    super.initState();
    _user = Provider.of<Muser>(context, listen: false);

    //_clearOlddata();
  }*/

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _user = Provider.of<Muser>(context, listen: false);
    var firebaseAuth = fAuth.FirebaseAuth.instance;
    var haveUser = false;
    if (firebaseAuth != null) {
      haveUser = firebaseAuth.currentUser != null;
    }
    authFlag = (haveUser == true);
    if (haveUser) {
      _user.isNewUser = false;
    }
    //listener = new DataConnectionChecker().onStatusChange;
  }

  //TODO: well this sure isn't UI..
  void buildDefaultUser() async {
    await lifterMaxesController.update1RepMax(
        progression: false,
        context: context,
        lift: "bench",
        newMax: 100,
        updateCloud: true);
    await lifterMaxesController.update1RepMax(
        progression: false,
        context: context,
        lift: "deadlift",
        newMax: 120,
        updateCloud: true);
    await lifterMaxesController.update1RepMax(
        progression: false,
        context: context,
        lift: "squat",
        newMax: 110,
        updateCloud: true);
    await lifterMaxesController.update1RepMax(
        progression: false,
        context: context,
        lift: "press",
        newMax: 90,
        updateCloud: true);
// default bar weight of 45
    lifterWeightsController.updateBarWeight(context, 45);
    lifterWeightsController.updateBumpers(context: context, bumpers: false);
// add default plate counts. first, lbs
    lifterWeightsController.updatePlate(
        context: context, plate: 2.5, plateCount: 4);
    lifterWeightsController.updatePlate(
        context: context, plate: 5.0, plateCount: 4);
    lifterWeightsController.updatePlate(
        context: context, plate: 10.0, plateCount: 2);
    lifterWeightsController.updatePlate(
        context: context, plate: 25.0, plateCount: 2);
    lifterWeightsController.updatePlate(
        context: context, plate: 35.0, plateCount: 2);
    lifterWeightsController.updatePlate(
        context: context, plate: 45.0, plateCount: 2);
// add default plate counts. second, kgs
    lifterWeightsController.updatePlate(
        context: context, plate: 2.75, plateCount: 0);
    lifterWeightsController.updatePlate(
        context: context, plate: 5.5, plateCount: 0);
    lifterWeightsController.updatePlate(
        context: context, plate: 11, plateCount: 0);
    lifterWeightsController.updatePlate(
        context: context, plate: 22, plateCount: 0);
    lifterWeightsController.updatePlate(
        context: context, plate: 33, plateCount: 0);
    lifterWeightsController.updatePlate(
        context: context, plate: 44, plateCount: 0);
  }

  Scaffold buildNextPage() {
    //\\listener.drain();
    if (_user.isNewUser) {
      buildDefaultUser();
      //buildDefaultUser();
      return Scaffold(
        body: Container(child: IntroScreenView()),
      );
    } else {
      loginController.getMaxes(context);
      loginController.getBarWeight(context);
      loginController.getPlates(context);
      if (_user.getPhotoURL() != null && _user.getPhotoURL().isNotEmpty) {
        precacheImage(new NetworkImage(_user.getPhotoURL()), context);
      }
      return Scaffold(
        body: Container(child: PickDayView()),
      );
    }
  }

  /*doit(snapshot) async {
    //fauth.User user = snapshot.data;
    _user.fAuthUser = snapshot.data;
    //if (_user.fAuthUser == null) {
    await _onActionTapped(context: context, user: _user);
    //}
    return buildNextPage();
  }*/

  @override
  Widget build(BuildContext context) {
    return authFlag
        ? buildNextPage()
        : StreamBuilder<FirebaseUser>(
            stream: FirebaseAuthUi.instance().launchAuth(
              [
                AuthProvider.email(),
                AuthProvider.google(),
                //AuthProvider.twitter(),
                AuthProvider.facebook(),
                AuthProvider.phone(),
              ],
              //TODO: actual deep links.
              tosUrl: "https://sagrehomegym.web.app/",
              privacyPolicyUrl: "https://sagrehomegym.web.app/",
            ).asStream(),
            builder: (context, snapshot) {
              authFlag = true;
              if (snapshot.connectionState == ConnectionState.done) {
                _user.fAuthUser = fAuth.FirebaseAuth.instance.currentUser;
                // pull in this users' information or build a default user
                if (snapshot.data.isNewUser != false) {
                  _user.isNewUser = true;
                  //buildDefaultUser();
                } else {
                  _user.isNewUser = false;
                }
                return buildNextPage();
              } else {
                return Scaffold(
                  body: Center(
                    child: Container(),
                  ),
                );
              }
            },
          );
  }
  //_user = Provider.of<Muser>(context, listen: false);
  //Navigator.of(context).pushReplacement(
  //MaterialPageRoute<void>(builder: (BuildContext context) {
  //

  //  return Scaffold(body: Container(child: PickDay()));

  // if already logged in. this handles e.g. the phone falling asleep on next page (guh)
  // does require that we null out on logout, but that looks standard

//consider... https://stackoverflow.com/questions/50885891/one-time-login-in-app-firebaseauth

  Future<void> _onActionTapped({BuildContext context, Muser user}) async {
    await FirebaseAuthUi.instance().launchAuth(
      [
        AuthProvider.email(),
        AuthProvider.google(),
        //AuthProvider.twitter(),
        AuthProvider.phone(), // kind of silly on a phone though?
      ],
      //TODO: actual deep links.
      tosUrl: "https://sagrehomegym.web.app/",
      privacyPolicyUrl: "https://sagrehomegym.web.app/",
    ).then((firebaseUser) {
      //user.firebaseUser = firebaseUser;
      // pull in this users' information
      if (user.isNewUser) {
        buildDefaultUser();
      }
      loginController.getMaxes(context);
      loginController.getBarWeight(context);
      loginController.getPlates(context);
      if (user.getPhotoURL() != null && user.getPhotoURL().isNotEmpty) {
        precacheImage(new NetworkImage(user.getPhotoURL()), context);
      }
    }).catchError((error) {
      if (error is PlatformException) {
        setState(() {
          if (error.code == FirebaseAuthUi.kUserCancelledError) {}
        });
      }
    });
  }
/*
  void _logout() async {
    await FirebaseAuthUi.instance().logout();
    setState(() {
      _user = null;
    });
  }
  */
  /*
  // would delete all other associated data first...
  void _deleteUser() async {
    final result = await FirebaseAuthUi.instance().delete();
    if (result) {
      setState(() {
        _user = null;
      });
    }
  }
*/
}

/*
   //import 'package:data_connection_checker/data_connection_checker.dart';
   // stream wifi. could implement throughout app via mixin... spotify does this with a helper to turn on wifi/data
  Stream<DataConnectionStatus> listener;

  // in initState
  listener = DataConnectionChecker().onStatusChange;

  // if necessary, put in DidChangeDependencies
  result = await DataConnectionChecker().hasConnection;
  // note that this does not guarantee anyhting in calls afterwards, so more of a sanity check / waste of time vs. try-catch
    Future<bool> _activeConnection() async {
    return await DataConnectionChecker().hasConnection;
  }



/// this is stupid and dangerous - susceptible to a blip
    /// but also, why did we do this at all?
    /// Theory: DataConnectionStatus is a singleton. once it is set to Connected
    /// it isn't going to change state. i try to reassing a listener in hopes it would
    /// restart, but no dice - maybe just me not knowing how streams work, but tried new and func generated ones
    /// maybe there's a way to do it better though ('var abc;' and then abc func=>Stream() in init or something?)
    /// in any event i'm doing this for fun and it more or less works sooo....
    // check to see if we have an immediately active connection
    return new FutureBuilder(
        future: _activeConnection(),
        builder: (BuildContext context, AsyncSnapshot text) {
          // if we're done asking and the result is that we don't, open the stream to get it
          if (text.connectionState == ConnectionState.done &&
              text.hasError == false &&
              text.data == false) {
            return new StreamBuilder(
                stream: listener,
                initialData: DataConnectionStatus.disconnected,
                builder: (context, snapshot) {
                  // if we don't have data yet, say we're waiting
                  if (!snapshot.hasData) {
                    print('Checking internet status');
                    return CircularProgressIndicator();
                  }
                  // if we have data and that is that we're connected, we now have internet access! get login
                  else if (snapshot.data == DataConnectionStatus.connected) {
                    print("you have access to the internet!");
                    // may be able to get rid of this? and just keep this going? yield?
                    if (_user.firebaseUser != null) {
                      return buildNextPage();
                    } else {
                      return new FutureBuilder(
                          future:
                              _onActionTapped(context: context, user: _user),
                          builder: (BuildContext context, AsyncSnapshot text) {
                            if (text.connectionState == ConnectionState.done &&
                                text.hasError == false) {
                              print(
                                  "User auth done, without error. user is: ${_user.firebaseUser.displayName}");
                              return buildNextPage();
                            }
                            return SizedBox(
                              height: 200,
                              width: 200,
                              child: Text(
                                  !text.hasError ? "" : text.error.toString()),
                            );
                          });
                    }
                  }
                  // otherwise we have the data back and we don't have internet, so tell them to fix that
                  else {
                    print('You are disconnected from the internet.');
                    return Container(
                        child: (Text(
                            "Please connect to wifi or data to use this app")));
                  }
                });
          }
          // otherwise we know we have an active connection and don't need the stream to tell us, so go ahead
          // need to do error handling on original FutureBuilder though, and 'what about until we have our answer?'
          else if (text.connectionState == ConnectionState.done &&
              text.data == true) {
            if (_user.firebaseUser != null) {
              return buildNextPage();
            } else {
              return new FutureBuilder(
                  future: _onActionTapped(context: context, user: _user),
                  builder: (BuildContext context, AsyncSnapshot text) {
                    if (text.connectionState == ConnectionState.done &&
                        text.hasError == false) {
                      print(
                          "User auth done, without error. user is: ${_user.firebaseUser.displayName}");
                      return buildNextPage();
                    }
                    return SizedBox(
                      height: 200,
                      width: 200,
                      child: Text(!text.hasError ? "" : text.error.toString()),
                    );
                  });
            }
          }
          return SizedBox(
            height: 200,
            width: 200,
            child: Text(!text.hasError ? "" : text.error.toString()),
          );
        });
        */
