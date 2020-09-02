import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
//import 'package:home_gym/controllers/controllers.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  @override
  ProfileViewState createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
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
              Consumer<Muser>(
                builder: (context, user, child) {
                  return
                      //Expanded(
//                    flex: 1,
                      //child:
                      Column(
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
                          Text(
                              "Here is all the information we have about your identity, granted to us by how you logged in: "),
                          SizedBox(height: 35),
                          //Image.asset("assets/images/pos_icon.png"),
                          Text("Name: ${user.getDisplayName()}"),
                          SizedBox(height: 10),
                          Text("Email: ${user.firebaseUser.email}"),
                          SizedBox(height: 10),
                          Text(
                              "Are you a new user: ${user.firebaseUser.isNewUser.toString()}"),
                          SizedBox(height: 10),
                          Text(
                              "Your phone number: ${user.firebaseUser.phoneNumber}"),
                          SizedBox(height: 10),
                          Text("Your user ID: ${user.firebaseUser.uid}"),
                          SizedBox(height: 10),
                          Text(
                              "Are you an anonymous user: ${user.firebaseUser.isAnonymous.toString()}"),
                          SizedBox(height: 10),
                          Text(
                              "Account creation date: ${user.firebaseUser.metaData.creationTimestamp.toString()}"),
                          SizedBox(height: 10),
                          Text(
                              "Last sign in date: ${user.firebaseUser.metaData.lastSignInTimestamp.toString()}"),
                        ],
                      ),
                    ],
                    //trailing: ,
                    //),
                  );
                },
              ),
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
              FlatButton(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(15),
                  height: 50,
                  width: 150,
                  color: Colors.blueGrey[200],
                  child: Text("Delete Account"),
                ),
                onPressed: () {
                  print("pressed for deletion!");
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
            ],
          ),
        ],
      ),
    );
  }
}
