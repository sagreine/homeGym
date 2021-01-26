import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

//TODO: implement dispose
class ExerciseDayController {
  buildCustomProgramDay(
      {BuildContext context,
      @required List<ExerciseSet> exerciseSets,
      bool updateMaxIfGetReps}) {
    // at this point we already have the program-level info in.
    // need to populate any day-level info and bring in each individual exercise set

    var day = Provider.of<ExerciseDay>(context, listen: false);
    // note that this is backwards compared to how the default programs work
    // that is, we store it at the exercise set level for custom instead of the program level. if any exercise
    // is set to progress, then we progress.
    // this is possible only if we store every week in the cloud, which we do right now. if we later change to only store a single week
    // will need to change this because week 0 might not be a progress set while week 3 is..
    day.buildCustomDay(
        exerciseSets: exerciseSets,
        updateMaxIfGetReps:
            exerciseSets.any((element) => element.thisSetProgressSet));
  }

  updateDay({
    String lift,
    BuildContext context,
    String program,
    List<int> reps,
    List<int> prSets,
    List<double> percentages,
    List<String> lifts,
    double trainingMaxPct,
    bool updateMaxIfGetReps,
    bool prSetWeek,
    int progressSet,
    List<ExerciseSet> exercises,
  }) {
    var day = Provider.of<ExerciseDay>(context, listen: false);
    // TODO: the order of this does NOT match the controller and is ripe for problems down the line.
    // we need to select an individual lift for each slot. the divider pipe "|" is used for this
    // with them going in order as defined in the pick_day program controller (for now) which is
    // this, but double check: ["Squat", "Deadlift", "Bench", "Press"];
    // note that the inputs can be 1-4 elements.
    // write this with programming indices makes it easier to think about.......
    // if 1, use for any of the 4 items
    // if 2, use 1 for squat, 2 for press, 1 for deadlift, 2 for bench
    // if 3, use 1 for squat, 2 for press, 1 for deadlift, 3 for bench
    // if 4, use them in order for each item..

    // TODO this is dangerous. if we don't start with a Main lift and start with something with multiple exercises based on the selected main day
    // this is going to leave us with a null
    var liftCheck = lift ?? day.lift ?? "Squat";
    int liftNum = ["Squat", "Press", "Deadlift", "Bench"].indexOf(liftCheck);

    for (int i = 0; i < lifts.length; ++i) {
      //lifts.forEach((element) {
      if (lifts[i].contains('|')) {
        // a divider means we have 2 items at least
        var count = (lifts[i].split("|")).length;
        // for 2 count items, we start from right after the pipe (take the second item) for bench and press. else,
        // for squat and deadlift we start from the start (take the first item).
        if (count == 2) {
          lifts[i] = lifts[i]
              .substring(liftNum.isOdd ? lifts[i].indexOf("|") + 1 : 0,
                  liftNum.isOdd ? null : lifts[i].indexOf("|"))
              .trim();
        } else {
          // could do it in one line with a modified version of this but it's a little harder to read
          //var  itemToTake = element.splitMapJoin("|", onMatch: (m) => '${m.group(0)}', onNonMatch: (m) => "");

          var allItems = lifts[i].split("|");
          if (count == 3) {
            var index = 3 % (liftNum + 1);
            // this doesn't work for the 4th one, because of the + 1 above, so fix taht one.
            if (liftNum == 3) {
              --index;
            }
            lifts[i] = allItems[index].trim();
          } else {
            lifts[i] = allItems[liftNum].trim();
          }
        }

        // 3 mod 1 for 3
      }
    }

    day.buildDay(
      lift: lift ?? day.lift ?? "Squat",
      updateMaxIfGetReps: updateMaxIfGetReps,
      lifts: lifts,
      program: program,
      currentSet: 0,
      reps: reps,
      percentages: percentages,
      sets: reps.length,
      prSets: prSets,
      progressSet: progressSet,
      prSetWeek: prSetWeek,
      //trainingMax: trainingMaxPct,
      context: context,
    );
  }

  ExerciseSet nextSet(BuildContext context) {
    var day = Provider.of<ExerciseDay>(context, listen: false);
    day.nextSet();
    return day.exercises[day.currentSet];
  }

  bool areWeOnLastSet(BuildContext context) {
    var day = Provider.of<ExerciseDay>(context, listen: false);
    return day.areWeOnLastSet();
  }

  /*void justDidLastSet(BuildContext context) {
    var day = Provider.of<ExerciseDay>(context, listen: false);
    //day.justDidLastSet();
  }*/
}
