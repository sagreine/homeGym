import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/views/views.dart';
import 'package:provider/provider.dart';

class LifterWeightsView extends StatefulWidget {
  @override
  LifterWeightsViewState createState() => LifterWeightsViewState();
}

class LifterWeightsViewState extends State<LifterWeightsView> {
  // untested
  String numberValidator(String value) {
    if (value == null) {
      return null;
    }
    final n = num.tryParse(value);
    if (n == null) {
      return '"$value" is not a valid number';
    }
    if (!n.toInt().isEven) {
      return "$value is not even and you have to have even number of plates";
    }
    return null;
  }

  //SettingsController settingsController = SettingsController();
  LifterWeightsController lifterWeightsController = LifterWeightsController();

  _buildDataTable(
      {/*bool isKg,*/ List<double> platesAsList, LifterWeights lifterweights}) {
    //var _platesAsList = platesAsList.where((element) => (element/2.5).truncateToDouble() == element/2.5);
    // this is unnecessary since it is already done above...
    // this is not yet 'controlled' of course and doesn't use real data yet.
    return DataTable(
        sortColumnIndex: 0,
        sortAscending: true,
        columns: [
          DataColumn(label: Text('Weight'), numeric: true),
          DataColumn(label: Text('# Plates'), numeric: true),
        ],
        // will build rows dynamically here, so no error checking up front.
        // will deprecate this for now in favor of hardcoded plates (customizable counts).
        // don't have to let them add new, don't have to let them customize the weight..
        rows: lifterweights.plates == null
            ? [
                DataRow(cells: [
                  DataCell(Text("add your plates!")),
                  DataCell(Text("add your plates count!"))
                ])
              ]
            : platesAsList
                .map((
                  plate,
                ) =>
                    DataRow(
                      cells: [
                        // the weight of the plate (double)
                        DataCell(
                            Text("$plate", style: TextStyle(fontSize: 14))),
                        // the count of how many we have of that plate
                        DataCell(
                            TextFormField(
                              initialValue:
                                  lifterweights.plates[plate].toString(),
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
                                lifterWeightsController.updatePlate(
                                    context: context,
                                    plate: plate,
                                    plateCount: int.parse(val));
                              },
                            ),
                            showEditIcon: true),
                      ],
                    ))
                .toList());
  }

  _barWeightWidget(LifterWeights lifterweights, String lift) {
    var barweight;
    switch (lift) {
      case "Squat":
        barweight = lifterweights.squatBarWeight;
        break;
      case "Deadlift":
        barweight = lifterweights.deadliftBarWeight;
        break;
      case "Press":
        barweight = lifterweights.pressBarWeight;
        break;
      case "Bench":
        barweight = lifterweights.benchBarWeight;
        break;
      default:
    }

    return TextField(
      decoration: new InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.greenAccent,
            width: 1.0,
            style: BorderStyle.solid,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
        ),
        labelText: barweight == null
            ? "Enter Your $lift Bar's weight"
            : "Edit Your $lift Bar's weight",
      ),

      //_allowedSore.toString()),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
      ],
      controller: TextEditingController.fromValue(
          TextEditingValue(text: barweight.toString())),
      onSubmitted: (String value) {
        lifterWeightsController.updateBarWeight(
            context: context, newBarWeight: int.parse(value), lift: lift);
      },
    ); //..controller().text = barweight.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(),
      drawer: ReusableWidgets.getDrawer(context),
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
                Divider(
                  height: 10,
                  thickness: 8,
                  color: Colors.blueGrey,
                  indent: 20,
                  endIndent: 20,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Your Bar weights",
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
                Consumer<LifterWeights>(
                  builder: (context, lifterweights, child) {
                    // to order plates by weight (probably a better way)
                    List<double> platesAsList;
                    if (lifterweights.plates != null) {
                      platesAsList =
                          new List.from(lifterweights.plates.keys.toList());
                      platesAsList.sort((b, a) => a.compareTo(b));
                    }
// set the bar weight initially.
                    /*lifterWeightsController.barWeightTextController.text =
                        lifterweights.barWeight != null
                            ? lifterweights.barWeight.toString()
                            : "";*/
                    return Column(children: <Widget>[
                      _barWeightWidget(
                        lifterweights,
                        "Squat",
                      ),
                      SizedBox(height: 4),
                      _barWeightWidget(lifterweights, "Press"),
                      SizedBox(height: 4),
                      _barWeightWidget(lifterweights, "Deadlift"),
                      SizedBox(height: 4),
                      _barWeightWidget(lifterweights, "Bench"),
                      SizedBox(height: 12),
                      Divider(
                        height: 10,
                        thickness: 8,
                        color: Colors.blueGrey,
                        indent: 20,
                        endIndent: 20,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Your plates",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SwitchListTile.adaptive(
                        title: Text("Are these bumpers"),
                        secondary: lifterweights.bumpers
                            ? Icon(Icons.airline_seat_legroom_extra)
                            : Icon(Icons.airline_seat_legroom_reduced),
                        value: lifterweights.bumpers,
                        onChanged: (newValue) {
                          //
                          setState(() {
                            lifterWeightsController.updateBumpers(
                                context: context, bumpers: newValue);
                          });
                        },
                        controlAffinity: ListTileControlAffinity.platform,
                      ),
                      // split the kg and lb into separate tables to be easier to look at
                      Row(
                        children: [
                          _buildDataTable(
                            platesAsList: platesAsList
                                .where((element) =>
                                    (element / 2.5).truncateToDouble() ==
                                    element / 2.5)
                                .toList(),
                            lifterweights: lifterweights,
                          ),
                          _buildDataTable(
                            platesAsList: platesAsList
                                .where((element) =>
                                    (element / 2.5).truncateToDouble() !=
                                    element / 2.5)
                                .toList(),
                            lifterweights: lifterweights,
                          ),
                        ],
                      ),
                      Consumer<Muser>(
                        builder: (context, user, child) {
                          return Visibility(
                              visible: user.isNewUser,
                              child: RaisedButton(
                                  splashColor: Colors.green[600],
                                  elevation: 4,
                                  color: Colors.green[800],
                                  onPressed: () =>
                                      Navigator.pushNamed(context, "/pick_day"),
                                  child: Text("Now do a workout!")));
                        },
                      ),
                    ]);
                  },
                ),
              ])
        ],
      ),
    );
  }
}
