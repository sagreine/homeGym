import 'package:flutter/cupertino.dart';
import 'package:home_gym/models/models.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';

part 'exercise.g.dart';

//? not sure

@JsonSerializable()
class ExerciseSet extends ChangeNotifier {
  String videoPath;
  // these will be passed to TV. probably won't live here in the long run tbh.
  String title;
  String description;
  // TV app uses this to pick vidoes - for now
  String type;
  int restPeriodAfter;
  int weight;
  int reps;
  DateTime dateTime;
  bool thisSetPRSet;
  //BuildContext context;

  ExerciseSet({
    //this.context,
    this.videoPath,
    this.title,
    this.description,
    this.restPeriodAfter,
    this.weight,
    this.reps,
    this.thisSetPRSet,
  }) {
    //var day = Provider.of<LifterWeights>(context, listen: false);
    //this.updateExerciseFull(context: context, exerciseTitle: "deadlift");
    this.dateTime = DateTime.now();
    this.type = "/video";
    this.thisSetPRSet = false;
  }

  void updateExerciseFull(
      {@required context,
      String exerciseTitle,
      @required int reps,
      @required double setPct,
      bool thisSetPRSet}) {
    // should be using the controller here instead of doing this...
    // if we passed a title in and there wasn't already a title (that equals this one)
    if (exerciseTitle != null &&
        (this.title == null || this.title != exerciseTitle)) {
      this.title = exerciseTitle;
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
        weight: calculatedWeight,
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
  }) {
    // should handle this another way probably -> controller if nothing else.
    if (title != null) {
      this.title = title;
    }
    if (description != null) {
      this.description = description;
    }
    if (restPeriodAfter != null) {
      this.restPeriodAfter = restPeriodAfter;
    }
    this.weight = weight;
    this.reps = reps;
    if (thisSetPRSet != null) {
      this.thisSetPRSet = thisSetPRSet;
    } else {
      this.thisSetPRSet = false;
    }
    this.type = "video/";
    this.dateTime = DateTime.now();
    notifyListeners();
  }

  factory ExerciseSet.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSetFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseSetToJson(this);

  //@override
  List<Object> get props => [
        videoPath,
        title,
        description,
        type,
        restPeriodAfter,
        reps,
        weight,
        dateTime,
        thisSetPRSet,
      ];
}
