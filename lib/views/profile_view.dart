import 'package:flutter/material.dart';
import 'package:home_gym/controllers/profile.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
//import 'package:home_gym/controllers/controllers.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileView extends StatefulWidget {
  @override
  ProfileViewState createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  //SettingsController settingsController = SettingsController();
  // should these go in the Settingscontroller probably then...

  ProfileController profileController = ProfileController();

  @override
  void dispose() {
    // TODO: implement dispose for controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(),
      drawer: ReusableWidgets.getDrawer(context),
      body: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Your Profile"),
              Consumer<Muser>(builder: (context, user, child) {
                return
                    //Expanded(
//                    flex: 1,
                    //child:
                    Column(children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.brown.shade800,
                    backgroundImage: user.fAuthUser.photoURL == null ||
                            user.fAuthUser.photoURL.isEmpty
                        ? AssetImage("assets/images/pos_icon.png")
                        : NetworkImage(user.getPhotoURL()),
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Text(
                          "Here is all the information we have about your identity, granted to us by how you logged in. We don't keep or use anything else"
                          " aside from your workout logs and videos, which we only share with you."),
                      SizedBox(height: 35),
                      //Image.asset("assets/images/pos_icon.png"),
                      Text("Name: ${user.getDisplayName()}"),
                      SizedBox(height: 10),
                      Text("Email: ${user.fAuthUser.email}"),
                      SizedBox(height: 10),
                      Text(
                          "Are you a new user: ${user.isNewUser == true ? "Yep" : "Nope"}"),
                      SizedBox(height: 10),
                      Text("Your phone number: ${user.fAuthUser.phoneNumber}"),
                      SizedBox(height: 10),
                      Text("Your user ID: ${user.fAuthUser.uid}"),
                      SizedBox(height: 10),
                      Text(
                          "Are you an anonymous user: ${user.fAuthUser.isAnonymous == true ? "Yep" : "Nope"}"),
                      SizedBox(height: 10),
                      Text(user.fAuthUser == null
                          ? "Not sure when you created your account!"
                          : "Account creation date: ${timeago.format(user.fAuthUser.metadata.creationTime)}"),
                      SizedBox(height: 10),
                      Text(user.fAuthUser == null
                          ? "Not sure when you last signed in!"
                          : "Last sign in date: ${timeago.format(user.fAuthUser.metadata.lastSignInTime)}"),
                    ],
                  ),

                  //trailing: ,
                  //),

                  // ),

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
                    "Delete Profile",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child: Text(
                      "This is permanent and deletes all data associated with your account. We'll email you afterwards with confirmation.",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  RaisedButton(
                    child: Text("Delete Account"),
                    padding: EdgeInsets.all(8.0),
                    onPressed: () async {
                      // lol cmon now....
                      if (!await profileController.deleteUser(
                          context: context)) {
                        await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text(
                                    "We need you to sign in again first, then come back to this page"),
                                actions: [
                                  RaisedButton(
                                      child: Text("Ok"),
                                      onPressed: () async {
                                        await user.logout();
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                                '/login',
                                                (Route<dynamic> route) =>
                                                    false);
                                      }),
                                ],
                              );
                            });
                      }
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login', (Route<dynamic> route) => false);

                      //await user.logout();
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
                ]);
              }),
            ],
          ),
        ],
      ),
    );
  }
}
