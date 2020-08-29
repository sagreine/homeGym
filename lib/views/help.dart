import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_gym/controllers/settings.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:provider/provider.dart';

class HelpView extends StatefulWidget {
  @override
  HelpViewState createState() => HelpViewState();
}

class HelpViewState extends State<HelpView> {
  //SettingsController settingsController = SettingsController();
  // should these go in the Settingscontroller probably then...

  @override
  void dispose() {
    // TODO: implement dispose for controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Gym TV')),
      body: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Help Page"),
              Divider(
                height: 10,
                thickness: 8,
                color: Colors.blueGrey,
                indent: 20,
                endIndent: 20,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 8),
              ),
              Text(
                "Instructional Screens",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Text(
                  "When you opened the app for the very first time you were shown these screens. Click to show them again",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              FlatButton(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(15),
                  height: 50,
                  width: 150,
                  color: Colors.blueGrey[200],
                  child: Text("See Instructions"),
                ),
                onPressed: () {
                  print("pressed for help!");
                  /*Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) {
                                  return Scaffold(
                                      body: Container(child: IntroScreen()));
                                },
                              ),
                            );*/
                },
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                  "Refer to www.example.com for user manual with further instructions"),
            ],
          ),
        ],
      ),
    );
  }
}
