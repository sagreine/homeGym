import 'package:flutter/material.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/views/views.dart';

class PickDay extends StatefulWidget {
  @override
  _PickDayState createState() => _PickDayState();
}

class _PickDayState extends State<PickDay> {
  PickDayController pickDayController = PickDayController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Home Gym TV"),
          leading: Padding(
            padding: EdgeInsets.all(3),
            child: Image.asset("assets/images/pos_icon.png"),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) => Settings()),
                );
              },
            ),
          ],
        ),
        body: ListView(
          children: [
            //TODO: this breaks the listview, even if it conveniently centers everything in just one line.
            // so need to put columns withhin, not at the top :(
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 28,
                  child:
                      Text("Select Exercise", style: TextStyle(fontSize: 24)),
                ),
                SizedBox(
                  height: 400,
                  child: GridView.count(
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    crossAxisCount: 2,
                    children: List.generate(4, (index) {
                      return AnimatedContainer(
                        decoration: BoxDecoration(
                          gradient: pickDayController.selectedExercise[index]
                              ? LinearGradient(
                                  colors: <Color>[
                                    Color(0xFF0D47A1),
                                    Color(0xFF1976D2),
                                    Color(0xFF0D47A1),
                                    //Color(0xFF42A5F5),
                                  ],
                                )
                              : LinearGradient(
                                  colors: <Color>[
                                    Color(0xFF058f43),
                                    Color(0xFF06ac51),
                                    Color(0xFF058f43),
                                    //Color(0xFF1bcc50),
                                  ],
                                ),
                        ),
                        //color: isPickedTest ? Colors.blue : Colors.yellow[200],
                        duration: Duration(milliseconds: 300),
                        width: 400,
                        height: 400,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(0),
                        // this isn't a great idea. allows splash, but doing it this way makes things harder to work with
                        // e.g. you need the sized box below because alignment: up above would otherwise shrink this to the
                        // size of the text box...
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                              onTap: () {
                                // this is lazy and bad.
                                setState(() {
                                  if (pickDayController
                                      .selectedExercise[index]) {
                                    pickDayController.selectedExercise[index] =
                                        false;
                                  } else {
                                    pickDayController.selectedExercise.setAll(
                                        0, [false, false, false, false]);
                                    pickDayController.selectedExercise[index] =
                                        true;
                                  }
                                });
                              },
                              splashColor:
                                  !pickDayController.selectedExercise[index]
                                      ? Color(0xFF1976D2)
                                      : Color(0xFF06ac51),
                              child: SizedBox(
                                width: 400,
                                height: 400,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                          pickDayController.exercises[index]
                                              .toString(),
                                          style: TextStyle(fontSize: 50)),
                                    ]),
                              )),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 80,
                  width: 380,
                  child: TextFormField(
                    controller: pickDayController.programController,
                    decoration: new InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF06ac51),
                          width: 1.0,
                          style: BorderStyle.solid,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF1976D2), width: 1.0),
                      ),
                      labelText: "Select Program",
                    ),
                    readOnly: true,
                    style: TextStyle(fontSize: 50),
                    onTap: () {
                      pickDayController.pickProgram(context);
                    },
                  ),
                ),
                SizedBox(height: 10),
                RaisedButton(
                  child: Text("Go!", style: TextStyle(fontSize: 50)),
                  onPressed: !pickDayController.readyToGo
                      ? null
                      : () => print("ready to go"),
                  disabledColor: Color(0xFF06ac51),
                  color: Color(0xFF1976D2),
                )
              ],
            ),
          ],
        ));
  }
}
