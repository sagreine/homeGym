import 'dart:io';

import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
//import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/views/views.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:social_share_plugin/social_share_plugin.dart';

import 'package:direct_select_flutter/generated/i18n.dart';
import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';

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
  // TODO use static
  List<String> _lifts = [
    "Squat",
    "Press",
    "Deadlift",
    "Bench",
  ];
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

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
    if (prs == null) {
      return;
    }
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
                    : "${element.weight.toString()}WM",
              ),
              showEditIcon: false),
          DataCell(
            Text(tabName == "Rep"
                ? "${element.weight.toString()}"
                : "${element.reps.toString()}"),
            showEditIcon: false,
          ),
          DataCell(
            Text(Provider.of<LifterMaxes>(context, listen: false)
                .calculateE1RM(reps: element.reps, weight: element.weight)
                .toInt()
                .toString()),
            showEditIcon: false,
          ),
          DataCell(
              Text(
                "${element.dateTime.month.toString()}/${element.dateTime.day.toString()}/${element.dateTime.year.toString()}",
              ),
              showEditIcon: false),
        ]));
      });
      //}
      //return dr;
    }
  }

  DirectSelectItem<String> getDropDownMenuItem(String value) {
    return DirectSelectItem<String>(
        itemHeight: 56,
        value: value,
        itemBuilder: (context, value) {
          return Text(value);
        });
  }

  void _showScaffold() {
    final snackBar = SnackBar(content: Text('Hold and drag instead of tap'));
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  _getDslDecoration() {
    return BoxDecoration(
      border: BorderDirectional(
        bottom: BorderSide(width: 1, color: Colors.black12),
        top: BorderSide(width: 1, color: Colors.black12),
      ),
    );
  }

  _buildTab(String tabName) {
    updateThisLifPrs(prs: fullCurrentPrs, isRep: tabName == "Rep");
    _buildPRCells(thisLiftPrs, tabName);

    return DirectSelectContainer(
      //decoration: BoxDecoration(),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Your $tabName PRs",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          //SingleChildScrollView(
          //child: Column(
          //mainAxisSize: MainAxisSize.min,
          //children: [
          //MealSelector(data: _lifts, label: "Select lift"),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    spreadRadius: 4,
                    offset: new Offset(0.0, 0.0),
                    blurRadius: 15.0,
                  ),
                ],
              ),
              child: Card(
                  child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                      child: Padding(
                          child: DirectSelectList<String>(
                              values: _lifts,
                              onUserTappedListener: () {
                                _showScaffold();
                              },
                              defaultItemIndex: _lifts.indexOf(lift),
                              itemBuilder: (String value) =>
                                  getDropDownMenuItem(value),
                              focusedItemDecoration: _getDslDecoration(),
                              onItemSelectedListener: (item, index, context) {
                                setState(() {
                                  lift = _lifts[index];
                                  updateThisLifPrs(
                                      prs: fullCurrentPrs,
                                      isRep: tabName == "Rep");
                                });
                              }),
                          padding: EdgeInsets.only(left: 22))),
                  Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.unfold_more,
                        color: Colors.blueAccent,
                      ))
                ],
              )),
            ),
          ),
          /*
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
                  updateThisLifPrs(
                      prs: fullCurrentPrs, isRep: tabName == "Rep");
                });
              }),*/
          SizedBox(
            height: 12,
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
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
                    DataColumn(
                      label: Text(
                        'e1RM',
                      ),
                    ),
                    DataColumn(label: Text('Date'), numeric: true),
                  ],
                  rows: dr, //_buildPRCells(prs),

                  // prs.prs.forEach((element) { _buildPRCells(value.prs[element]);})
                ),
              ],
            ),
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
      ),
      //),
      //),
    );
    //  );

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
    new Tab(text: 'Pretty Graphs'),
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
        TabController(initialIndex: 0, length: 3, vsync: this);
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
        .capture(path: path, delay: Duration(milliseconds: 20), pixelRatio: 1.5)
        .then((File image) async {
      await SocialSharePlugin.shareToFeedInstagram(path: image.path);
    });
    setState(() {
      isScreenshotting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    //_buildPRCells(thisLiftPrs, tabName);

    return Scaffold(
        key: scaffoldKey,
        drawer: ReusableWidgets.getDrawer(context),
        appBar: MediaQuery.of(context).orientation == Orientation.portrait
            ? ReusableWidgets.getAppBar(
                tabController: this.defaultTabController, tabs: myTabs)
            : ReusableWidgets.getAppBar(tabController: null, tabs: myTabs),
        body: Screenshot(
            controller: screenshotController,
            child: Container(
                color: Theme.of(context).canvasColor,
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Expanded(
                    child: TabBarView(
                      controller: this.defaultTabController,
                      children: [
                        _buildTab("Rep"),
                        _buildTab("Weight"),
                        // CONSUMER

                        ChangeNotifierProvider(
                          create: (context) => PrettyPRGraphs(
                            prs: Provider.of<Prs>(context, listen: false),
                            selectedLift: lift,
                            //barBackgroundColor: Theme.of(context).accentColor
                            /*isScreenshotting: isScreenshotting*/
                          ),
                          child: PrettyPRGraphsView(
                              isScreenshotting:
                                  isScreenshotting), //context: context),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text("@HomeGymTV"),
                      ), //Image.asset("assets/images/fc_logo.png"),
                      visible: isScreenshotting),
                  Visibility(
                      child: IconButton(
                          icon: Image.asset("assets/images/Instagram_Logo.png"),
                          onPressed: () async {
                            // because we can't share app data outside of the app, need to save to external storage
                            final directory =
                                (await getExternalStorageDirectory())
                                    .path; //from path_provide package
                            String fileName = DateTime.now().toIso8601String();
                            var path = '$directory/$fileName.png';
                            await doScreenshot(path);
                          }), //Image.asset("assets/images/fc_logo.png"),
                      visible: !isScreenshotting),
                ]))));

    //]));
  }
}
/*
class MealSelector extends StatelessWidget {
  final buttonPadding = const EdgeInsets.fromLTRB(0, 8, 0, 0);

  final List<String> data;
  final String label;

  MealSelector({@required this.data, @required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            alignment: AlignmentDirectional.centerStart,
            margin: EdgeInsets.only(left: 4),
            child: Text(label)),
        Padding(
          padding: buttonPadding,
          child: Container(
            decoration: _getShadowDecoration(),
            child: Card(
                child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                    child: Padding(
                        child: DirectSelectList<String>(
                          values: data,
                          defaultItemIndex: 0,
                          itemBuilder: (String value) =>
                              getDropDownMenuItem(value),
                          focusedItemDecoration: _getDslDecoration(),
                        ),
                        padding: EdgeInsets.only(left: 12))),
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: _getDropdownIcon(),
                )
              ],
            )),
          ),
        ),
      ],
    );
  }

  DirectSelectItem<String> getDropDownMenuItem(String value) {
    return DirectSelectItem<String>(
        itemHeight: 56,
        value: value,
        itemBuilder: (context, value) {
          return Text(value);
        });
  }

 

  BoxDecoration _getShadowDecoration() {
    return BoxDecoration(
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.black.withOpacity(0.06),
          spreadRadius: 4,
          offset: new Offset(0.0, 0.0),
          blurRadius: 15.0,
        ),
      ],
    );
  }

  Icon _getDropdownIcon() {
    return Icon(
      Icons.unfold_more,
      color: Colors.blueAccent,
    );
  }
}

DirectSelectItem<String> getDropDownMenuItem(String value) {
  return DirectSelectItem<String>(
      itemHeight: 56,
      value: value,
      itemBuilder: (context, value) {
        return Text(value);
      });
}

_getDslDecoration() {
  return BoxDecoration(
    border: BorderDirectional(
      bottom: BorderSide(width: 1, color: Colors.black12),
      top: BorderSide(width: 1, color: Colors.black12),
    ),
  );
}
*/
