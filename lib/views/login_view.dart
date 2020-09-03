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

  //FirebaseUser _firebaseUser;
  //User _user;
  Muser _user;
  String error;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<Muser>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _user = Provider.of<Muser>(context, listen: false);
  }

  Scaffold buildNextPage() {
    if (_user.firebaseUser.isNewUser) {
      return Scaffold(
        body: Container(child: IntroScreenView()),
      );
    } else {
      return Scaffold(
        body: Container(child: PickDayView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //Navigator.of(context).pushReplacement(
    //MaterialPageRoute<void>(builder: (BuildContext context) {
    //

    //  return Scaffold(body: Container(child: PickDay()));

    // if already logged in. this handles e.g. the phone falling asleep on next page (guh)
    // does require that we null out on logout, but that looks standard
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
              if (_user.getPhotoURL() != null &&
                  _user.getPhotoURL().isNotEmpty) {
                precacheImage(new NetworkImage(_user.getPhotoURL()), context);
              }
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

//consider... https://stackoverflow.com/questions/50885891/one-time-login-in-app-firebaseauth

  Future<void> _onActionTapped({BuildContext context, Muser user}) async {
    await FirebaseAuthUi.instance().launchAuth([
      AuthProvider.email(),
      AuthProvider.google(),
      //AuthProvider.twitter(),
      AuthProvider.phone(), // kind of silly on a phone though?
    ]).then((firebaseUser) {
      user.firebaseUser = firebaseUser;
      // pull in this users' information
      loginController.getMaxes(context);
      loginController.getBarWeight(context);
      loginController.getPlates(context);
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
