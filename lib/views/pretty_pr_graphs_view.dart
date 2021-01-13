import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/controllers/pretty_pr_graphs.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';
import 'package:flutter_icons/flutter_icons.dart';

class PrettyPRGraphsView extends StatefulWidget {
  final bool isScreenshotting;
  PrettyPRGraphsView({this.isScreenshotting});

  @override
  _PrettyPRGraphsViewState createState() => _PrettyPRGraphsViewState();
}

class _PrettyPRGraphsViewState extends State<PrettyPRGraphsView> {
  bool onInit = true;
  final animationDuration = Duration(milliseconds: 250);
  bool isPlaying = false;
  PrettyPrGraphsController prettyPrGraphsController =
      PrettyPrGraphsController();

  @override
  void initState() {
    super.initState();
  }

  _buildBarChart(PrettyPRGraphs model) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: Theme.of(context).brightness == Brightness.light
            ? Color(0xff81e5cd)
            : Color(0xff06916f),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: _cycleLiftsIconButton(model),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      '${model.selectedLift}',
                      style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .color
                              .withOpacity(0.8),
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Align(
                    //
                    alignment: Alignment.center,
                    child: Text(
                      (model.isRepNotWeight ?? false)
                          ? "Rep Maxes"
                          : "Weight Maxes",
                      style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .color
                              .withOpacity(0.4),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 38,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: BarChart(
                        isPlaying
                            ? model.dataOverTime()
                            : model.currentData(
                                (barTouchResponse) {
                                  setState(() {
                                    if (barTouchResponse.spot != null &&
                                        barTouchResponse.touchInput
                                            is! FlPanEnd &&
                                        barTouchResponse.touchInput
                                            is! FlLongPressEnd) {
                                      model.touchedIndex = barTouchResponse
                                          .spot.touchedBarGroupIndex;
                                    } else {
                                      model.touchedIndex = -1;
                                    }
                                  });
                                },
                              ),
                        swapAnimationDuration: animationDuration,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: const Color(0xff0f4a3c),
                  ),
                  onPressed: () {
                    setState(() {
                      isPlaying = !isPlaying;
                      model.currentIteratorDistinctPrs = 0;
                      refreshState(model);
                    });
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildLineChart(PrettyPRGraphs model) {
    return AspectRatio(
      aspectRatio: 1.23,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).hoverColor,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 37,
                ),
                // xrM? lift? --- want to be able to compare across lifts all at once for a given rm.
                Text(
                  'My Personal Records',
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .headline4
                        .color
                        .withOpacity(.3),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  '${model.selectedLift} ' +
                      ((model.isRepNotWeight ?? true)
                          ? "Rep Maxes"
                          : "Weight Maxes"),
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 37,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0, left: 6.0),
                    child: LineChart(
                      (model.isShowingMainData ?? true)
                          ? model.oneLiftData(true)
                          : model.oneLiftData(false),
                      swapAnimationDuration: animationDuration,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
            _cycleLiftsIconButton(model),
          ],
        ),
      ),
    );
  }

  _cycleLiftsIconButton(PrettyPRGraphs model) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: Icon(
            EvilIcons.arrow_right, // .refresh,
          ),
          onPressed: () {
            setState(() {
              model.nextLift();
              isPlaying = false;
            });
          },
        ));
  }

  _buildCharts(model) {
    return Expanded(
      child: model.chartTypeIsLine
          ? _buildLineChart(model)
          : _buildBarChart(model),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Prs>(builder: (context, prs, child) {
      return Consumer<PrettyPRGraphs>(builder: (context, model, child) {
        if (onInit) {
          model.isShowingMainData = true;
          onInit = false;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: !widget.isScreenshotting,
              child: Column(children: [
                SwitchListTile.adaptive(
                    title: Text("Chart Type"),
                    value: model.chartTypeIsLine ?? false,
                    onChanged: (newValue) {
                      model.chartTypeIsLine = newValue;
                      isPlaying = false;
                      setState(() {});
                    }),
                SwitchListTile.adaptive(
                    title: Text("Rep Max not Weight Max"),
                    value: model.isRepNotWeight ?? false,
                    onChanged: (newValue) {
                      model.isRepNotWeight = newValue;
                      isPlaying = false;
                      setState(() {});
                    }),
              ]),
            ),
            // see if it already exists. if it does, just build the chart. otherwise, futurebuild it.
            // this is because we have Playing that forces setState repeatedly and don't want to have the future fire again and again
            // which apparently happens even if we directly return something inside the future.
            Provider.of<Prs>(context, listen: false).allPrs != null
                ? _buildCharts(model)
                : FutureBuilder(
                    future: prettyPrGraphsController.getAllPrs(
                        context, model.selectedLift, model.isRepNotWeight),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return _buildCharts(model);
                      } else {
                        return Text("Loading...");
                      }
                    }),
          ],
        );
      });
    });
  }

  Future<dynamic> refreshState(model) async {
    setState(() {});
    await Future<dynamic>.delayed(
        animationDuration + const Duration(milliseconds: 50));
    if (isPlaying) {
      model.currentIteratorDistinctPrs++;
      if (isPlaying &&
          model.currentIteratorDistinctPrs < model.maxDistinctPrsInAnyBucket) {
        refreshState(model);
      }
      // this sets us back to current PRs. might not be a problem i guess, cuz it should be the same, but
      // think about it I guess
      else {
        isPlaying = false;
        setState(() {});
      }
      /*else {
        model.currentIteratorDistinctPrs = 0;
      }*/
    }
  }
}
