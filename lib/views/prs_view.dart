import 'dart:io';

import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
//import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/views/views.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:social_share_plugin/social_share_plugin.dart';

class PrsView extends StatefulWidget {
  @override
  PrsViewState createState() => PrsViewState();
}

class PrsViewState extends State<PrsView> {
  //PrsController _prsController = PrsController();
  int reps;
  int weight;
  String lift;
  List<DataRow> dr; // = List<DataRow>();
  List<Pr> thisLiftPrs;
  bool isScreenshotting =
      false; //- this doesn't work, obviously, because we rebuild in the middle of it
  ScreenshotController screenshotController = ScreenshotController();
  String quote;
  var prs;

  @override
  dispose() {
    super.dispose();
    //screenshotController.dispose();
  }

  @override
  initState() {
    super.initState();
    var currentDay = Provider.of<ExerciseDay>(context, listen: false);

    lift = currentDay.lift ?? "Squat";
    prs = Provider.of<Prs>(context, listen: false);
    if (prs.prs != null) {
      updateThisLifPrs(prs);
    }
    quote = Quotes().getQuote(greatnessQuote: true);
  }

  void updateThisLifPrs(Prs prs) {
    if (prs.prs != null) {
      thisLiftPrs = prs.prs.where((element) => element.lift == lift).toList();
    }
  }

  // this allows us to splash something on just for the screenshot
  doScreenshot(String path) async {
    setState(() {
      isScreenshotting = true;
    });
    //await Future.delayed(Duration(seconds: 1))
    await screenshotController
        .capture(path: path, delay: Duration(milliseconds: 20))
        .then((File image) async {
      await SocialSharePlugin.shareToFeedInstagram(path: image.path);
    });
    setState(() {
      isScreenshotting = false;
    });
  }

  _buildPRCells(List<Pr> prs) {
    dr = List<DataRow>();
    if (prs != null) {
      prs.where((element) => element.lift == lift).forEach((element) {
        //var prindex = prs.prs.indexOf(element);
        //prs[prindex];
        //dr.indexOf(]);

        //if(prs.prs[dr.indexOf(element)] != -1){
        dr.add(DataRow(cells: [
          DataCell(
              Text(
                "${element.reps.toString()}RM",
              ),
              showEditIcon: false),
          DataCell(
            Text(
              element.weight.toString(),
            ),
            showEditIcon: false,
          ),
          DataCell(
              Text(
                "${element.dateTime.day.toString()}/${element.dateTime.month.toString()}/${element.dateTime.year.toString()}",
              ),
              showEditIcon: false),
        ]));
      });
      //}
      //return dr;
    }
  }

  @override
  Widget build(BuildContext context) {
    _buildPRCells(thisLiftPrs);

    return Scaffold(
        appBar: ReusableWidgets.getAppBar(),
        drawer: ReusableWidgets.getDrawer(context),
        body: ListView(children: <Widget>[
          Column(children: <Widget>[
            Screenshot(
              controller: screenshotController,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Your Rep PRs",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton(
                        value: lift,
                        items: [
                          DropdownMenuItem(
                              child: Text("Squat"), value: "Squat"),
                          DropdownMenuItem(
                              child: Text("Press"), value: "Press"),
                          DropdownMenuItem(
                              child: Text("Deadlift"), value: "Deadlift"),
                          DropdownMenuItem(
                              child: Text("Bench"), value: "Bench"),
                        ],
                        onChanged: (value) {
                          setState(() {
                            lift = value;
                            updateThisLifPrs(prs);
                          });
                        }),
                    SizedBox(
                      height: 12,
                    ),
                    DataTable(
                      sortColumnIndex: 0,
                      sortAscending: true,
                      columns: [
                        DataColumn(
                            //onSort: (columnIndex, ascending) {
                            /*setState(() {
                            if (ascending) {
                              thisLiftPrs.sort((row1, row2) {
                                return row1.reps.compareTo(row2.reps);*/

                            //.forEach((element)

                            /*return thisLiftPrs[thisLiftPrs.indexOf(row1)]
                                  .reps
                                  .compareTo(
                                      thisLiftPrs[thisLiftPrs.indexOf(row2)]
                                          .reps);*/
                            /*});
                            } else if (!ascending) {
                              thisLiftPrs.sort((row1, row2) {
                                return row1.reps.compareTo(row2.reps);*/
                            //thisLiftPrs = thisLiftPrs.reversed.toList();
                            /*thisLiftPrs.sort((row1, row2) {
                                return row2.reps.compareTo(row1.reps);*/

                            /*prs.prs.sort((row1, row2) {
                              return thisLiftPrs[thisLiftPrs.indexOf(row2)]
                                  .reps
                                  .compareTo(
                                      thisLiftPrs[thisLiftPrs.indexOf(row1)]
                                          .reps);*/
                            //});
                            /* });
                            }
                          });*/
                            //},
                            label: Text('Rep Max'),
                            numeric: true),
                        DataColumn(label: Text('Weight'), numeric: true),
                        DataColumn(label: Text('Date'), numeric: true),
                      ],
                      rows: dr, //_buildPRCells(prs),

                      // prs.prs.forEach((element) { _buildPRCells(value.prs[element]);})
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          quote,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Visibility(
                        child: Text(
                            "HomeGymTV"), //Image.asset("assets/images/fc_logo.png"),
                        visible: isScreenshotting)
                  ]),
            ),
            IconButton(
                icon: Image.asset("assets/images/Instagram_Logo.png"),
                onPressed: () async {
                  // because we can't share app data outside of the app, need to save to external storage
                  final directory = (await getExternalStorageDirectory())
                      .path; //from path_provide package
                  String fileName = DateTime.now().toIso8601String();
                  var path = '$directory/$fileName.png';
                  await doScreenshot(path);
                }),
          ]),
        ]));
  }
}
