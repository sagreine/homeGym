import 'package:flutter/material.dart';
import 'package:home_gym/controllers/controllers.dart';
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
    String newRouteName;

    return Consumer<Muser>(builder: (context, user, child) {
      return Drawer(
        child: Column(children: [
          DrawerHeader(
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    //color: Colors.blueGrey[200],
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
                            InkWell(
                              child: Text(
                                "View Profile",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              onTap: () {
                                newRouteName = "/profile";
                                // if the current route is the exact location we're at (first on the stack), mark that
                                Navigator.popUntil(context, (route) {
                                  if (route.settings.name == newRouteName) {
                                    isNewRouteSameAsCurrent = true;
                                  } else {
                                    isNewRouteSameAsCurrent = false;
                                  }
                                  return true;
                                });
                                // if it isn't, go to the new route
                                if (!isNewRouteSameAsCurrent) {
                                  Navigator.pushNamed(context, newRouteName);
                                }
                                // again if it is, just pop the drawer away
                                else {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                      //trailing: ,
                    ),
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
                    newRouteName = "/pick_day";
                    // if the current route is the exact location we're at (first on the stack), mark that
                    Navigator.popUntil(context, (route) {
                      if (route.settings.name == newRouteName) {
                        isNewRouteSameAsCurrent = true;
                      } else {
                        isNewRouteSameAsCurrent = false;
                      }
                      return true;
                    });
                    // if it isn't, go to the new route
                    if (!isNewRouteSameAsCurrent) {
                      Navigator.pushNamed(context, newRouteName);
                    }
                    // again if it is, just pop the drawer away
                    else {
                      Navigator.pop(context);
                    }
                  }),
              ListTile(
                  title: Text("Do Lift"),
                  leading: Icon(Icons.directions_run),
                  // typical is icons, and need a similar iimage for all (image is bigger than icon) but to think about
                  //leading: Image.asset("assets/images/pos_icon.png"),
                  onTap: () {
                    newRouteName = "/do_lift";
                    // if the current route is the exact location we're at (first on the stack), mark that
                    Navigator.popUntil(context, (route) {
                      if (route.settings.name == newRouteName) {
                        isNewRouteSameAsCurrent = true;
                      } else {
                        isNewRouteSameAsCurrent = false;
                      }
                      return true;
                    });
                    // if it isn't, go to the new route
                    if (!isNewRouteSameAsCurrent) {
                      Navigator.pushNamed(context, newRouteName);
                    }
                    // again if it is, just pop the drawer away
                    else {
                      Navigator.pop(context);
                    }
                  }),
              ListTile(
                  title: Text("My Weights"),
                  leading: Icon(Icons.filter_list),
                  onTap: () {
                    newRouteName = "/lifter_weights";
                    // if the current route is the exact location we're at (first on the stack), mark that
                    Navigator.popUntil(context, (route) {
                      if (route.settings.name == newRouteName) {
                        isNewRouteSameAsCurrent = true;
                      } else {
                        isNewRouteSameAsCurrent = false;
                      }
                      return true;
                    });
                    // if it isn't, go to the new route
                    if (!isNewRouteSameAsCurrent) {
                      Navigator.pushNamed(context, newRouteName);
                    }
                    // again if it is, just pop the drawer away
                    else {
                      Navigator.pop(context);
                    }
                  }),
              ListTile(
                  title: Text("My Maxes"),
                  //leading: Icon(Icons.description),
                  leading: Icon(Icons.format_list_bulleted),
                  onTap: () {
                    newRouteName = "/lifter_maxes";
                    // if the current route is the exact location we're at (first on the stack), mark that
                    Navigator.popUntil(context, (route) {
                      if (route.settings.name == newRouteName) {
                        isNewRouteSameAsCurrent = true;
                      } else {
                        isNewRouteSameAsCurrent = false;
                      }
                      return true;
                    });
                    // if it isn't, go to the new route
                    if (!isNewRouteSameAsCurrent) {
                      Navigator.pushNamed(context, newRouteName);
                    }
                    // again if it is, just pop the drawer away
                    else {
                      Navigator.pop(context);
                    }
                  }),
              ListTile(
                  title: Text("Help"),
                  leading: Icon(Icons.help),
                  onTap: () {
                    newRouteName = "/help";
                    // if the current route is the exact location we're at (first on the stack), mark that
                    Navigator.popUntil(context, (route) {
                      if (route.settings.name == newRouteName) {
                        isNewRouteSameAsCurrent = true;
                      } else {
                        isNewRouteSameAsCurrent = false;
                      }
                      return true;
                    });
                    // if it isn't, go to the new route
                    if (!isNewRouteSameAsCurrent) {
                      Navigator.pushNamed(context, newRouteName);
                    }
                    // again if it is, just pop the drawer away
                    else {
                      Navigator.pop(context);
                    }
                  }),
              ListTile(
                title: Text("Settings"),
                leading: Icon(Icons.settings),
                onTap: () {
                  newRouteName = "/settings";
                  // if the current route is the exact location we're at (first on the stack), mark that
                  Navigator.popUntil(context, (route) {
                    if (route.settings.name == newRouteName) {
                      isNewRouteSameAsCurrent = true;
                    } else {
                      isNewRouteSameAsCurrent = false;
                    }
                    return true;
                  });
                  // if it isn't, go to the new route
                  if (!isNewRouteSameAsCurrent) {
                    Navigator.pushNamed(context, newRouteName);
                  }
                  // again if it is, just pop the drawer away
                  else {
                    Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                title: Text("Log Out"),
                leading: Icon(Icons.exit_to_app),
                onTap: () async {
                  //Navigator.of(context).pop();
                  // wait while we log the user out.
                  await user.logout();
                  // pop until we get to the login page
                  Navigator.popUntil(context, ModalRoute.withName("/login"));
                },
              ),
            ]),
          ),
        ]),
      );
    });
  }
}
