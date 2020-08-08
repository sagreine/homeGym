// may want this to be a changeNotifier just to simplify things..

import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
part 'lifter_weights.g.dart';

@JsonSerializable()
class LifterWeights extends ChangeNotifier {
  double barWeight;
  // this is an object of itself......... way simpler too...
  List<double> plates; // = [2.5, 2.75, 5, 10, 11, 22, 25, 33, 35, 44, 45];
  List<int> plateCount; // = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];

  LifterWeights({
    this.barWeight,
    this.plates,
    this.plateCount,
  });

  updateBarWeight(double newWeight) {
    barWeight = newWeight;
    notifyListeners();
  }

  bool updatePlate(double _plate, int _plateCount) {
    if (plates == null) {
      plates = new List<double>();
      plateCount = new List<int>();
    } else if (plates.contains(_plate)) {
      // if we already have this plate and it's plateCount is equal to what we passed in, return false
      if (plateCount[plates.indexOf(_plate)] == _plateCount) {
        return false;
      }
      plateCount[plates.indexOf(_plate)] = _plateCount;
    } else {
      plates.add(_plate);
      plateCount.add(_plateCount);
    }
    notifyListeners();
    return true;
  }

  List<Object> get props => [
        barWeight,
        plates,
        plateCount,
      ];

  factory LifterWeights.fromJson(Map<String, dynamic> json) =>
      _$LifterWeightsFromJson(json);

  Map<String, dynamic> toJson() => _$LifterWeightsToJson(this);
}

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

/*



const sumPlates = (plates) => {
  return plates.reduce((acc, plate) => {
    return acc + (plate * 2);
  }, 0);
};

const rack = (targetWeight) => {
  const sortedPlates = PLATES.sort((a, b) => b - a);

  const rackedPlates = sortedPlates.reduce((acc, plate) => {
    if ((BAR + (plate * 2) + sumPlates(acc)) > targetWeight) {
      // Calculate here the closest possible rack weight
      return acc;
    }

    acc.push(plate);

    return acc;
  }, []);

  return {
    targetWeight,
    barbellWeight: BAR + sumPlates(rackedPlates),
    plates: rackedPlates,
  };
};
*/
