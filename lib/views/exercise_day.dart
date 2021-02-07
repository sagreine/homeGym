import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ExcerciseDayView extends StatefulWidget {
  final // only used in building new programs.
      PickedProgram program;
  final ExerciseDay exerciseDay;
  //final Function() callback;
  ExcerciseDayView({
    this.program,
    this.exerciseDay,
  });

  @override
  _ExcerciseDayViewState createState() => _ExcerciseDayViewState();
}

class _ExcerciseDayViewState extends State<ExcerciseDayView> {
  //ExerciseDay thisDay;
  AdmobBannerSize bannerSize;
  final mainContainerHeight = 100.0;
  bool isBuildingNotUsing = false;
  bool isBuildingFromInput = false;
  PickedProgram program;

  @override
  void initState() {
    super.initState();
    if (widget.program != null) {
      isBuildingNotUsing = true;
      program = widget.program;
    } //else {
    //program = Provider.of<PickedProgram>(context, listen: false);
    //}
    if (widget.exerciseDay != null) {
      isBuildingFromInput = true;
    }

//    isBuildingNotUsing =
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bannerSize = AdmobBannerSize.ADAPTIVE_BANNER(
        width: (MediaQuery.of(context).size.width).toInt());
  }

  buildFAB(BuildContext context, ExerciseDay exerciseDay) {
    return Padding(
        padding: EdgeInsets.only(bottom: (isBuildingNotUsing ? 0 : 70.0)),
        child: FloatingActionButton(
          key: ObjectKey(exerciseDay),
          heroTag: UniqueKey(),
          child: Icon(Icons.add),
          onPressed: () {
            if (exerciseDay == null) {
              exerciseDay = ExerciseDay();
            }
            exerciseDay.addExercise(ExerciseSet());
            //setState(() {});
          },
        ));
  }

  Widget _pickChild({
    @required int index,
    @required bool enabled,
    @required ExerciseDay thisDay,
    @required PickedProgram program,
  }) {
    final ExerciseSet step = thisDay.exercises[index];

    final child = Container(
        //height: 550,
        child: _TimelineStepsChild(
      activity: step,
      enabled: enabled,
      program: program,
      thisDay: thisDay,
      isBuildingNotUsing: isBuildingNotUsing,
      //onCopyCallback: () => setState(() {}),
      thisSetProgressSet:
          step.thisSetProgressSet, //&& (thisDay.updateMaxIfGetReps ?? false),
    ));

    final isFirst = index == 0;
    final isLast = index == (thisDay?.exercises?.length ?? 1) - 1;
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

  bool firstBuild = true;
  int initialOffset = 0;
  @override
  Widget build(BuildContext context) {
    // CONSUMER!!!

    // TODO: put a way to overide this consumer, since we don't always want this - in building a program, when
    // we go to week 2...
    //var exerciseDayBuliding;
    if (isBuildingFromInput && firstBuild) {
      //exerciseDayBuliding = widget.exerciseDay;
      firstBuild = false;
      // this is around a dumb way to tell if we're on the last set / just did the last set
      initialOffset = 0;
    } else {
      initialOffset = 1;
    }

    /*if (program == null) {
      program = Provider.of<PickedProgram>(context, listen: false);
    }*/

    return Consumer<PickedProgram>(builder: (context, programConsumed, child) {
      //thisDay = Provider.of<ExerciseDay>(context, listen: false);
      return Consumer<ExerciseDay>(builder: (context, thisDay, child) {
        // this updates the changenotifier ... so going to cause infinite rebuild?
        /*if (widget.exerciseDay != thisDay) {
        widget.exerciseDay = thisDay;
        widget?.callback?.call();
      }*/
        // if we just did the last set we want to reflect that here, otherwise just use what set it says we're on.
        //setState(() {
        // TODO: this is very stupid. basically, each week has the same ancestor which is no good. so,
        // we pass in each week's ancestor here. so, we have to do this + have to setState everywhere in here to
        // force a rebuild. very, very stupid.
        // still broken: edit, add a week?
        //if (isBuildingFromInput) {
        //thisDay = widget.exerciseDay;
        //}

        //});
        int currentSet = (thisDay.justDidLastSet ?? false)
            ? thisDay.currentSet + 1
            : thisDay.currentSet;
        //isBuildingNotUsing = currentSet == null;
        // jump to the current set
        ScrollController scrollController = ScrollController(
            initialScrollOffset:
                initialOffset * (currentSet ?? 0) * mainContainerHeight,
            keepScrollOffset: true);
        return SizedBox.expand(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      accentColor: const Color(0xFFFCB69F).withOpacity(0.2),
                    ),
                    child: SafeArea(
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        floatingActionButton: buildFAB(context, thisDay),
                        body: Center(
                          child: Column(
                            children: <Widget>[
                              //_Header(),
                              if (!isBuildingNotUsing)
                                Text("Current Set: $currentSet"),
                              if (isBuildingNotUsing)
                                Text("Add, edit, delete sets!"),

                              Expanded(
                                child: ReorderableListView(
                                  scrollController: scrollController,
                                  onReorder: (_oldIndex, _newIndex) {
                                    if (_newIndex > currentSet * 2 - 1) {
                                      //setState(() {
                                      if (_newIndex > _oldIndex) {
                                        _newIndex -= 1;
                                      }

                                      thisDay.insert(
                                          _newIndex ~/ 2,
                                          thisDay.removeAt(_oldIndex ~/ 2),
                                          isBuildingNotUsing);
                                      //thisDay.removeAt();

                                      /*thisDay.exercises.insert(_newIndex ~/ 2,
                                    thisDay.exercises.removeAt(_oldIndex ~/ 2));*/
                                      //});
                                    }
                                  },
                                  children: <Widget>[
                                    for (int i = 0;
                                        i <
                                            (thisDay?.exercises?.length ?? 0) *
                                                2;
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
                                              height: mainContainerHeight,
                                              key: UniqueKey(),
                                              child:
                                                  // this stops them from deleting or reordering the deleted items
                                                  // but need to stop them from dragging not-yet-done items to deleted if we're going to do this.
                                                  IgnorePointer(
                                                ignoring:
                                                    i < currentSet * 2 - 1,
                                                child: Dismissible(
                                                  direction: DismissDirection
                                                      .endToStart,
                                                  // Each Dismissible must contain a Key. Keys allow Flutter to
                                                  // uniquely identify widgets.
                                                  key: UniqueKey(),
                                                  // Provide a function that tells the app
                                                  // what to do after an item has been swiped away.
                                                  // and only allows swipes from not-already-completed items - unnecessary protection if ignorePointer is kept..
                                                  // TODO: could use this to go back to the tab!
                                                  confirmDismiss:
                                                      (direction) async {
                                                    // Remove the item from the data source.
                                                    if (i >=
                                                        currentSet * 2 - 1) {
                                                      if (direction ==
                                                          DismissDirection
                                                              .endToStart) {
                                                        //setState(() {
                                                        // sugar for toInt()
                                                        thisDay
                                                            .removeAt((i ~/ 2));

                                                        //thisDay.exercises
                                                        //  .removeAt((i ~/ 2));
                                                        // show snakcbar?
                                                        // });
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
                                                  background: Container(
                                                      color: Colors.red),

                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: _pickChild(
                                                          thisDay: thisDay,
                                                          index: i ~/ 2,
                                                          // this is disgusting. be an adult.
                                                          program: program ??
                                                              programConsumed,
                                                          enabled: i >
                                                              currentSet * 2 -
                                                                  1,
                                                        ),
                                                      ),
                                                      InkWell(
                                                        child: Icon(
                                                          Icons.delete_sweep,
                                                          // for disabled ones, gray them out a little
                                                          color: i >
                                                                  currentSet *
                                                                          2 -
                                                                      1
                                                              ? Colors.red
                                                              : Colors.red
                                                                  .withOpacity(
                                                                      0.6),
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
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(top: 5, bottom: 10.0),
                                child: isBuildingNotUsing
                                    ? Container()
                                    : AdmobBanner(
                                        adUnitId: Provider.of<OldVideos>(
                                                context,
                                                listen: false)
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
          ),
        );
      });
    });
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

class EditExerciseScreenArguments {
  final ExerciseSet activity;
  final bool isBuildingNotUsing;
  final bool isExerciseFromMainLiftPRogram;

  EditExerciseScreenArguments(
      {this.activity,
      this.isBuildingNotUsing = false,
      @required this.isExerciseFromMainLiftPRogram});
}

class _TimelineStepsChild extends StatelessWidget {
  const _TimelineStepsChild({
    Key key,
    this.activity,
    @required this.enabled,
    @required this.thisSetProgressSet,
    @required this.thisDay,
    @required this.isBuildingNotUsing,
    @required this.program,
    //@required this.onCopyCallback
  }) : super(key: key);

  final ExerciseSet activity;
  final bool enabled;
  final bool thisSetProgressSet;
  final ExerciseDay thisDay;
  final bool isBuildingNotUsing;
  final PickedProgram program;
  //final Function onCopyCallback;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 15,
      child: ClipPath(
        clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)))),
        child: Container(
          decoration: BoxDecoration(
            //color: Colors.orange,
            border: thisSetProgressSet
                ? Border.all(
                    //bottom: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.green[900]
                        : Colors.greenAccent,
                    //Color.fromRGBO(0, 83, 79, 1),
                    width: 3.0 //, width: 7.0)//,
                    //top: BorderSide(
                    //  color: Color.fromRGBO(0, 83, 79, 1), width: 7.0),
                    )
                : null,
            color: enabled
                ? Colors.transparent
                : Colors.grey[500].withOpacity(0.7),
          ),
          padding: const EdgeInsets.all(2.0),
          height: 95,
          child: ListTile(
              //visualDensity: ,
              isThreeLine: true,
              // put in a container to force the text to wrap, not take the whole thing
              leading:
                  //ConstrainedBox(
                  //constraints: const BoxConstraints.tightFor(width: 130),
                  FractionallySizedBox(
                widthFactor: 0.25,
                child: Text(
                  activity.title ?? "Exercise",
                  maxLines: 4,
                  textAlign: TextAlign.left,
                  //textWidthBasis: TextWidthBasis.parent,
                  style: TextStyle(
                    //color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
              title: Text(
                activity.reps == null
                    ? "Reps and Weight"
                    : activity.reps.toString() +
                        // if the weight is zero, don't display any weight and display 'reps' instead
                        ((activity.weight != 0 && activity.weight != null)
                            ? "x" +
                                (activity.thisSetPRSet ? "PRx" : "") +
                                activity.weight.toString()
                            : " reps" +
                                (activity.thisSetPRSet ? " (xPR)" : "")),
                textAlign: TextAlign.left,
                softWrap: false,
                style: TextStyle(
                  //color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.visible,
              ),
              subtitle: Text(
                activity.description ?? "Plates go here",
                maxLines: 4,
                overflow: TextOverflow.fade,
              ),
              trailing: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Visibility(
                      child: IconButton(
                          //
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            // TODO this is not working - in that edits are automatically saving even without FAB
                            var activityStart =
                                ExerciseSet.deepCopy(copyingFrom: activity);
                            await Navigator.pushNamed(context, '/exercise',
                                arguments: EditExerciseScreenArguments(
                                    activity: activity,
                                    isBuildingNotUsing: isBuildingNotUsing,
                                    isExerciseFromMainLiftPRogram:
                                        program?.isMainLift ?? false));
                            // tell everyone that ExerciseDay has been changed so they rebuild. bad, but a hack around
                            // it for the edit program page which otherwise wouldnt see these changes.
                            if (activityStart != activity) {
                              thisDay.tempNotify();
                            }

// TODO this should work, but there is an issue and it doesn't. a consumer that rebuilds overwrites the updates in a build? or something. on do_lift_view...
                            /*var activityStart =
                                ExerciseSet.deepCopy(copyingFrom: activity);
                            final updatedActivity = await Navigator.pushNamed(
                                context, '/exercise',
                                arguments: EditExerciseScreenArguments(
                                    activity: activityStart,
                                    isBuildingNotUsing: isBuildingNotUsing,
                                    isExerciseFromMainLiftPRogram:
                                        program?.isMainLift ?? false));
                            // tell everyone that ExerciseDay has been changed so they rebuild. bad, but a hack around
                            // it for the edit program page which otherwise wouldnt see these changes.
                            if (activity != updatedActivity &&
                                updatedActivity != null) {
                              thisDay.updateSet(activity, updatedActivity);

                              //thisDay.updateActivity(updatedActivity);
                              //updateActivity(activity, updatedActivity);
                              //thisDay.tempNotify();
                            }*/

                            //setState?? isnt' a stateful widget though...
                            // shouldn't be necessary becuase the parent of this is a Consumer of thisDay
                            // and activity should be it's child.
                            // but that requires using notifyListeners()
                          }),
                      visible: enabled),
                  Visibility(
                    child: IconButton(
                        icon: Icon(Icons.content_copy),
                        onPressed: () {
                          //var thisDay =
                          //Provider.of<ExerciseDay>(context, listen: false);
                          // TODO: stop doing this. lazy, sloowwww, lose type... just build a deep copy function in the model
                          // we have deepCopy already don't we?
                          thisDay.insert(
                              thisDay.exercises.indexOf(activity),
                              ExerciseSet.fromJson(activity.toJson()),
                              isBuildingNotUsing);
                          //onCopyCallback();

                          /*thisDay.exercises.insert(
                              thisDay.exercises.indexOf(activity), activity);*/
                        }),
                    visible: enabled,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                          child: Text("RPR!"),
                          visible: activity.wasRepPRSet ?? false),
                      Visibility(
                          child: Text("WPR!"),
                          visible: activity.wasWeightPRSet ?? false),
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
