import 'package:flutter/cupertino.dart';
import 'package:home_gym/models/models.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';

part 'exercise.g.dart';

//? not sure

@JsonSerializable()
class ExerciseSet extends ChangeNotifier {
  // this will only be used on mobile - previously i thought that, but easiest to keep it and write it to db alongside this..

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
  //BuildContext context;

  ExerciseSet({
    //this.context,
    this.videoPath,
    this.title,
    this.description,
    this.restPeriodAfter,
    this.weight,
    this.reps,
  }) {
    //var day = Provider.of<LifterWeights>(context, listen: false);
    //this.updateExerciseFull(context: context, exerciseTitle: "deadlift");
    this.dateTime = DateTime.now();
    this.type = "/video";
  }

  void updateExerciseFull(
      {@required context, String exerciseTitle, @required double setPct}) {
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
    double targetWeight = (setPct * trainingMax);

    this.updateExercise(
        // reps is a straight pull
        reps: thisDay.reps[thisDay.currentSet],
        weight: targetWeight.toInt(),
        description: "Weight each side: " +
            (thisWeights.pickPlates(targetWeight: targetWeight)[0])
                .round()
                .toString()
        // + nextExercise(context),
        );
    //formControllerTitle
    //formControllerDescription.text = exercise.description;
    //formControllerReps.text = exercise.reps.toString();
    //formControllerWeight.text = exercise.weight.toString();

    // this is a hack for now.
  }

  void updateExercise({
    String title,
    String description,
    int restPeriodAfter,
    int weight,
    int reps,
  }) {
    // should hanlde this another way probably -> controller if nothing else.
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
      ];
}
