import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/views/views.dart';
import 'package:provider/provider.dart';

class LifterMaxesView extends StatefulWidget {
  @override
  LifterMaxesViewState createState() => LifterMaxesViewState();
}

class LifterMaxesViewState extends State<LifterMaxesView> {
  //SettingsController settingsController = SettingsController();
  // should these go in the Settingscontroller probably then...
  LifterMaxesController lifterMaxesController = LifterMaxesController();

  @override
  void dispose() {
    // TODO: implement dispose for controllers
    super.dispose();
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
          //validator: numberValidator,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly
          ],
          onFieldSubmitted: (val) {
            lifterMaxesController.update1RepMax(
                progression: false,
                context: context,
                lift: lift,
                newMax: int.parse(val),
                updateCloud: true);
          },
        ),
        showEditIcon: true);
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
                  "Your One Rep Maxes",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // this is not yet 'controlled' of course and doesn't use real data yet.
                Consumer<LifterMaxes>(
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
                          DataCell(
                              Text('Deadlift', style: TextStyle(fontSize: 14))),
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
              ]),
        ],
      ),
    );
  }
}
