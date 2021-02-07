import 'package:flutter/cupertino.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';
import 'package:quiver/core.dart';

part 'exercise.g.dart';

//? not sure

@JsonSerializable()
class ExerciseSet extends ChangeNotifier {
  String videoPath;
  String thumbnailPath;
  double aspectRatio;
  // these will be passed to TV. probably won't live here in the long run tbh.
  String title;
  String description;
  // TV app uses this to pick vidoes - for now
  String type;
  int restPeriodAfter;
  int weight;
  int reps;
  final int prescribedReps;
  double duration;
  List<String> keywords;
  DateTime dateTime;
  bool basedOnBarbellWeight;
  //Barbell barbell;
  bool basedOnPercentageOfTM;
  double percentageOfTM;
  bool thisSetPRSet;
  bool thisSetProgressSet;
  bool wasWeightPRSet;
  bool wasRepPRSet;
  bool thisIsRPESet;
  bool thisIsMainSet;
  int indexForOrdering;
  // this is set as an index of ReusableWidgets.list
  int whichBarbellIndex;
  int whichLiftForPercentageofTMIndex;
  int rpe;
  // either of these mean that the prescribed weight is null (it can't be either %TM or RPE-based and have a prescribed weight)
  get noPrescribedWeight => (basedOnPercentageOfTM || thisIsRPESet == true);

  bool hasBeenUpdated;
  @JsonKey(ignore: true)
  String id;

  bool operator ==(o) =>
      identical(this, o) ||
      o is ExerciseSet &&
          title == o.title &&
          reps == o.reps &&
          description == description &&
          restPeriodAfter == o.restPeriodAfter &&
          weight == o.weight &&
          prescribedReps == prescribedReps &&
          basedOnBarbellWeight == o.basedOnBarbellWeight &&
          basedOnPercentageOfTM == o.basedOnPercentageOfTM &&
          percentageOfTM == o.percentageOfTM &&
          thisSetPRSet == o.thisSetPRSet &&
          thisSetProgressSet == o.thisSetProgressSet &&
          thisIsRPESet == o.thisIsRPESet &&
          thisIsMainSet == o.thisIsMainSet &&
          indexForOrdering == o.indexForOrdering &&
          whichBarbellIndex == o.whichBarbellIndex &&
          whichLiftForPercentageofTMIndex ==
              o.whichLiftForPercentageofTMIndex &&
          rpe == o.rpe;

  int get hashCode => hash4(
      hash4(
        title,
        reps,
        description,
        restPeriodAfter,
      ),
      hash4(
        weight,
        prescribedReps,
        basedOnBarbellWeight,
        basedOnPercentageOfTM,
      ),
      hash4(
        percentageOfTM,
        thisSetPRSet,
        thisSetProgressSet,
        thisIsMainSet,
      ),
      hash4(thisIsRPESet, indexForOrdering, whichBarbellIndex,
          hash2(whichLiftForPercentageofTMIndex, rpe)));

  // for searching, we'll popluate with keywords based on lift title
  static List<String> makeKeywords(String name) {
    List<String> arrName = [];
    if (name == null) {
      return arrName;
    }
    String curName = '';
    // add the null string.
    arrName.add(curName);
    name?.split('')?.forEach((element) {
      curName += element.toLowerCase();
      arrName.add(curName);
    });
    return arrName;
  }

  // TODO: pro tip, construct in the constructor instead of some random function. good god this is garbage
  ExerciseSet({
    //this.context,
    this.videoPath,
    this.thumbnailPath,
    this.title,
    this.description,
    this.restPeriodAfter,
    this.weight,
    this.reps,
    // read the pro tip above and realize this final variable setting is one (of many) reasons...
    this.thisSetPRSet,
    this.aspectRatio,
    this.dateTime,
    this.thisSetProgressSet,
    this.wasWeightPRSet,
    this.wasRepPRSet,
    this.duration,
    this.hasBeenUpdated,
    this.thisIsMainSet,
    this.type,
    this.keywords,
    this.id,
    this.basedOnBarbellWeight = false,
    this.basedOnPercentageOfTM = false,
    this.indexForOrdering,
    this.percentageOfTM,
    this.thisIsRPESet = false,
    this.whichBarbellIndex,
    this.whichLiftForPercentageofTMIndex,
    this.rpe,
  }) : prescribedReps = reps {
    //var day = Provider.of<LifterWeights>(context, listen: false);
    //this.updateExerciseFull(context: context, exerciseTitle: "deadlift");
    if (this.dateTime == null) {
      this.dateTime = DateTime.now();
    }
    this.type = "/video";
    this.thisSetPRSet = thisSetPRSet ?? false;
    this.thisSetProgressSet = thisSetProgressSet ?? false;
    this.thisIsMainSet = thisIsMainSet ?? false;
    if (hasBeenUpdated == null) {
      this.hasBeenUpdated = false;
    }
    //this.prescribedReps = reps;
  }

  ExerciseSet.deepCopy({ExerciseSet copyingFrom})
      : this(
          videoPath: copyingFrom.videoPath,
          thumbnailPath: copyingFrom.thumbnailPath,
          aspectRatio: copyingFrom.aspectRatio,
          // these will be passed to TV. probably won't live here in the long run tbh.
          title: copyingFrom.title,
          description: copyingFrom.description,
          // TV app uses this to pick vidoes - for now
          type: copyingFrom.type,
          restPeriodAfter: copyingFrom.restPeriodAfter,
          weight: copyingFrom.weight,
          reps: copyingFrom.reps,
          duration: copyingFrom.duration,
          keywords: copyingFrom.keywords,
          thisIsMainSet: copyingFrom.thisIsMainSet ?? false,
          dateTime: copyingFrom.dateTime,
          basedOnBarbellWeight: copyingFrom.basedOnBarbellWeight ?? false,
          //Barbell barbell;
          basedOnPercentageOfTM: copyingFrom.basedOnPercentageOfTM ?? false,
          percentageOfTM: copyingFrom.percentageOfTM,
          thisSetPRSet: copyingFrom.thisSetPRSet ?? false,
          thisSetProgressSet: copyingFrom.thisSetProgressSet ?? false,
          wasWeightPRSet: copyingFrom.wasRepPRSet ?? false,
          wasRepPRSet: copyingFrom.wasRepPRSet ?? false,
          thisIsRPESet: copyingFrom.thisIsRPESet ?? false,
          indexForOrdering: copyingFrom.indexForOrdering,
          // this is set as an index of ReusableWidgets.list
          whichBarbellIndex: copyingFrom.whichBarbellIndex,
          whichLiftForPercentageofTMIndex:
              copyingFrom.whichLiftForPercentageofTMIndex,
          rpe: copyingFrom.rpe,

          hasBeenUpdated: copyingFrom.hasBeenUpdated,
          id: copyingFrom.id,
        );
  // TODO: need to actually do the percentages and etc where necessary
  ExerciseSet.fromCustom(
      {this.videoPath,
      this.thumbnailPath,
      this.title,
      this.description,
      this.restPeriodAfter,
      this.weight,
      this.reps,
      // read the pro tip above and realize this final variable setting is one (of many) reasons...
      this.thisSetPRSet = false,
      this.aspectRatio,
      this.dateTime,
      this.thisSetProgressSet = false,
      this.wasWeightPRSet,
      this.wasRepPRSet,
      this.thisIsMainSet,
      this.duration,
      this.hasBeenUpdated = false,
      this.id,
      this.indexForOrdering,
      this.basedOnBarbellWeight = false,
      @required this.whichBarbellIndex,
      this.basedOnPercentageOfTM = false,
      this.whichLiftForPercentageofTMIndex,
      this.percentageOfTM,
      this.rpe,
      this.thisIsRPESet = false,
      this.type = "/video",
      bool isMainLift = false,
      @required BuildContext context,
      String lift})
      : prescribedReps = reps {
    if (this.dateTime == null) {
      this.dateTime = DateTime.now();
    }
    /*this.title = title;
    this.description = description;
    this.restPeriodAfter = restPeriodAfter;
    this.weight = weight;
    this.reps = reps;
    this.thisSetPRSet = thisSetPRSet ?? false;
    this.thisSetProgressSet = thisSetProgressSet ?? false;

    this.hasBeenUpdated = hasBeenUpdated ?? false;
    this.id = id;
    this.indexForOrdering = indexForOrdering;
    this.basedOnBarbellWeight = basedOnBarbellWeight ?? false;
    this.whichBarbellIndex = whichBarbellIndex;
    this.basedOnPercentageOfTM = basedOnPercentageOfTM ?? false;
    this.whichLiftForPercentageofTMIndex = whichLiftForPercentageofTMIndex;
    this.percentageOfTM = percentageOfTM;
    this.rpe = rpe;
    this.thisIsRPESet = thisIsRPESet;
    */
    //isMainLift = isMainLift ?? false;
    // try out building based on percetnage of training max. god help us
    if (this.basedOnPercentageOfTM ?? false) {
      var tmp = this.title;
      // TODO very stupid, but the thought is when you edit programs and this is a main lift you want to reflect hat.
      if (this.whichLiftForPercentageofTMIndex != -1) {
        updateExerciseFull(
            context: context,
            //TODO: what about the interplay here. e.g. i want 80% of squat 1RM but I'm using the deadlift bar?
            exerciseTitle:
                ReusableWidgets.lifts[this.whichLiftForPercentageofTMIndex],
            indexForPickingBar: this.whichBarbellIndex,
            reps: reps,
            setPct: percentageOfTM / 100,
            thisSetPRSet: thisSetPRSet,
            thisSetProgressSet: thisSetProgressSet,
            isFromCustom: true,
            useBarbellWeight: this.basedOnBarbellWeight,
            id: id);
      }
      this.title = tmp;
    } else if (thisIsRPESet ?? false) {
      this.weight = null;
    }

    // TODO: the order of this does NOT match the controller and is ripe for problems down the line.
    // we need to select an individual lift for each slot. the divider pipe "|" is used for this
    // with them going in order as defined in the pick_day program controller (for now) which is
    // this, but double check:
    // note that the inputs can be 1-4 elements.
    // write this with programming indices makes it easier to think about.......
    // if 1, use for any of the 4 items
    // if 2, use 1 for squat, 2 for press, 1 for deadlift, 2 for bench
    // if 3, use 1 for squat, 2 for press, 1 for deadlift, 3 for bench
    // if 4, use them in order for each item..
    // TODO this is dangerous. if we don't start with a Main lift and start with something with multiple exercises based on the selected main day
    // this is going to leave us with a null
    var liftCheck = lift ?? "Squat";
    // TODO: this only supports 'Main' days. add support to non-string... also use reusableApp list.
    int liftNum = ReusableWidgets.lifts.indexOf(liftCheck);
    if (isMainLift ?? false) {
      //for (int i = 0; i < lifts.length; ++i) {
      //lifts.forEach((element) {
      if (title?.contains('|') ?? false) {
        // a divider means we have 2 items at least
        var count = (title.split("|")).length;
        // for 2 count items, we start from right after the pipe (take the second item) for bench and press. else,
        // for squat and deadlift we start from the start (take the first item).
        if (count == 2) {
          title = title
              .substring(liftNum.isOdd ? title.indexOf("|") + 1 : 0,
                  liftNum.isOdd ? null : title.indexOf("|"))
              .trim();
        } else {
          // could do it in one line with a modified version of this but it's a little harder to read
          //var  itemToTake = element.splitMapJoin("|", onMatch: (m) => '${m.group(0)}', onNonMatch: (m) => "");

          var allItems = title.split("|");
          if (count == 3) {
            var index = 3 % (liftNum + 1);
            // this doesn't work for the 4th one, because of the + 1 above, so fix taht one.
            if (liftNum == 3) {
              --index;
            }
            title = allItems[index].trim();
          } else {
            title = allItems[liftNum].trim();
          }
        }
        // 3 mod 1 for 3
      }
    }
    keywords = makeKeywords(title);
  }
  // TODO: for legacy / stupid reasons this uses strings and title name and shit. rework it to use indices throughout, either here or in controller
  void updateExerciseFull(
      {@required context,
      String exerciseTitle,
      int indexForPickingBar,
      @required int reps,
      @required double setPct,
      bool thisSetPRSet,
      int indexForOrdering,
      bool isFromCustom,
      bool thisSetProgressSet,
      @required bool useBarbellWeight,
      String id}) {
    // should be using the controller here instead of doing this...
    // if we passed a title in and there wasn't already a title (that equals this one)
    // TODO why are we doing this again?
    if (exerciseTitle != null &&
        (this.title == null || this.title != exerciseTitle)) {
      this.title = exerciseTitle;
      keywords = makeKeywords(title);
    }
    var thisDay = Provider.of<ExerciseDay>(context, listen: false);
    var thisMax = Provider.of<LifterMaxes>(context, listen: false);
    // would, when needed, listen because if we update the bar weight we want this update. look into more though.
    var thisWeights = Provider.of<LifterWeights>(context, listen: false);
    // default to 0
    double trainingMax = 0;
    if (indexForOrdering != null) {
      this.indexForOrdering = indexForOrdering;
    }
    // some sets are PR sets, if the week has them and we're currently on the progress set.
    // this is really stupid. obviously not right, put it in the db...
    //bool thisSetPRSet =
    //(thisDay.prSetWeek && plannedSet == thisDay.progressSet);
    var multiplier = (isFromCustom ?? false)
        ?
        //0.0001
        //0.01
        1
        : 1;
    // some sets have an override on percentage of TM. use it if they do.
    switch (this.title.toLowerCase()) {
      case "deadlift":
        trainingMax = (thisMax.deadliftMax.toDouble() *
            (thisDay.trainingMax ?? 1) *
            multiplier);
        break;
      case "bench":
        trainingMax = (thisMax.benchMax.toDouble() *
            (thisDay.trainingMax ?? 1) *
            multiplier);
        break;
      case "press":
        trainingMax = (thisMax.pressMax.toDouble() *
            (thisDay.trainingMax ?? 1) *
            multiplier);
        break;
      case "squat":
        trainingMax = (thisMax.squatMax.toDouble() *
            (thisDay.trainingMax ?? 1) *
            multiplier);
        break;
    }
    int targetWeight = ((setPct ?? 1) * trainingMax).floor();

// Now though, we can only lift based on what weights we actually own - but only if we're doing a barbell lift!
// e.g. maybe they are doing a strongman thing..
    if (useBarbellWeight) {
      // so, calculate that based on our weight and updated accordingly
      // TODO: this higlights the absurdity of using ints vs doubles....
      // for title we pass the name of the bar we are using (for now, eventually we'll convert to using indexes of the standard lifts)
      int calculatedWeight = thisWeights
          .getPickedOverallTotal(
              targetWeight: targetWeight,
              lift: indexForPickingBar == null
                  ? this.title
                  : ReusableWidgets.lifts[indexForPickingBar])
          .toInt();

      if (calculatedWeight < targetWeight) {
        print(
            "Note, we had to pick a lower weight. Targetweight: $targetWeight and picked weight: $calculatedWeight");
      }

      this.updateExercise(
          // reps is a straight pull
          reps: reps,
          thisSetPRSet: thisSetPRSet,
          thisSetProgressSet: thisSetProgressSet,
          weight: calculatedWeight,
          id: id,
          description: "Plates: " +
              (thisWeights.getPickedPlatesAsString(
                  targetWeight: targetWeight,
                  lift: indexForPickingBar == null
                      ? this.title
                      : ReusableWidgets.lifts[indexForPickingBar])));
    }
    // if you aren't using a barbell. really we would ideally want to do the calculation (0 pound barbell) and description update still
    // but that can be a later feature.
    else {
      this.weight = targetWeight;
    }
  }

  void updateExercise({
    String title,
    String description,
    int restPeriodAfter,
    int weight,
    int reps,
    bool thisSetPRSet,
    bool thisSetProgressSet,
    String id,
  }) {
    // should handle this another way probably -> constructor if nothing else.
    if (title != null) {
      this.title = title;
      keywords = makeKeywords(title);
    }
    if (description != null) {
      this.description = description;
    }
    if (restPeriodAfter != null) {
      this.restPeriodAfter = restPeriodAfter;
    }
    if (weight != null) {
      this.weight = weight;
    }
    if (reps != null) {
      this.reps = reps;
    }
    if (thisSetPRSet != null) {
      this.thisSetPRSet = thisSetPRSet;
    } else if (this.thisSetPRSet == null) {
      this.thisSetPRSet = false;
    }
    if (thisSetProgressSet != null) {
      this.thisSetProgressSet = thisSetProgressSet;
    }
    if (restPeriodAfter == null) {
      this.restPeriodAfter = 90;
    }
    if (id != null) {
      this.id = id;
    }

    this.type = "video/";
    this.dateTime = DateTime.now();
    notifyListeners();
  }

  void tempNotify() {}

  factory ExerciseSet.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSetFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseSetToJson(this);
//
  //@override
  List<Object> get props => [
        videoPath,
        thumbnailPath,
        title,
        description,
        type,
        restPeriodAfter,
        reps,
        weight,
        dateTime,
        thisSetPRSet,
        aspectRatio,
        thisSetProgressSet,
        prescribedReps,
        keywords,
        wasRepPRSet,
        wasWeightPRSet,
        thisIsMainSet,
        duration
      ];
}
