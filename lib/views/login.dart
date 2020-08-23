import 'package:flutter/material.dart';
import 'package:home_gym/views/pick_day.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  LoginController loginController = LoginController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // for now, just send them to the pick day page.
      body: RaisedButton(
          onPressed: () {
            loginController.getMaxes(context);
            loginController.getBarWeight(context);
            loginController.getPlates(context);
            Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (BuildContext context) => PickDay()));
          },
          child: Text("Login page")),
    );
  }
}
