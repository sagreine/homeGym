import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/appbar.dart';

// TODO: a lot of display code is in here for some reason
// including things about width to show ont he screen that should be
// set as a function of context (mediaquery etc.) so fix that.

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

  final Color barBackgroundColor = const Color(0xff72d8bf);
  //Color barBackgroundColor = Colors.yellow;
//final Color barBackgroundColodr = const Color(0xff72d8bf);
  //var a = const Color(0xff81e5cd);

  int index;

  //bool isScreenshotting;
  final List<Color> availableColors = [
    Colors.purpleAccent,
    Colors.yellow,
    Colors.lightBlue,
    Colors.orange,
    Colors.pink,
    Colors.redAccent,
  ];

  PrettyPRGraphs(
      {this.isShowingMainData,
      //this.selectedMax,
      @required this.selectedLift,
      @required this.prs,
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

// bad because we have an index to pass in, and then bad because map isn't ordered.
/*  Map<int, List<Pr>> _buildPRsByType(List<Pr> prs) {
    List<Pr> prsToReturn = List.from(prs);
    var map2 = Map<int, List<Pr>>();
    if (isRepNotWeight) {
      prsToReturn.sort((item1, item2) {
        return item2.reps.compareTo(item1.reps);
      });

      prsToReturn.forEach((pr) {
        if (map2[pr.reps] == null) {
          map2[pr.reps] = List<Pr>();
        }
        map2[pr.reps].add(pr);
      });
    } else {
      prsToReturn.sort((item1, item2) {
        return item2.weight.compareTo(item1.weight);
      });
      var map2 = Map<int, List<Pr>>();
      prs.forEach((pr) {
        if (map2[pr.weight] == null) {
          map2[pr.weight] = List<Pr>();
        }
        map2[pr.weight].add(pr);
      });
    }
    return map2;
  }*/

  List<List<Pr>> _buildPRsByType(List<Pr> prs) {
    List<Pr> prsToReturn = List.from(prs);
    List<List<Pr>> list2 = List<List<Pr>>();
    if (isRepNotWeight) {
      // sort
      /*prsToReturn.sort((item1, item2) {
        return item2.reps.compareTo(item1.reps);
      });*/

      //prsToReturn.reduce((value, element) => null)
      // for every PR we have,
      for (int i = 0; i < prsToReturn.length; i++) {
        // see if we have a bucket for it, and add it to that or make a new one if not
        bool anyBucketFound = false;
        for (int j = 0; j < list2.length; j++) {
          // if it does exist, see if it matches reps. if it does, add it to the list if it exists
          if (list2[j][0].reps == prsToReturn[i].reps) {
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
      // Now sort each Rep or Weight max bucket from low to high so it increases over time!
      list2.forEach((element) {
        element.sort((subelement1, subelement2) =>
            subelement1.weight.compareTo(subelement2.weight));
      });
    }
    // TODO: this sort might be necessary though, double check
    else {
      /*prsToReturn.sort((item1, item2) {
        return item2.weight.compareTo(item1.weight);
      });*/
      //prsToReturn.reduce((value, element) => null)
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

    /* mapToPrList.forEach((key, value) { 
        return 
        value[
          min(currentIteratorDistinctPrs,mapToPrList[currentIteratorDistinctPrs].length - 1)
          ].weight;
          }
          )*/
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

  String getTitle(
      {@required int index,
      @required List<Pr> prsList,
      @required bool returnDateNotVals}) {
    /*var prsList = prs.bothLocalAllPR(
        liftTitle: selectedLift)[_isRepNotWeight ? "Rep" : "Weight"];*/
    if (index >= prsList.length) {
      return "";
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
              /*String maxName = getTitle(
                index: group.x,
                prsList: getPrsList(currentPrs: true),
                returnDateNotVals: true,
              );*/
              String date = getTitle(
                index: group.x,
                prsList: getPrsList(currentPrs: true),
                returnDateNotVals: true,
              );
              // sooooooo the rod y value gets modified to push it up, so we need to re-adjust that here (why not just literal val?)
              return BarTooltipItem(
                  (rod.y ~/ 1.1).toString() +
                      (!isRepNotWeight ? " reps" : "") +
                      '\n' +
                      date,
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
            // TODO: need to pass in the distinct'd list to this?
            return getTitle(
                index: value.toInt(),
                prsList: prsListDistinct, //getPrsList(currentPrs: false)//,
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
        //var numPointsShowing = min(prs.length, maxPointsToShow);
        /*if (numPointsShowing <= 0) {
          numPointsShowing = 1;
        }*/
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

        //mapToPrList.entries.map((e) => null)
        //mapToPrList.entries[0].

        // we can make this work but it isn't going to be ordered nicely
        /*List.generate(numPointsShowing, (i) {
      return makeGroupData(
            i,
      mapToPrList.forEach((key, value) { 
        return 
        value[
          min(currentIteratorDistinctPrs,mapToPrList[currentIteratorDistinctPrs].length - 1)
          ].weight;
          }
          )
      
          //
        
        
            isRepNotWeight
                ? mapToPrList[i][min(currentIteratorDistinctPrs,
                        mapToPrList[currentIteratorDistinctPrs].length - 1)]
                    .weight
                : mapToPrList[i][min(currentIteratorDistinctPrs,
                        mapToPrList[currentIteratorDistinctPrs].length - 1)]
                    .reps,
            );*/

        // instead of 'random' we'll select either
        // 1) the next highest number if one exists else
        // 2) the highest one
        // this should show us the growth over time for each bucket
        /*makeGroupData(
            i, 1 * (isRepNotWeight ? prs[i].weight : prs[i].reps) + 0,
            isTouched: i == touchedIndex, width: 220 / numPointsShowing);*/
        /*switch (i) {
          case 0:
            
            return makeGroupData(
                0, (Random().nextInt(15).toDouble() + 6).toInt(),
                barColor:
                    availableColors[Random().nextInt(availableColors.length)]);
          case 1:
            return makeGroupData(1, Random().nextInt(15).toDouble().toInt() + 6,
                barColor:
                    availableColors[Random().nextInt(availableColors.length)]);
          case 2:
            return makeGroupData(2, Random().nextInt(15).toDouble().toInt() + 6,
                barColor:
                    availableColors[Random().nextInt(availableColors.length)]);
          case 3:
            return makeGroupData(3, Random().nextInt(15).toDouble().toInt() + 6,
                barColor:
                    availableColors[Random().nextInt(availableColors.length)]);
          case 4:
            return makeGroupData(4, Random().nextInt(15).toDouble().toInt() + 6,
                barColor:
                    availableColors[Random().nextInt(availableColors.length)]);
          case 5:
            return makeGroupData(5, Random().nextInt(15).toDouble().toInt() + 6,
                barColor:
                    availableColors[Random().nextInt(availableColors.length)]);
          case 6:
            return makeGroupData(6, Random().nextInt(15).toDouble().toInt() + 6,
                barColor:
                    availableColors[Random().nextInt(availableColors.length)]);
          default:
            return null;
        }*/
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
        return makeGroupData(
            i, 1 * (isRepNotWeight ? prs[i].weight : prs[i].reps) + 0,
            isTouched: i == touchedIndex, width: 220 / numPointsShowing);
      });

  LineChartData sampleData1() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
        touchCallback: (LineTouchResponse touchResponse) {},
        handleBuiltInTouches: true,
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
        ),
      ),
      minX: 0,
      maxX: 14,
      maxY: 4,
      minY: 0,
      lineBarsData: linesBarData1(),
    );
  }

  List<LineChartBarData> linesBarData1() {
    final LineChartBarData lineChartBarData1 = LineChartBarData(
      spots: [
        FlSpot(1, 1),
        FlSpot(3, 1.5),
        FlSpot(5, 1.4),
        FlSpot(7, 3.4),
        FlSpot(10, 2),
        FlSpot(12, 2.2),
        FlSpot(13, 1.8),
      ],
      isCurved: true,
      colors: [
        const Color(0xff4af699),
      ],
      barWidth: 8,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
    final LineChartBarData lineChartBarData2 = LineChartBarData(
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
    final LineChartBarData lineChartBarData3 = LineChartBarData(
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
    );
    return [
      lineChartBarData1,
      lineChartBarData2,
      lineChartBarData3,
    ];
  }

  LineChartData sampleData2() {
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
      lineBarsData: linesBarData2(),
    );
  }

  List<LineChartBarData> linesBarData2() {
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
