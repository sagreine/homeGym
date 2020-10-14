import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

class ReusableWidgets {
  static getAppBar({TabController tabController, List<Tab> tabs}) {
    return AppBar(
      title: Text("Home Gym TV"),
      bottom: tabController == null
          ? null
          : new TabBar(
              controller: tabController,
              tabs: tabs,
            ),
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
                          backgroundColor:
                              Color(0xFFCB8421), //Colors.brown.shade800,
                          backgroundImage: user.firebaseUser.photoUri.isEmpty
                              ? AssetImage("assets/images/pos_icon.png")
                              : NetworkImage(user.getPhotoURL()),
                        ),
                        SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                  // TODO: this is yet messed up because login doesn't route to pick_day it builds it's own.... so breaks if we do this the first time through.
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
                    newRouteName = "/today";
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
                  // rotate this icon
                  leading: RotatedBox(
                      //alignment: Alignment.center,
                      //transform: Matrix4.rotationX(pi),
                      quarterTurns: 3,
                      child: Icon(Icons.filter_list)),
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
                  title: Text("My Videos"),
                  //leading: Icon(Icons.description),
                  leading: Icon(Icons.video_library),
                  onTap: () {
                    newRouteName = "/lifter_videos";
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
                  title: Text("Check Form Picture"),
                  //leading: Icon(Icons.description),
                  leading: Icon(Icons.video_library),
                  onTap: () {
                    newRouteName = "/form_check";
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
                  title: Text("Check Form Video"),
                  //leading: Icon(Icons.description),
                  leading: Icon(Icons.video_library),
                  onTap: () {
                    newRouteName = "/form_check_copy";
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
                  // wait while we log the user out.
                  await user.logout();
                  var exerciseDay =
                      Provider.of<ExerciseDay>(context, listen: false);
                  exerciseDay.lift = null;
                  print("successfully logged out");
                  // pop until we get to the login page
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login', (Route<dynamic> route) => false);
                },
              ),
            ]),
          ),
        ]),
      );
    });
  }
}
