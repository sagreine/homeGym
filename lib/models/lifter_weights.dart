// may want this to be a changeNotifier just to simplify things..

import 'package:json_annotation/json_annotation.dart';
part 'lifter_weights.g.dart';

@JsonSerializable()
class LifterWeights {
  int barWeight = 20;
  List<double> plates = [
    1.25,
    2.5,
    2.5,
    5,
    5,
    10,
    10,
    20,
    20,
  ];

  List<int> plateCount = [2, 2, 2, 2, 2, 2, 2];
  LifterWeights({
    this.barWeight,
    this.plates,
    this.plateCount,
  });

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
class LiftMaxes {
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
