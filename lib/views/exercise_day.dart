import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ExcerciseDayView extends StatefulWidget {
  @override
  _ExcerciseDayViewState createState() => _ExcerciseDayViewState();
}

class _ExcerciseDayViewState extends State<ExcerciseDayView> {
  ExerciseDay thisDay;
  AdmobBannerSize bannerSize;

  @override
  void initState() {
    super.initState();
    bannerSize = AdmobBannerSize.FULL_BANNER;
  }

  Widget _pickChild({
    @required int index,
    @required bool enabled,
  }) {
    final ExerciseSet step = thisDay.exercises[index];

    final child = Container(
        child: _TimelineStepsChild(
      activity: step,
      enabled: enabled,
      thisSetProgressSet: step.thisSetProgressSet && thisDay.updateMaxIfGetReps,
    ));

    final isFirst = index == 0;
    final isLast = index == thisDay.exercises.length - 1;
    double indicatorY;
    if (isFirst) {
      indicatorY = 0.2;
    } else if (isLast) {
      indicatorY = 0.8;
    } else {
      indicatorY = 0.5;
    }

    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineX: 0.1,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 40,
        height: 40,
        indicatorY: indicatorY,
        // don't need to pass step if we do away with the color circle...
        indicator: _TimelineStepIndicator(
          index: index,
        ),
      ),
      topLineStyle: LineStyle(
        width: 5,
      ),
      rightChild: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    thisDay = Provider.of<ExerciseDay>(context, listen: false);
    // if we just did the last set we want to reflect that here, otherwise just use what set it says we're on.
    int currentSet =
        thisDay.justDidLastSet ? thisDay.currentSet + 1 : thisDay.currentSet;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: Container(
            /*decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFCCCA9),
            Color(0xFFFFA578),
          ],
        ),
      ),*/
            child: Theme(
              data: Theme.of(context).copyWith(
                accentColor: const Color(0xFFFCB69F).withOpacity(0.2),
              ),
              child: SafeArea(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(
                    child: Column(
                      children: <Widget>[
                        //_Header(),
                        Text("Current Set: $currentSet"),
                        Expanded(
                          child: ReorderableListView(
                            onReorder: (_oldIndex, _newIndex) {
                              if (_newIndex > currentSet * 2 - 1) {
                                setState(() {
                                  if (_newIndex > _oldIndex) {
                                    _newIndex -= 1;
                                  }
                                  // if we just changed the progress set, we need to update to account for that.
                                  // TODO this has not been tested at all.
                                  // TODO: very much not view code....
                                  // TODO: dead code...
                                  if (thisDay.progressSet < _oldIndex ~/ 2 &&
                                      thisDay.progressSet >= _newIndex ~/ 2) {
                                    thisDay.progressSet++;
                                  } else if (thisDay.progressSet ==
                                      _oldIndex ~/ 2) {
                                    if (thisDay.progressSet > _newIndex ~/ 2) {
                                      thisDay.progressSet--;
                                    } else if (thisDay.progressSet <
                                        _newIndex ~/ 2) {
                                      thisDay.progressSet++;
                                    }
                                  } else if (thisDay.progressSet >
                                          _oldIndex ~/ 2 &&
                                      thisDay.progressSet <= _newIndex ~/ 2) {
                                    thisDay.progressSet--;
                                  }
                                  thisDay.insert(
                                      _newIndex ~/ 2,
                                      thisDay.exercises
                                          .removeAt(_oldIndex ~/ 2));
                                  //thisDay.removeAt();

                                  /*thisDay.exercises.insert(_newIndex ~/ 2,
                                    thisDay.exercises.removeAt(_oldIndex ~/ 2));*/
                                });
                              }
                            },
                            children: <Widget>[
                              for (int i = 0;
                                  i < thisDay.exercises.length * 2;
                                  i++)
                                // put each item and a divider -> the only visible divider is the one that shows
                                // which set we're currently on.
                                i.isOdd
                                    ? Divider(
                                        key: UniqueKey(),
                                        thickness: 2,
                                        height: 1,
                                        color: i == currentSet * 2 - 1
                                            ? Colors.blueGrey
                                            : Colors.transparent,
                                      )
                                    : Container(
                                        /*color: i > thisDay.currentSet * 2 - 1
                                            ? Colors.transparent
                                            : Colors.grey[500].withOpacity(.7),*/
                                        height: 75,
                                        key: UniqueKey(),
                                        child:
                                            // this stops them from deleting or reordering the deleted items
                                            // but need to stop them from dragging not-yet-done items to deleted if we're going to do this.
                                            IgnorePointer(
                                          ignoring: i < currentSet * 2 - 1,
                                          child: Dismissible(
                                            direction:
                                                DismissDirection.endToStart,
                                            // Each Dismissible must contain a Key. Keys allow Flutter to
                                            // uniquely identify widgets.
                                            key: UniqueKey(),
                                            // Provide a function that tells the app
                                            // what to do after an item has been swiped away.
                                            // and only allows swipes from not-already-completed items - unnecessary protection if ignorePointer is kept..
                                            // TODO: could use this to go back to the tab!
                                            confirmDismiss: (direction) async {
                                              // Remove the item from the data source.
                                              if (i >= currentSet * 2 - 1) {
                                                if (direction ==
                                                    DismissDirection
                                                        .endToStart) {
                                                  setState(() {
                                                    // sugar for toInt()
                                                    thisDay.remove((i ~/ 2));
                                                    //thisDay.exercises
                                                    //  .removeAt((i ~/ 2));
                                                    // show snakcbar?
                                                    // if we just changed the progress set order by deleting one..., we need to update to account for that.
                                                    // TODO this has not been tested at all. very much not view code....
                                                    if (i ~/ 2 <
                                                        thisDay.progressSet) {
                                                      thisDay.progressSet--;
                                                    }
                                                  });
                                                  // this would be after it already dismisses, so stop that!
                                                  // https://gist.github.com/Nash0x7E2/08acca529096d93f3df0f60f9c034056
                                                }
                                                return true;
                                              } else {
                                                return false;
                                              }

                                              //else {
                                              //widget.callback();
                                              //}
                                            },
                                            // Show a red background as the item is swiped away.
                                            background:
                                                Container(color: Colors.red),

                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Expanded(
                                                  child: _pickChild(
                                                    index: i ~/ 2,
                                                    enabled:
                                                        i > currentSet * 2 - 1,
                                                  ),
                                                ),
                                                InkWell(
                                                  child: Icon(
                                                    Icons.delete_sweep,
                                                    color: Colors.red,
                                                    size: 35,
                                                  ),
                                                  //onTap: () {
                                                  //setState(() {
                                                  //thisDay.activities.removeAt(i);
                                                  // snackbar show..
                                                  //});
                                                  //},
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 20.0),
                          child: AdmobBanner(
                            adUnitId:
                                Provider.of<OldVideos>(context, listen: false)
                                    .getBannerAdUnitId(),
                            adSize: bannerSize,
                            /* listener: (AdmobAdEvent event, Map<String, dynamic> args) {
                  handleEvent(event, args, 'Banner');
                },*/
                            onBannerCreated:
                                (AdmobBannerController controller) {
                              // Dispose is called automatically for you when Flutter removes the banner from the widget tree.
                              // Normally you don't need to worry about disposing this yourself, it's handled.
                              // If you need direct access to dispose, this is your guy!
                              // controller.dispose();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineStepIndicator extends StatelessWidget {
  const _TimelineStepIndicator({Key key, this.index}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        //step.lifepoints <= 0 ? Colors.greenAccent : Colors.redAccent,
        //color: Color(0xFFCB8421),
        color: Colors.blueGrey,
      ),
      child: Center(
        child: Text(
          index.toString(),
          style: GoogleFonts.architectsDaughter(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _TimelineStepsChild extends StatelessWidget {
  const _TimelineStepsChild(
      {Key key,
      this.activity,
      @required this.enabled,
      @required this.thisSetProgressSet})
      : super(key: key);

  final ExerciseSet activity;
  final bool enabled;
  final bool thisSetProgressSet;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 15,
      child: Container(
        color: enabled ? Colors.transparent : Colors.grey[500].withOpacity(0.7),
        padding: const EdgeInsets.all(4.0),
        height: 200,
        child: ListTile(
          leading: Text(activity.title,
              textAlign: TextAlign.left,
              style: TextStyle(
                //color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
          title: Text(
              activity.reps.toString() +
                  // if the weight is zero, don't display any weight and display 'reps' instead
                  (activity.weight != 0
                      ? "x" +
                          (activity.thisSetPRSet ? "PRx" : "") +
                          activity.weight.toString()
                      : " reps"),
              textAlign: TextAlign.left,
              style: TextStyle(
                //color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
          subtitle: Text(activity.description),
          trailing: thisSetProgressSet
              ? Icon(Icons.star)
              : Container(
                  height: 0,
                  width: 0,
                ),
        ),
      ),
    );
  }
}
