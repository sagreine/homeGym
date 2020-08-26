import 'package:firebase_auth_ui/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/pick_day.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

// maybe we can cover this stuff with a splash screen in the end, for those logged in already?

class _LoginState extends State<Login> {
  LoginController loginController = LoginController();

  //FirebaseUser _firebaseUser;
  //User _user;
  var _user;
  String error;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = Provider.of<Muser>(context, listen: false);
    //fb = FutureBuilder()
  }

  Scaffold buildNextPage() {
    return Scaffold(
      body: Container(child: PickDay()),
    );
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

  Future<void> _onActionTapped({BuildContext context, Muser user}) async {
    await FirebaseAuthUi.instance().launchAuth([
      AuthProvider.email(),
      //AuthProvider.google(),
      //AuthProvider.twitter(),
      AuthProvider.phone(), // kind of silly on a phone though?
    ]).then((firebaseUser) {
      user.firebaseUser = firebaseUser;
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
