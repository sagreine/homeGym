import 'package:flutter/material.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/views/views.dart';

class PickDayView extends StatefulWidget {
  @override
  _PickDayViewState createState() => _PickDayViewState();
}

class _PickDayViewState extends State<PickDayView> {
  PickDayController pickDayController = PickDayController();

  @override
  Widget build(BuildContext context) {
    /*List<int> items = [2, 3, 5];
    List<int> itemscount = [2, 2, 2];
    print("for value 1");
    print(changeLimitedCoins.knapsack(items, itemscount, 1));
    print("for value 2");
    print(changeLimitedCoins.knapsack(items, itemscount, 2));
    print("for value 3");
    print(changeLimitedCoins.knapsack(items, itemscount, 3));
    print("for value 4");
    print(changeLimitedCoins.knapsack(items, itemscount, 4));
    print("for value 5");
    print(changeLimitedCoins.knapsack(items, itemscount, 5));
    print("for value 6");
    print(changeLimitedCoins.knapsack(items, itemscount, 6));
    print("for value 7");
    print(changeLimitedCoins.knapsack(items, itemscount, 7));
    print("for value 8");
    print(changeLimitedCoins.knapsack(items, itemscount, 8));
    print("for value 9");
    print(changeLimitedCoins.knapsack(items, itemscount, 9));
    print("for value 10");
    print(changeLimitedCoins.knapsack(items, itemscount, 10));
    print("for value 11");
    print(changeLimitedCoins.knapsack(items, itemscount, 11));
    print("for value 12");
    print(changeLimitedCoins.knapsack(items, itemscount, 12));
    print("for value 13");
    print(changeLimitedCoins.knapsack(items, itemscount, 13));
    print("for value 14");
    print(changeLimitedCoins.knapsack(items, itemscount, 14));
    print("for value 15");
    print(changeLimitedCoins.knapsack(items, itemscount, 15));
    print("for value 16");
    print(changeLimitedCoins.knapsack(items, itemscount, 16));
    print("for value 17");
    print(changeLimitedCoins.knapsack(items, itemscount, 17));
    print("for value 18");
    print(changeLimitedCoins.knapsack(items, itemscount, 18));
    print("for value 19");
    print(changeLimitedCoins.knapsack(items, itemscount, 19));
    print("for value 20");
    print(changeLimitedCoins.knapsack(items, itemscount, 20));
    print("for value 21");
    print(changeLimitedCoins.knapsack(items, itemscount, 21));
    print("for value 22");
    print(changeLimitedCoins.knapsack(items, itemscount, 22));
    print("for value 23");
    print(changeLimitedCoins.knapsack(items, itemscount, 23));
    print("for value 24");
    print(changeLimitedCoins.knapsack(items, itemscount, 24));*/

    //print(user.firebaseUser.displayName);
    return Scaffold(
        appBar: ReusableWidgets.getAppBar(),
        drawer: ReusableWidgets.getDrawer(context),
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
                          gradient: !pickDayController.selectedExercise[index]
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
                                  pickDayController.pickExercise(index);
                                });
                              },
                              splashColor:
                                  !pickDayController.selectedExercise[index]
                                      ? Color(0xFF06ac51)
                                      : Color(0xFF1976D2),
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
                  height: 120,
                  width: 380,
                  child: TextFormField(
                    controller: pickDayController.programController,
                    decoration: new InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF1976D2),
                          width: 1.0,
                          style: BorderStyle.solid,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF06ac51), width: 1.0),
                      ),
                      labelText: "Select Program",
                    ),
                    readOnly: true,
                    style: TextStyle(fontSize: 50),
                    onTap: () async {
                      await pickDayController.pickProgram(context);
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(height: 10),
                RaisedButton(
                  child: Text("Go!", style: TextStyle(fontSize: 50)),
                  onPressed: !pickDayController.readyToGo
                      ? null
                      : () => pickDayController.launchDay(context),
                  disabledColor: Color(0xFF1976D2),
                  color: Color(0xFF06ac51),
                )
              ],
            ),
          ],
        ));
  }
}
