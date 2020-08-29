import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/controllers/controllers.dart';
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
    return null;
  }

  //SettingsController settingsController = SettingsController();
  LifterWeightsController lifterWeightsController = LifterWeightsController();

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
                    lifterWeightsController.barWeightTextController.text =
                        lifterweights.barWeight != null
                            ? lifterweights.barWeight.toString()
                            : "";
                    return Column(children: <Widget>[
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
                        controller:
                            lifterWeightsController.barWeightTextController,
                        onSubmitted: (String value) {
                          lifterWeightsController.updateBarWeight(
                              context, double.parse(value));
                        },
                      ),
                      Text(
                        "Your plates",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      // this is unnecessary since it is already done above...
                      // this is not yet 'controlled' of course and doesn't use real data yet.
                      DataTable(
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
                                          DataCell(Text("$plate",
                                              style: TextStyle(fontSize: 14))),
                                          // the count of how many we have of that plate
                                          DataCell(
                                              TextFormField(
                                                initialValue: lifterweights
                                                    .plates[plate]
                                                    .toString(),
                                                style: TextStyle(fontSize: 14),
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                  signed: false,
                                                  decimal: false,
                                                ),
                                                validator: numberValidator,
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  WhitelistingTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                onFieldSubmitted: (val) {
                                                  lifterWeightsController
                                                      .updatePlate(
                                                          context: context,
                                                          plate: plate,
                                                          plateCount:
                                                              int.parse(val));
                                                },
                                              ),
                                              showEditIcon: true),
                                        ],
                                      ))
                                  .toList())
                    ]);
                  },
                ),
              ])
        ],
      ),
    );
  }
}
