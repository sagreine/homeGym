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

class PrsViewState extends State<PrsView> with SingleTickerProviderStateMixin {
//class SinglePrView extends StatefulWidget {
  String tabName = "Rep";
  //final ScreenshotController screenshotController;
  /*SinglePrView({
    Key key,
    
    @required this.tabName,
    //@required this.screenshotController
  }) : super(key: key);
  @override
  SinglePrViewState createState() => SinglePrViewState();
}*/

//class SinglePrViewState extends State<SinglePrView> {
  String lift;
  int reps;
  int weight;
  List<DataRow> dr; // = List<DataRow>();

  List<Pr> thisLiftPrs;

  String quote;
  //var prs;
  //Prs prs;
  Map<String, List<Pr>> fullCurrentPrs;

  // = ScreenshotController();

  /*@override
  initState() {
    super.initState();
    var currentDay = Provider.of<ExerciseDay>(context, listen: false);

    lift = currentDay.lift ?? "Squat";
    //if(widget)
    prs = Provider.of<Prs>(context, listen: false);
    if (prs.prs != null) {
      updateThisLifPrs(prs);
    }
    quote = Quotes().getQuote(greatnessQuote: true);
  }*/

  void updateThisLifPrs(
      {@required Map<String, List<Pr>> prs, @required bool isRep}) {
    /*var _prs;
    if (isRep) {
      _prs = prs.prsRep;
    } else {
      _prs = prs.prsWeight;
    }*/
    if (prs[isRep ? "Rep" : "Weight"] != null) {
      thisLiftPrs = prs[isRep ? "Rep" : "Weight"]
          .where((element) => element.lift == lift)
          .toList()
            ..sort((element1, element2) => isRep
                ? element1.reps.compareTo(element2.reps)
                : element2.weight.compareTo(element1.weight));
    }
  }

  _buildPRCells(List<Pr> prs, String tabName) {
    dr = List<DataRow>();
    if (prs != null) {
      prs.where((element) => element.lift == lift).forEach((element) {
// TODO: SORT THIS HERE OR SO

        //var prindex = prs.prs.indexOf(element);
        //prs[prindex];
        //dr.indexOf(]);

        //if(prs.prs[dr.indexOf(element)] != -1){
        dr.add(DataRow(cells: [
          DataCell(
              Text(
                tabName == "Rep"
                    ? "${element.reps.toString()}RM"
                    : "${element.weight.toString()}RM",
              ),
              showEditIcon: false),
          DataCell(
            Text(tabName == "Rep"
                ? "${element.weight.toString()}"
                : "${element.reps.toString()}"),
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

  _buildTab(String tabName) {
    updateThisLifPrs(prs: fullCurrentPrs, isRep: tabName == "Rep");
    _buildPRCells(thisLiftPrs, tabName);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "Your $tabName PRs",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        DropdownButton(
            value: lift,
            items: [
              DropdownMenuItem(child: Text("Squat"), value: "Squat"),
              DropdownMenuItem(child: Text("Press"), value: "Press"),
              DropdownMenuItem(child: Text("Deadlift"), value: "Deadlift"),
              DropdownMenuItem(child: Text("Bench"), value: "Bench"),
            ],
            onChanged: (value) {
              setState(() {
                lift = value;
                updateThisLifPrs(prs: fullCurrentPrs, isRep: tabName == "Rep");
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
                label: Text('$tabName Max'),
                numeric: true),
            DataColumn(
                label: Text(tabName == "Rep" ? 'Weight' : "Reps"),
                numeric: true),
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
      ],
    );
    //]);
  }
/*
  @override
  Widget build(BuildContext context) {
    _buildPRCells(thisLiftPrs, widget.tabName);
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      _buildTab("Rep"),
      _buildTab("Weight"),
    ]);
  }
}
*/

  //PrsController _prsController = PrsController();
  //int reps;
  //int weight;
  //String lift
  /*List<DataRow> dr; // = List<DataRow>();
  List<Pr> thisLiftPrs;
  bool isScreenshotting = false;*/
  // this is a dumb way to do this.
  // String tabName;
  bool isScreenshotting = false;
  ScreenshotController screenshotController = ScreenshotController();
  TabController defaultTabController;
  final List<Tab> myTabs = <Tab>[
    new Tab(text: 'Rep PRs'),
    new Tab(text: 'Weight PRs'),
  ];

//  String quote;
//  var prs;

  @override
  dispose() {
    super.dispose();
    //screenshotController.dispose();
  }

  @override
  initState() {
    super.initState();
    //var currentDay = Provider.of<ExerciseDay>(context, listen: false);
    defaultTabController =
        TabController(initialIndex: 0, length: 2, vsync: this);
    // start by showing the rep PRs
//    tabName = "Rep";

    //lift = currentDay.lift ?? "Squat";
    /*prs = Provider.of<Prs>(context, listen: false);
    if (prs.prs != null) {
      updateThisLifPrs(prs);
    }
    quote = Quotes().getQuote(greatnessQuote: true);*/

    var currentDay = Provider.of<ExerciseDay>(context, listen: false);

    lift = currentDay.lift ?? "Squat";
    //if(widget)
    fullCurrentPrs = Provider.of<Prs>(context, listen: false).currentPrs;

    if (fullCurrentPrs != null) {
      updateThisLifPrs(prs: fullCurrentPrs, isRep: tabName == "Rep");
    }

    quote = Quotes().getQuote(greatnessQuote: true);
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

  @override
  Widget build(BuildContext context) {
    _buildPRCells(thisLiftPrs, tabName);

    return Scaffold(
        drawer: ReusableWidgets.getDrawer(context),
        appBar: MediaQuery.of(context).orientation == Orientation.portrait
            ? ReusableWidgets.getAppBar(
                tabController: this.defaultTabController, tabs: myTabs)
            : ReusableWidgets.getAppBar(tabController: null, tabs: myTabs),
        body: Screenshot(
            controller: screenshotController,
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Expanded(
                child: TabBarView(
                  controller: this.defaultTabController,
                  children: [
                    _buildTab("Rep"),
                    _buildTab("Weight"),
                  ],
                ),
              ),
              Visibility(
                  child: Text(
                      "HomeGymTV"), //Image.asset("assets/images/fc_logo.png"),
                  visible: isScreenshotting),
              IconButton(
                  icon: Image.asset("assets/images/Instagram_Logo.png"),
                  onPressed: () async {
                    // because we can't share app data outside of the app, need to save to external storage
                    final directory = (await getExternalStorageDirectory())
                        .path; //from path_provide package
                    String fileName = DateTime.now().toIso8601String();
                    var path = '$directory/$fileName.png';
                    await doScreenshot(path);
                  })
            ])));

    //]));
  }
}
