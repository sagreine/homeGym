import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_gym/controllers/settings.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  SettingsController settingsController = SettingsController();
  // should these go in the Settingscontroller probably then...

  @override
  void dispose() {
    // TODO: implement dispose for controllers
    super.dispose();
  }

  String numberValidator(String value) {
    if (value == null) {
      return null;
    }
    final n = num.tryParse(value);
    if (n == null) {
      return '"$value" is not a valid number';
    }
    return null;
  }

  DataCell _buildMaxValues(String initialMax, String lift) {
    return DataCell(
        TextFormField(
          initialValue: initialMax,
          style: TextStyle(fontSize: 14),
          keyboardType: TextInputType.numberWithOptions(
            signed: false,
            decimal: false,
          ),
          validator: numberValidator,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly
          ],
          onFieldSubmitted: (val) {
            settingsController.update1RepMax(
                context: context, lift: lift, newMax: int.parse(val));
          },
        ),
        showEditIcon: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Gym TV')),
      body: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Your weight collection",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "Bar weight",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Text(
                  "This is used in calculating how much weight to add ",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              // need to use controller
              Consumer<LifterWeights>(builder: (context, lifterweights, child) {
                settingsController.barWeightTextController.text =
                    lifterweights.barWeight != null
                        ? lifterweights.barWeight.toString()
                        : "";
                return Column(
                  children: <Widget>[
                    TextField(
                      decoration: new InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.greenAccent,
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blueGrey, width: 1.0),
                        ),
                        labelText: lifterweights.barWeight == null
                            ? "Enter Your Bar's weight"
                            : "Edit Your Bar's weight",
                      ),
                      //_allowedSore.toString()),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                      ],
                      controller: settingsController.barWeightTextController,
                      onSubmitted: (String value) {
                        settingsController.lifterWeightsController
                            .updateBarWeight(context, double.parse(value));
                      },
                    ),
                    Text(
                      "Your plates",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    // this is unnecessary since it is already done above...
                    Consumer<LifterWeights>(
                      builder: (context, lifterweights, child) {
                        List<double> platesAsList;
                        if (lifterweights.plates != null) {
                          platesAsList =
                              new List.from(lifterweights.plates.keys.toList());
                          platesAsList.sort((b, a) => a.compareTo(b));
                        }

                        return
                            // this is not yet 'controlled' of course and doesn't use real data yet.
                            DataTable(
                                sortColumnIndex: 0,
                                sortAscending: true,
                                columns: [
                                  DataColumn(
                                      label: Text('Weight'), numeric: true),
                                  DataColumn(
                                      label: Text('# Plates'), numeric: true),
                                ],
                                // will build rows dynamically here, so no error checking up front.
                                // will deprecate this for now in favor of hardcoded plates (customizable counts).
                                // don't have to let them add new, don't have to let them customize the weight..
                                rows: lifterweights.plates == null
                                    ? [
                                        DataRow(cells: [
                                          DataCell(Text("add your plates!")),
                                          DataCell(
                                              Text("add your plates count!"))
                                        ])
                                      ]
                                    : platesAsList
                                        .map((
                                          plate,
                                        ) =>
                                            DataRow(
                                              cells: [
                                                // the weight of the plate (double)
                                                DataCell(Text("$plate",
                                                    style: TextStyle(
                                                        fontSize: 14))),
                                                // the count of how many we have of that plate
                                                DataCell(
                                                    TextFormField(
                                                      initialValue:
                                                          lifterweights
                                                              .plates[plate]
                                                              .toString(),
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                      keyboardType: TextInputType
                                                          .numberWithOptions(
                                                        signed: false,
                                                        decimal: false,
                                                      ),
                                                      validator:
                                                          numberValidator,
                                                      inputFormatters: <
                                                          TextInputFormatter>[
                                                        WhitelistingTextInputFormatter
                                                            .digitsOnly
                                                      ],
                                                      onFieldSubmitted: (val) {
                                                        settingsController
                                                            .updatePlateCount(
                                                                context:
                                                                    context,
                                                                plate: plate,
                                                                newCount:
                                                                    int.parse(
                                                                        val));
                                                      },
                                                    ),
                                                    showEditIcon: true),
                                              ],
                                            ))
                                        .toList());
                      },
                    ),
                    Text(
                      "Your One Rep Maxes",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    // this is not yet 'controlled' of course and doesn't use real data yet.
                    Consumer<LiftMaxes>(
                      builder: (context, liftMaxes, child) {
                        return DataTable(
                          sortColumnIndex: 0,
                          sortAscending: true,
                          columns: [
                            DataColumn(label: Text('Lift'), numeric: true),
                            DataColumn(label: Text('Max'), numeric: true),
                          ],
                          rows: [
                            DataRow(selected: true, cells: [
                              DataCell(Text('Deadlift',
                                  style: TextStyle(fontSize: 14))),
                              _buildMaxValues(
                                  liftMaxes.deadliftMax.toString(), "deadlift"),
                            ]),
                            DataRow(cells: [
                              DataCell(
                                Text('Bench', style: TextStyle(fontSize: 14)),
                              ),
                              _buildMaxValues(
                                  liftMaxes.benchMax.toString(), "bench"),
                            ]),
                            DataRow(cells: [
                              DataCell(
                                Text('Squat', style: TextStyle(fontSize: 14)),
                              ),
                              _buildMaxValues(
                                  liftMaxes.squatMax.toString(), "squat"),
                            ]),
                            DataRow(cells: [
                              DataCell(
                                Text('Press', style: TextStyle(fontSize: 14)),
                              ),
                              _buildMaxValues(
                                  liftMaxes.pressMax.toString(), "press"),
                            ]),
                          ],
                        );
                      },
                    ),
                  ],
                );
              }),
              Divider(
                height: 10,
                thickness: 8,
                color: Colors.blueGrey,
                indent: 20,
                endIndent: 20,
              ),
              // let them rewatch onboarding from settings page
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  // expanded here says "take all the width of this row"
                  Expanded(
                    child: Container(
                      height: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 8),
                          ),
                          Text(
                            "Instructional Screens",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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
                              child: Text("See Instructions - not implemented"),
                            ),
                            onPressed: () {
                              print("pressed info!");
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                height: 10,
                thickness: 8,
                color: Colors.blueGrey,
                indent: 20,
                endIndent: 20,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 12, 0, 8),
                child: Text(
                  "Picking a Fling Device",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Consumer<FlingMediaModel>(
                builder: (context, flingy, child) {
                  return Column(children: <Widget>[
                    flingy.selectedPlayer == null
                        ? Text("Search, then pick a player by tapping on it")
                        : Text(
                            "Select Player State: ${flingy.selectedPlayer.name}"),
                    RaisedButton(
                        child: Text('Search'),
                        onPressed: () async {
                          await settingsController.flingController
                              .getCastDevices(context);
                        }),
                    RaisedButton(
                      child: Text('Dispose Controller'),
                      onPressed: () async {
                        settingsController.flingController.dispose(context);
                        //setState(() {});
                        // should be in controller - imagine using Cast instead of fling...
                      },
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: flingy.flingDevices == null
                          ? 0
                          : flingy.flingDevices.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title:
                              Text(flingy.flingDevices.elementAt(index).name),
                          subtitle:
                              Text(flingy.flingDevices.elementAt(index).uid),
                          onTap: () => {
                            settingsController.flingController.selectPlayer(
                                context, flingy.flingDevices.elementAt(index))
                          },
                        );
                      },
                    ),
                  ]);
                },
              ),
            ],
          ),
        ],
      ),
      /*floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Consumer<FlingMediaModel>(
            builder: (context, flingy, child) {
              return Column(
                children: <Widget>[],
              );
            },
          ),
        ],
      ),*/
    );
  }
}
