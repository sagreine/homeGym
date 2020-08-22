import 'package:flutter/material.dart';
import 'package:home_gym/views/views.dart';

class PickDay extends StatefulWidget {
  @override
  _PickDayState createState() => _PickDayState();
}

class _PickDayState extends State<PickDay> {
  List<String> exercises = ["Squat", "Deadlift", "Bench", "Press"];
  List<bool> selectedExercise = [false, false, false, false];

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
            SizedBox(
              height: 20,
              child: Text("Select an exercise for today"),
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
                      gradient: selectedExercise[index]
                          ? LinearGradient(
                              colors: <Color>[
                                Color(0xFF0D47A1),
                                Color(0xFF1976D2),
                                Color(0xFF42A5F5),
                              ],
                            )
                          : LinearGradient(
                              colors: <Color>[
                                Color(0xFF058f43),
                                Color(0xFF06ac51),
                                Color(0xFF1bcc50),
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
                              if (selectedExercise[index]) {
                                selectedExercise[index] = false;
                              } else {
                                selectedExercise
                                    .setAll(0, [false, false, false, false]);
                                selectedExercise[index] = true;
                              }
                            });
                          },
                          splashColor: !selectedExercise[index]
                              ? Color(0xFF1976D2)
                              : Color(0xFF06ac51),
                          child: SizedBox(
                            width: 400,
                            height: 400,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(exercises[index].toString(),
                                      style: TextStyle(fontSize: 50)),
                                ]),
                          )),
                    ),
                  );
                }),
              ),
            ),
          ],
        ));
  }
}
