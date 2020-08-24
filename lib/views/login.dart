import 'package:firebase_auth_ui/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_gym/views/pick_day.dart';
import 'package:home_gym/controllers/controllers.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  LoginController loginController = LoginController();

  FirebaseUser _user;
  String _error = '';
  @override
  Widget build(BuildContext context) {
    //Navigator.of(context).pushReplacement(
    //MaterialPageRoute<void>(builder: (BuildContext context) {
    _onActionTapped();
    return Scaffold(
      body: Container(child: PickDay()),
      /*Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getMessage(),
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: RaisedButton(
                child: Text(_user != null ? 'Logout' : 'Login'),
                onPressed: _onActionTapped,
              ),
            ),
            _getErrorText(),
            _user != null
                ? FlatButton(
                    child: Text('Delete Account'),
                    textColor: Colors.red,
                    onPressed: () => _deleteUser(),
                  )
                : Container()
          ],
        ),
      ),*/
    );
  }

  Widget _getMessage() {
    if (_user != null) {
      return Text(
        'Logged in user is: ${_user.displayName ?? ''}',
        style: TextStyle(
          fontSize: 16,
        ),
      );
    } else {
      return Text(
        'Tap the below button to Login',
        style: TextStyle(
          fontSize: 16,
        ),
      );
    }
  }

  Widget _getErrorText() {
    if (_error?.isNotEmpty == true) {
      return Text(
        _error,
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 16,
        ),
      );
    } else {
      return Container();
    }
  }

  // would delete all other associated data first...
  void _deleteUser() async {
    final result = await FirebaseAuthUi.instance().delete();
    if (result) {
      setState(() {
        _user = null;
      });
    }
  }

  void _onActionTapped() {
    if (_user == null) {
      // User is null, initiate auth
      FirebaseAuthUi.instance().launchAuth([
        AuthProvider.email(),
        // Google ,facebook, twitter and phone auth providers are commented because this example
        // isn't configured to enable them. Please follow the README and uncomment
        // them if you want to integrate them in your project.

        AuthProvider.google(),
        //AuthProvider.facebook(),
        //AuthProvider.twitter(),
        AuthProvider.phone(),
      ]).then((firebaseUser) {
        //setState(() {
        _error = "";
        _user = firebaseUser;
        loginController.getMaxes(context);
        loginController.getBarWeight(context);
        loginController.getPlates(context);
        /*Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (BuildContext context) => PickDay()));*/
        //});
      }).catchError((error) {
        if (error is PlatformException) {
          setState(() {
            if (error.code == FirebaseAuthUi.kUserCancelledError) {
              _error = "User cancelled login";
            } else {
              _error = error.message ?? "Unknown error!";
            }
          });
        }
      });
    } else {
      // User is already logged in, logout!
      _logout();
    }
  }

  void _logout() async {
    await FirebaseAuthUi.instance().logout();
    setState(() {
      _user = null;
    });
  }
}
