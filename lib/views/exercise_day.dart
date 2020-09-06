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

  Widget _pickChild(int index) {
    final ExerciseSet step = thisDay.exercises[index];

    final child = Container(
        child: _TimelineStepsChild(
      activity: step,
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
                        Expanded(
                          child: ReorderableListView(
                            onReorder: (_oldIndex, _newIndex) {
                              setState(() {
                                if (_newIndex > _oldIndex) {
                                  _newIndex -= 1;
                                }
                                thisDay.exercises.insert(_newIndex,
                                    thisDay.exercises.removeAt(_oldIndex));
                              });
                            },
                            children: <Widget>[
                              for (int i = 0; i < thisDay.exercises.length; i++)
                                Container(
                                  height: 75,
                                  key: UniqueKey(),
                                  child: Dismissible(
                                    direction: DismissDirection.endToStart,
                                    // Each Dismissible must contain a Key. Keys allow Flutter to
                                    // uniquely identify widgets.
                                    // this isn't unique though... UniqueKey()
                                    key: UniqueKey(),
                                    // Provide a function that tells the app
                                    // what to do after an item has been swiped away.
                                    onDismissed: (direction) {
                                      // Remove the item from the data source.

                                      if (direction ==
                                          DismissDirection.endToStart) {
                                        setState(() {
                                          thisDay.exercises.removeAt(i);
                                          // show snakcbar
                                        });
                                        // this would be after it already dismisses, so stop that!
                                        // https://gist.github.com/Nash0x7E2/08acca529096d93f3df0f60f9c034056
                                      }
                                      //else {
                                      //widget.callback();
                                      //}
                                    },
                                    // Show a red background as the item is swiped away.
                                    background: Container(color: Colors.red),

                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Expanded(
                                          child: _pickChild(i),
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
                            ],
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
        color: Color(0xFFCB8421),
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
  const _TimelineStepsChild({Key key, this.activity}) : super(key: key);

  final ExerciseSet activity;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 15,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        height: 200,
        child: ListTile(
            leading: Text(activity.title,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
            title: Text(
                activity.reps.toString() + "x" + activity.weight.toString(),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
            subtitle: Text(activity.description)),
      ),
    );
  }
}
