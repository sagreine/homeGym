import 'package:flutter/material.dart';
import 'package:home_gym/views/views.dart';

class PickDay extends StatefulWidget {
  @override
  _PickDayState createState() => _PickDayState();
}

class _PickDayState extends State<PickDay> {
  bool isPickedTest = false;
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
              crossAxisSpacing: 2,
              crossAxisCount: 2,
              children: [
                RaisedButton(
                  onPressed: () {
                    isPickedTest = !isPickedTest;
                    setState(() {});
                  },
                  padding: const EdgeInsets.all(0.0),
                  elevation: 4,
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: isPickedTest
                          ? LinearGradient(
                              colors: <Color>[
                                Color(0xFF0D47A1),
                                Color(0xFF1976D2),
                                Color(0xFF42A5F5),
                              ],
                            )
                          : LinearGradient(
                              colors: <Color>[
                                Color(0xFF42A5F5),
                                Color(0xFF1976D2),
                                Color(0xFF0D47A1),
                              ],
                            ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      width: 400,
                      height: 400,
                      decoration: const BoxDecoration(),
                      padding: const EdgeInsets.all(10.0),
                      child:
                          const Text('Squat', style: TextStyle(fontSize: 50)),
                    ),
                  ),
//                  splashColor: Colors.yellow[200],
//                  animationDuration: Duration(seconds: 2),
                ),

                //splashColor: Colors.yellow[200],
                //padding: const EdgeInsets.all(0.0),
                AnimatedContainer(
                  color: isPickedTest ? Colors.blue : Colors.yellow[200],
                  duration: Duration(milliseconds: 300),

                  width: 400,
                  height: 400,
                  //padding: const EdgeInsets.all(10.0),

                  child: InkWell(
                    onTap: () {
                      isPickedTest = !isPickedTest;
                      setState(() {});
                    },
                    splashColor:
                        !isPickedTest ? Colors.blue : Colors.yellow[200],
                    child:
                        const Text('Deadlift', style: TextStyle(fontSize: 50)),
                  ),
                ),

//
                RaisedButton(
                  onPressed: () {
                    isPickedTest = !isPickedTest;
                    setState(() {});
                  },
                  animationDuration: Duration(seconds: 2),
                  autofocus: true,
                  clipBehavior: Clip.none,
                  splashColor: isPickedTest ? Colors.blue : Colors.yellow[200],
                  elevation: isPickedTest ? 2 : 4,
                  shape:
                      isPickedTest ? CircleBorder() : BeveledRectangleBorder(),
                  color: isPickedTest ? Colors.blue : Colors.yellow[200],
                  child: Text(
                    "Bench",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
                AnimatedContainer(
                  color: isPickedTest ? Colors.blue : Colors.yellow[200],
                  duration: Duration(milliseconds: 300),

                  width: 400,
                  height: 400,
                  //padding: const EdgeInsets.all(10.0),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () {
                        isPickedTest = !isPickedTest;
                        setState(() {});
                      },
                      splashColor:
                          !isPickedTest ? Colors.blue : Colors.yellow[200],
                      child: const Text('Deadlift',
                          style: TextStyle(fontSize: 50)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
