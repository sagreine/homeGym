// may want this to be a changeNotifier just to simplify things..

import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
part 'lifter_weights.g.dart';

@JsonSerializable()
//@CustomDoubleConverter()
class LifterWeights extends ChangeNotifier {
  double barWeight;
  //List<double> plates;
  //List<int> plateCount;
  Map<dynamic, int> plates;

  LifterWeights({
    this.barWeight,
    this.plates,
    //this.plateCount,
  });

  updateBarWeight(double newWeight) {
    barWeight = newWeight;
    notifyListeners();
  }

// the bool part of this is hanlded automatically by widgets. probably cloud too but just to be safe for now
  bool updatePlate(double _plate, int _plateCount) {
    if (plates == null) {
      plates = new Map<double, int>();
    } else if (plates.containsKey(_plate)) {
      // if we already have this plate and it's plateCount is equal to what we passed in, return false
      if (plates[_plate] == _plateCount) {
        return false;
      }
    }
    plates[_plate] = _plateCount;
    notifyListeners();
    return true;
  }

  List<double> pickPlates({BuildContext context, double targetWeight}) {
    return [2.0];
  }

  List<Object> get props => [
        barWeight,
        plates,
        //plateCount,
      ];

  factory LifterWeights.fromJson(Map<String, dynamic> json) =>
      _$LifterWeightsFromJson(json);

  Map<String, dynamic> toJson() => _$LifterWeightsToJson(this);
}

/*
class CustomDoubleConverter implements JsonConverter<Map<double,int>, String> {
  const CustomDoubleConverter();

  @override
  Map<double,int> fromJson(Map<double,int> map, String json) =>
      json == null ? null : double.parse(json[]);

  @override
  String toJson(double object) => object.toString();
}*/

@JsonSerializable()
class LiftMaxes extends ChangeNotifier {
  int deadliftMax;
  int squatMax;
  int benchMax;
  int pressMax;

  LiftMaxes({
    this.deadliftMax,
    this.squatMax,
    this.benchMax,
    this.pressMax,
  });
  List<Object> get props => [
        deadliftMax,
        squatMax,
        benchMax,
        pressMax,
      ];
  factory LiftMaxes.fromJson(Map<String, dynamic> json) =>
      _$LiftMaxesFromJson(json);

  Map<String, dynamic> toJson() => _$LiftMaxesToJson(this);
}
