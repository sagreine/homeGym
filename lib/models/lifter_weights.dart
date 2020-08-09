// may want this to be a changeNotifier just to simplify things..

import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
part 'lifter_weights.g.dart';

@JsonSerializable()
//@CustomDoubleConverter()
class LifterWeights extends ChangeNotifier {
  double barWeight;
  Map<dynamic, int> plates;

  LifterWeights({
    this.barWeight,
    this.plates,
  });

  void updateBarWeight(double newWeight) {
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

/*
  Set<dynamic> sumPlates = (plates) => {
   plates.reduce((acc, plate) => {
     acc + (plate * 2)
  }, 0)
};*/
/*
   get_plate_picking_matrix(Map<dynamic, int> plates, int targetWeight){
    var m = 
    
    [[0 for _ in range(targetWeight + 1)] for _ in range(len(plates) + 1)]


    for i in range(1, targetWeight + 1):
        m[0][i] = float('inf')  // By default there is no way of making change
    return m;
   }*/

  List<double> pickPlates({double targetWeight}) {
    return [(targetWeight - barWeight) / 2];
    /*
    double weightEachSide = (targetWeight - barWeight) / 2;
var sortedPlates;
var rackedPlates;
    List<double> tempPlates = new List.from(plates.keys.toList());                        
    List<int> tempPlateCount = new List.from(plates.values.toList()); 
    tempPlates.sort((b, a) => a.compareTo(b));

 var rack = (targetWeight) => {    
    rackedPlates = tempPlates.reduce((acc, plate) => {
    if ((barWeight + (plate * 2) + sumPlates(acc)) > targetWeight) {
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
  }

  List<Object> get props => [
        barWeight,
        plates,
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
