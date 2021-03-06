import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/appbar.dart';
import 'package:intl/intl.dart';

// TODO: a lot of display code is in here for some reason
// including things about width to show ont he screen that should be
// set as a function of context (mediaquery etc.) so fix that.

class EasyDate {
  String formattedDate;
  String easyBackToDateTimeFormatted;
  //DateTime originalDate;
  double daysSinceMin;

  EasyDate({@required DateTime date, DateTime minDateTime}) {
    //originalDate = date;
    if (minDateTime != null) {
      daysSinceMin = date.difference(minDateTime).inDays.toDouble();
    }
    formattedDate = DateFormat.yMd().format(date);
    easyBackToDateTimeFormatted = DateFormat('yyyy-MM-dd').format(date);
  }
}

class PrettyPRGraphs extends ChangeNotifier {
  bool isShowingMainData;
  //String selectedMax;
  bool _chartTypeIsLine;
  int touchedIndex = -1;
  String selectedLift;
  bool _isRepNotWeight;
  Prs prs;
  int maxPointsToShow = 10;
  int currentIteratorDistinctPrs = 0;
  int maxDistinctPrsInAnyBucket = 0;
  DateTime startDate;
  DateTime endDate;
  double barChartMaxY = 0;

  final Color barBackgroundColor = const Color(0xff72d8bf);

  int index;

  //bool isScreenshotting;
  final List<Color> availableColors = [
    Colors.purpleAccent,
    Colors.yellow,
    Colors.lightBlue,
    Colors.orange,
    Colors.pink,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.limeAccent,
    Colors.deepOrangeAccent,
    Colors.brown,
    Colors.tealAccent,
    Colors.grey,
    Colors.cyanAccent,
    Colors.blueGrey,
    Colors.lightGreenAccent
  ];

  PrettyPRGraphs(
      {this.isShowingMainData,
      //this.selectedMax,
      @required this.selectedLift,
      @required this.prs,
      //@required this.startDate,
      //@required this.endDate,
      //@required this.barBackgroundColor,
      //@required BuildContext context
      //this.isScreenshotting,
      chartTypeIsLine})
      : _chartTypeIsLine = chartTypeIsLine ?? true {
    if (selectedLift != null) {
      index = ReusableWidgets.lifts.indexOf(selectedLift);
    } else {
      this.index = 0;
      this.selectedLift = ReusableWidgets.lifts[index];
    }
    _isRepNotWeight = true;
  }

  set chartTypeIsLine(bool newValue) {
    _chartTypeIsLine = newValue;
    notifyListeners();
  }

  get chartTypeIsLine => _chartTypeIsLine;

  set isRepNotWeight(bool newValue) {
    _isRepNotWeight = newValue;
    notifyListeners();
  }

  get isRepNotWeight => _isRepNotWeight;

  nextLift() {
    index++;
    // if we just went past, set back to 0
    if (index >= ReusableWidgets.lifts.length) {
      index = 0;
    }
    selectedLift = ReusableWidgets.lifts[index];
  }

  List<Pr> getPrsList({@required bool currentPrs}) {
    List<Pr> toReturn;
    if (currentPrs) {
      toReturn = prs.bothLocalAllPR(
          liftTitle: selectedLift,
          prs: prs.currentPrs)[_isRepNotWeight ? "Rep" : "Weight"];
    } else {
      // here we are showing them over time, so we pull every individual PR
      // The line graph will simply spit these back out
      // the bar graph over time will instead need to group them by, e.g. "PRs that are 5RM PRs" and cycle through them over time
      // that will be dealt with outside of here
      toReturn = prs.bothLocalAllPR(
          liftTitle: selectedLift,
          prs: prs.allPrs)[_isRepNotWeight ? "Rep" : "Weight"];
    }
    // bias towards the heaviest available weights. Rep max is already sorted that way (for now)
    // TODO: if we allow sorting ont he other page we should probably reflect that here .
    if (!isRepNotWeight) {
      toReturn.sort((item1, item2) {
        return item2.weight.compareTo(item1.weight);
      });
    }
    return toReturn;
  }

  List<List<Pr>> _buildPRsByType(List<Pr> prs) {
    List<Pr> prsToReturn = List.from(prs);
    List<List<Pr>> list2 = List<List<Pr>>();
    if (_chartTypeIsLine) {}
    if (isRepNotWeight) {
      // for every PR we have,
      for (int i = 0; i < prsToReturn.length; i++) {
        // see if we have a bucket for it, and add it to that or make a new one if not
        bool anyBucketFound = false;
        for (int j = 0; j < list2.length; j++) {
          // if it does exist, see if it matches reps. if it does, add it to the list if it exists
          if (list2[j][0].reps == prsToReturn[i].reps) {
            /*bool tmpLineCheck = true;
            // this is intended to force us to only have one, and the max
            if (_chartTypeIsLine) {
              tmpLineCheck = !list2[j].any((element) => element.dateTime == prsToReturn[i].dateTime
              );
               */
            //}
            //if(tmpLineCheck) {
            anyBucketFound = true;
            list2[j].add(prsToReturn[i]);
            // we only cycle through as many times as we have MAX records for a given rep/weight max. increment that here
            maxDistinctPrsInAnyBucket = max(maxDistinctPrsInAnyBucket, j);
            // }
          }
        }
        // otherwise if this bucket doesn't exist, add it
        if (!anyBucketFound) {
          list2.add(List<Pr>());
          list2[min(list2.length - 1, i)].add(prsToReturn[i]);
        }
      }
      // Now sort each Rep or Weight max bucket from low to high so it increases over time!
      list2.forEach((element) {
        element.sort((subelement1, subelement2) =>
            subelement1.weight.compareTo(subelement2.weight));
      });
    } else {
      // for every PR we have,
      for (int i = 0; i < prsToReturn.length; i++) {
        // see if we have a bucket for it, and add it to that or make a new one if not
        bool anyBucketFound = false;
        for (int j = 0; j < list2.length; j++) {
          // if it does exist, see if it matches reps. if it does, add it to the list if it exists
          if (list2[j][0].weight == prsToReturn[i].weight) {
            anyBucketFound = true;
            list2[j].add(prsToReturn[i]);
            // we only cycle through as many times as we have MAX records for a given rep/weight max. increment that here
            maxDistinctPrsInAnyBucket = max(maxDistinctPrsInAnyBucket, j);
          }
        }
        // otherwise if this bucket doesn't exist, add it
        if (!anyBucketFound) {
          list2.add(List<Pr>());
          list2[min(list2.length - 1, i)].add(prsToReturn[i]);
        }
      }
      list2.forEach((element) {
        element.sort((subelement1, subelement2) =>
            subelement1.reps.compareTo(subelement2.reps));
      });
    }

    return list2;
  }

  _getMaxY({@required bool currentPrs}) {
    var _prs = prs.bothLocalAllPR(
        liftTitle: selectedLift,
        prs: prs.allPrs)[_isRepNotWeight ? "Rep" : "Weight"];
    var maxSofar = 0;

    _prs.forEach((element) {
      if ((isRepNotWeight ? element.weight : element.reps) > maxSofar) {
        maxSofar = (isRepNotWeight ? element.weight : element.reps);
      }
      ;
    });

    return maxSofar;
  }

  _getMinDateTime({@required List<List<Pr>> prs}) {
    DateTime minSofar = DateTime.now();

    prs.forEach((list) {
      list.forEach((element) {
        if (element.dateTime.compareTo(minSofar) < 0) {
          minSofar = element.dateTime;
        }
      });
    });

    return minSofar;
  }

  String getTitle(
      {@required int index,
      @required List<Pr> prsList,
      @required bool returnDateNotVals,

      /// this returns just the opposite of what is normally returned, WITHOUT the prefix
      bool switchGet}) {
    if (index >= prsList.length) {
      return "";
    }
    // return the opposite, with no prefix
    if (switchGet ?? false) {
      return (_isRepNotWeight ? prsList[index].weight : prsList[index].reps)
          .toString();
    }
    var suffix = (_isRepNotWeight ? "RM" : "");
    var prefix = (_isRepNotWeight ? prsList[index].reps : prsList[index].weight)
        .toString();

    if (returnDateNotVals) {
      return "${prsList[index].dateTime.month}/${prsList[index].dateTime.day}/${prsList[index].dateTime.year}";
    }
    return prefix + suffix;
  }

  BarChartData currentData(Function(BarTouchResponse) touchCallback) {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String date = getTitle(
                index: group.x,
                prsList: getPrsList(currentPrs: true),
                returnDateNotVals: true,
              );
              // sooooooo the rod y value gets modified to push it up, so we need to re-adjust that here (why not just literal val?)
              String weight = getTitle(
                  index: group.x,
                  prsList: getPrsList(currentPrs: true),
                  returnDateNotVals: false,
                  switchGet: true);
              return BarTooltipItem(

                  /*(barChartMaxY >= rod.y
                          ? (rod.y ~/ 1.1).toString()
                          : barChartMaxY.toString()) +
                          */
                  weight + (!isRepNotWeight ? " reps" : "") + '\n' + date,
                  TextStyle(color: Colors.yellow));
            }),
        touchCallback: (barTouchResponse) => touchCallback(barTouchResponse),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          interval: null,
          getTextStyles: (value) => const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            return getTitle(
                index: value.toInt(),
                prsList: getPrsList(currentPrs: true),
                returnDateNotVals: false);
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(getPrsList(currentPrs: true)),
    );
  }

  BarChartData dataOverTime(/*List<Pr> prs*/) {
    // first get the PRs list
    var prsList = getPrsList(currentPrs: false);
    // then we get them into buckets by type e.g. all 5RM PRs in a list to cycle through
    //var mapToPrList = _buildPRsByType(prsList);
    var prListOfLists = _buildPRsByType(prsList);
    // then count the number of distinct buckets to show, if there's enough to show, else 10
    int numPointsShowing = min(prListOfLists.length, maxPointsToShow);
    if (numPointsShowing <= 0) {
      numPointsShowing = 1;
    }
    // then get a distinct list of buckets so we can generate titles from it
    List<Pr> prsListDistinct = List<Pr>();

    prListOfLists.forEach((element) {
      prsListDistinct.add(element[0]);
    });

    return BarChartData(
      barTouchData: BarTouchData(
        enabled: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            return getTitle(
                index: value.toInt(),
                prsList: prsListDistinct,
                returnDateNotVals: false);
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: List.generate(numPointsShowing, (i) {
        var thisBarIndex =
            min(currentIteratorDistinctPrs, prListOfLists[i].length - 1);
        return makeGroupData(
            i,
            isRepNotWeight
                ? prListOfLists[i][thisBarIndex].weight
                : prListOfLists[i][thisBarIndex].reps,
            barColor:
                // store the seed somewhere per loop? something like that anyway.
                availableColors[
                    Random(thisBarIndex).nextInt(availableColors.length)],
            width: 220 / numPointsShowing);
      }),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    int y, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    var maxY = _getMaxY(currentPrs: isShowingMainData).toDouble();
    barChartMaxY = maxY;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? (min(1.1 * y.toDouble(), maxY)) : y.toDouble(),
          colors: isTouched ? [Colors.yellow] : [barColor],
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: maxY,
            colors: [barBackgroundColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups(List<Pr> prs) =>
      List.generate(min(prs.length, maxPointsToShow), (i) {
        var numPointsShowing = min(prs.length, maxPointsToShow);
        if (numPointsShowing <= 0) {
          numPointsShowing = 1;
        }
        return makeGroupData(i, isRepNotWeight ? prs[i].weight : prs[i].reps,
            isTouched: i == touchedIndex, width: 220 / numPointsShowing);
      });

  LineChartData oneLiftData(bool oneLiftNotAll) {
    // first get the PRs list
    var prsList = getPrsList(currentPrs: false);
    // then we get them into buckets by type e.g. all 5RM PRs in a list to cycle through
    var prListOfLists = _buildPRsByType(prsList);

    // then count the number of distinct buckets to show, if there's enough to show, else 10
    /*int numPointsShowing = min(prListOfLists.length, maxPointsToShow);
    if (numPointsShowing <= 0) {
      numPointsShowing = 1;
    }*/
    // then get a distinct list of buckets so we can generate titles from it
    List<Pr> prsListDistinct = List<Pr>();

    // for lines, we only want to keep the maximum PR set for a given rep or weight on a day
    //

    List<List<Pr>> listOfListDistinctDates = List<List<Pr>>();
    /*prListOfLists.forEach((element) {
      //element.sort()
      List<Pr> distinctDateList;
      final seen = Set<Pr>();
      distinctDateList = element.where((str) => seen.add(str)).toList();
      listOfListDistinctDates.add(distinctDateList);
    });*/

    //final reducedList = [];

    // we only want to capture a single PR set in a given day for a given rep or weight
    Set<Pr> setOfDistinctDates = Set<Pr>();
    Set<EasyDate> dates = Set<EasyDate>();
    prListOfLists.forEach((list) {
      List<Pr> distinctThisLine = List<Pr>();

      list.reduce((value, element) {
        if (!(value.dateTime.difference(element.dateTime).inDays.abs() < 0.5))
          distinctThisLine.add(value);
        setOfDistinctDates.add(element);
        dates.add(EasyDate(date: element.dateTime));
        return element;
      });
      distinctThisLine.add(list.last);
      // need to check this last element too! and single item lists...
      if (!dates.any((element) =>
          list.last.dateTime
              .difference(DateTime.parse(element.easyBackToDateTimeFormatted))
              .inDays
              .abs() <
          0.5)) {
        dates.add(EasyDate(date: list.last.dateTime));
      }

      listOfListDistinctDates.add(distinctThisLine);
    });

    var finaldates = dates.toList()
      ..sort((date1, date2) {
        return date1.easyBackToDateTimeFormatted
            .compareTo(date2.easyBackToDateTimeFormatted);
      });
    /*var finaldates = dates.toList()
      ..sort((date1, date2) {
        var firstSlash = date1.indexOf("/");
        var secondSlash = date1.indexOf("/", firstSlash + 1);

        var daypart = date1.substring(0, firstSlash);
        var monthpart = date1.substring(firstSlash + 1, secondSlash);
        var yearpart = date1.substring(secondSlash + 1);

        var firstSlash2 = date2.indexOf("/");
        var secondSlash2 = date2.indexOf("/", firstSlash2 + 1);

        var daypart2 = date2.substring(0, firstSlash2);
        var monthpart2 = date2.substring(firstSlash2 + 1, secondSlash2);
        var yearpart2 = date2.substring(secondSlash2 + 1);

        if (int.parse(yearpart2) > int.parse(yearpart)) {
          return -1;
        } else if (int.parse(yearpart2) < int.parse(yearpart)) {
          return 1;
        } else if (int.parse(yearpart2) == int.parse(yearpart)) {
          if (int.parse(monthpart2) > int.parse(monthpart)) {
            return -1;
          } else if (int.parse(monthpart2) < int.parse(monthpart)) {
            return 1;
          } else if (int.parse(monthpart2) == int.parse(monthpart)) {
            if (int.parse(daypart2) > int.parse(daypart)) {
              return -1;
            } else if (int.parse(daypart2) < int.parse(daypart)) {
              return 1;
            }
            if (int.parse(daypart2) == int.parse(daypart)) {
              return 0;
            }
          }
        }
        print("somethings gone wrong");
      });*/

    // now we want a list of all days that a PR was set on
    /* List<Pr> listOfDistinctDates = setOfDistinctDates.toList()
      ..sort((element1, element2) =>
          element1.dateTime.compareTo(element2.dateTime));*/

    // not sure if necessary for htis one
    prListOfLists.forEach((element) {
      prsListDistinct.add(element[0]);
    });

    double maxY = _getMaxY(currentPrs: isShowingMainData).toDouble();
    var minDateTime = _getMinDateTime(prs: listOfListDistinctDates);

    // calculate days since minimum, because that is our x value on the graph
    finaldates.forEach((element) {
      element.daysSinceMin = DateTime.parse(element.easyBackToDateTimeFormatted)
          .difference(minDateTime)
          .inDays
          .toDouble();
    });

    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItems: (items) {
              return List.generate(items.length, (index) {
                /*String repOrWeight = getTitle(
                  index: index,
                  prsList: prListOfLists[items.elementAt(index).barIndex],
                  returnDateNotVals: false,
                );*/
                return LineTooltipItem(
                    //(rod.y ~/ 1.1).toString() +
                    listOfListDistinctDates[items.elementAt(index).barIndex]
                                [items.elementAt(index).spotIndex]
                            .reps
                            .toString() +
                        "x" +
                        listOfListDistinctDates[items.elementAt(index).barIndex]
                                [items.elementAt(index).spotIndex]
                            .weight
                            .toString(),
                    TextStyle(color: Colors.yellow));
              });

              // sooooooo the rod y value gets modified to push it up, so we need to re-adjust that here (why not just literal val?)
            }),
        touchCallback: (LineTouchResponse touchResponse) {},
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          //reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff72719b),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          margin: 10,
          getTitles: (value) {
            if (value.toInt() == 0) {
              return finaldates[0].formattedDate;
            } else if (value ==
                finaldates[finaldates.length ~/ 2].daysSinceMin) {
              return finaldates[finaldates.length ~/ 2].formattedDate;
            } else if (value == finaldates[finaldates.length - 1].daysSinceMin)
              return finaldates[finaldates.length - 1].formattedDate;
            return "";
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          interval: max(((maxY * .05) ~/ 10 * 10).toDouble(), 5.0),
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          /*getTitles: (value) {

            switch (value.toInt()) {
              case 1:
                return '1m';
              case 2:
                return '2m';
              case 3:
                return '3m';
              case 4:
                return '5m';
            }
            return '';
          },
          */
          margin: 8,
          //reservedSize: 30,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xff4e4965),
            width: 4,
          ),
          left: BorderSide(
            color: Colors.transparent,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      minX: 0,
      //maxX: 14,
      maxY: maxY.toDouble(),
      minY: 0,
      lineBarsData: oneLiftNotAll
          ? singleLiftLineData(listOfListDistinctDates,
              _getMinDateTime(prs: listOfListDistinctDates))
          : allLiftLineData(),
    );
  }

  List<LineChartBarData> singleLiftLineData(
      List<List<Pr>> prListOfLists, DateTime minDateTime) {
    List<LineChartBarData> lines = List<LineChartBarData>();
    List<FlSpot> spots; // = List<FlSpot>();

    prListOfLists.forEach((elementOuter) {
      var colorIndex = prListOfLists.indexOf(elementOuter);
      spots = List<FlSpot>();
      // for this list, add every spot!
      // may need to come back later and
      elementOuter.forEach((elementInner) {
        // X and Y axis switch between reps and weight. otherwise we go by x axis = 1, 2, 3 for some reason?
        // no, use date. they aren't all equally spaced and that's going to mess up our titling too
        if (isRepNotWeight) {
          spots.add(FlSpot(

              //elementOuter.indexOf(elementInner).toDouble(),
              elementInner.dateTime.difference(minDateTime).inDays.toDouble(),
              elementInner.weight.toDouble()));
        } else {
          spots.add(FlSpot(
              //elementOuter.indexOf(elementInner).toDouble(),
              elementInner.dateTime.difference(minDateTime).inDays.toDouble(),
              elementInner.reps.toDouble()));
        }
      });
      lines.add(LineChartBarData(
        spots: spots,
        isCurved: false,
        isStepLineChart: true,
        lineChartStepData: LineChartStepData(
            stepDirection: LineChartStepData.stepDirectionForward),
        colors: [
          availableColors[Random(colorIndex).nextInt(availableColors.length)],
        ],
        barWidth: 8,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: false,
        ),
      ));
    });
    /*
    LineChartBarData lineChartBarData2 = LineChartBarData(
      spots: [
        FlSpot(1, 1),
        FlSpot(3, 2.8),
        FlSpot(7, 1.2),
        FlSpot(10, 2.8),
        FlSpot(12, 2.6),
        FlSpot(13, 3.9),
      ],
      isCurved: true,
      colors: [
        const Color(0xffaa4cfc),
      ],
      barWidth: 8,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(show: false, colors: [
        const Color(0x00aa4cfc),
      ]),
    );
    LineChartBarData lineChartBarData3 = LineChartBarData(
      spots: [
        FlSpot(1, 2.8),
        FlSpot(3, 1.9),
        FlSpot(6, 3),
        FlSpot(10, 1.3),
        FlSpot(13, 2.5),
      ],
      isCurved: true,
      colors: const [
        Color(0xff27b6fc),
      ],
      barWidth: 8,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );*/
    return lines;
    /*[
      lineChartBarData1,
      lineChartBarData2,
      lineChartBarData3,
    ];*/
  }
/*
  LineChartData sampleData2(List<List<Pr>> prListOfLists) {
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: false,
      ),
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff72719b),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          margin: 10,
          getTitles: (value) {
            switch (value.toInt()) {
              case 2:
                return 'SEPT';
              case 7:
                return 'OCT';
              case 12:
                return 'DEC';
            }
            return '';
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '1m';
              case 2:
                return '2m';
              case 3:
                return '3m';
              case 4:
                return '5m';
              case 5:
                return '6m';
            }
            return '';
          },
          margin: 8,
          reservedSize: 30,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(
              color: Color(0xff4e4965),
              width: 4,
            ),
            left: BorderSide(
              color: Colors.transparent,
            ),
            right: BorderSide(
              color: Colors.transparent,
            ),
            top: BorderSide(
              color: Colors.transparent,
            ),
          )),
      minX: 0,
      maxX: 14,
      maxY: 6,
      minY: 0,
      lineBarsData: allLiftLineData(),
    );
  }*/

  List<LineChartBarData> allLiftLineData() {
    return [
      LineChartBarData(
        spots: [
          FlSpot(1, 1),
          FlSpot(3, 4),
          FlSpot(5, 1.8),
          FlSpot(7, 5),
          FlSpot(10, 2),
          FlSpot(12, 2.2),
          FlSpot(13, 1.8),
        ],
        isCurved: true,
        curveSmoothness: 0,
        colors: const [
          Color(0x444af699),
        ],
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: false,
        ),
      ),
      LineChartBarData(
        spots: [
          FlSpot(1, 1),
          FlSpot(3, 2.8),
          FlSpot(7, 1.2),
          FlSpot(10, 2.8),
          FlSpot(12, 2.6),
          FlSpot(13, 3.9),
        ],
        isCurved: true,
        colors: const [
          Color(0x99aa4cfc),
        ],
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(show: true, colors: [
          const Color(0x33aa4cfc),
        ]),
      ),
      LineChartBarData(
        spots: [
          FlSpot(1, 3.8),
          FlSpot(3, 1.9),
          FlSpot(6, 5),
          FlSpot(10, 3.3),
          FlSpot(13, 4.5),
        ],
        isCurved: true,
        curveSmoothness: 0,
        colors: const [
          Color(0x4427b6fc),
        ],
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(
          show: false,
        ),
      ),
    ];
  }
}
