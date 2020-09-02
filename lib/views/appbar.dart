import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:provider/provider.dart';

class ReusableWidgets {
  static getAppBar() {
    return AppBar(
      title: Text("Home Gym TV"),
    );
  }

  static getDrawer(BuildContext context) {
    bool isNewRouteSameAsCurrent = false;
    final newRouteName = "/NewRoute";
    final currentRoutename = ModalRoute.of(context)?.settings?.name;

    return Consumer<Muser>(builder: (context, user, child) {
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
                              Navigator.popUntil(context, (route) {
                                if (route.settings.name == newRouteName) {
                                  isNewRouteSameAsCurrent = true;
                                }
                                return true;
                              });

                              if (!isNewRouteSameAsCurrent) {
                                Navigator.pushNamed(context, newRouteName);
                              }

/*
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        ProfileView()),
                              );*/
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
                          builder: (BuildContext context) => PickDayView()),
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
                        builder: (BuildContext context) => DoLiftView()));
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
                          builder: (BuildContext context) => LifterMaxesView()),
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
                        builder: (BuildContext context) => SettingsView()),
                  );
                },
              ),
              ListTile(
                title: Text("Log Out"),
                leading: Icon(Icons.exit_to_app),
                onTap: () async {
                  Navigator.of(context).pop();
                  await user.logout();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) => LoginView()),
                  );
                },
              ),
            ]),
          ),
        ]),
      );
    });
  }
}
