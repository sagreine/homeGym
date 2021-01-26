import 'package:flutter/cupertino.dart';
import 'package:home_gym/models/models.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';

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
  int indexForOrdering;

  bool hasBeenUpdated;
  @JsonKey(ignore: true)
  String id;

  // for searching, we'll popluate with keywords based on lift title
  static List<String> makeKeywords(String name) {
    List<String> arrName = [];
    String curName = '';
    // add the null string.
    arrName.add(curName);
    name.split('').forEach((element) {
      curName += element.toLowerCase();
      arrName.add(curName);
    });
    return arrName;
  }

  // TODO: pro tip, construct in the constructor instead of some random function. good god this is garbage
  ExerciseSet(
      {
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
      this.id,
      this.basedOnBarbellWeight = false,
      this.basedOnPercentageOfTM = false,
      this.indexForOrdering,
      this.percentageOfTM})
      : prescribedReps = reps {
    //var day = Provider.of<LifterWeights>(context, listen: false);
    //this.updateExerciseFull(context: context, exerciseTitle: "deadlift");
    if (this.dateTime == null) {
      this.dateTime = DateTime.now();
    }
    this.type = "/video";
    this.thisSetPRSet = thisSetPRSet ?? false;
    this.thisSetProgressSet = thisSetProgressSet ?? false;
    if (hasBeenUpdated == null) {
      this.hasBeenUpdated = false;
    }
    //this.prescribedReps = reps;
  }
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
      this.duration,
      this.hasBeenUpdated = false,
      this.id,
      this.indexForOrdering,
      this.basedOnBarbellWeight = false,
      this.basedOnPercentageOfTM = false,
      this.percentageOfTM,
      this.type = "/video",
      bool isMainLift = false,
      String lift})
      : prescribedReps = reps {
    if (this.dateTime == null) {
      this.dateTime = DateTime.now();
    }
    //if (this.basedOnPercentageOfTM ?? false) {}

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
    var liftCheck = lift ?? "Squat";
    // TODO: this only supports 'Main' days. add support to non-string... also use reusableApp list.
    int liftNum = ["Squat", "Press", "Deadlift", "Bench"].indexOf(liftCheck);
    if (isMainLift ?? false) {
      //for (int i = 0; i < lifts.length; ++i) {
      //lifts.forEach((element) {
      if (title.contains('|')) {
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
  }

  void updateExerciseFull(
      {@required context,
      String exerciseTitle,
      @required int reps,
      @required double setPct,
      bool thisSetPRSet,
      bool thisSetProgressSet,
      String id}) {
    // should be using the controller here instead of doing this...
    // if we passed a title in and there wasn't already a title (that equals this one)
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
    // some sets are PR sets, if the week has them and we're currently on the progress set.
    // this is really stupid. obviously not right, put it in the db...
    //bool thisSetPRSet =
    //(thisDay.prSetWeek && plannedSet == thisDay.progressSet);
    switch (this.title.toLowerCase()) {
      case "deadlift":
        trainingMax = (thisMax.deadliftMax.toDouble() * thisDay.trainingMax);
        break;
      case "bench":
        trainingMax = (thisMax.benchMax.toDouble() * thisDay.trainingMax);
        break;
      case "press":
        trainingMax = (thisMax.pressMax.toDouble() * thisDay.trainingMax);
        break;
      case "squat":
        trainingMax = (thisMax.squatMax.toDouble() * thisDay.trainingMax);
        break;
    }
    int targetWeight = (setPct * trainingMax).floor();

    // Now though, we can only lift based on what weights we actually own.
    // so, calculate that based on our weight and updated accordingly
    // TODO: this higlights the absurdity of using ints vs doubles....
    int calculatedWeight = thisWeights
        .getPickedOverallTotal(targetWeight: targetWeight, lift: this.title)
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
                targetWeight: targetWeight, lift: this.title)));
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
    // should handle this another way probably -> controller if nothing else.
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
    } else {
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
        duration
      ];
}
