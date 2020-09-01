// may want this to be a changeNotifier just to simplify things..

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
part 'lifter_weights.g.dart';

@JsonSerializable()
//@CustomDoubleConverter()
class LifterWeights extends ChangeNotifier {
  int barWeight;
  Map<dynamic, int> plates;

  LifterWeights({
    this.barWeight,
    this.plates,
  });

  void updateBarWeight(int newWeight) {
    barWeight = newWeight;
    print("new bar weight: $barWeight.toString()");
    notifyListeners();
  }

// the bool part of this is hanlded automatically by widgets. probably cloud too but just to be safe for now
  bool updatePlate({double plate, int plateCount}) {
    if (plates == null) {
      plates = new Map<double, int>();
    } else if (plates.containsKey(plate)) {
      // if we already have this plate and it's plateCount is equal to what we passed in, return false <probably antipatter>
      if (plates[plate] == plateCount) {
        return false;
      }
    }
    // otherwise upsert the plate
    plates[plate] = plateCount;
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
   }
   
   def change_making(coins, n: int):
    """This function assumes that all coins are available infinitely.
    n is the number to obtain with the fewest coins.
    coins is a list or tuple with the available denominations.
    """
    m = _get_change_making_matrix(coins, n)
    for c in range(1, len(coins) + 1):
        for r in range(1, n + 1):
            # Just use the coin coins[c - 1].
            if coins[c - 1] == r:
                m[c][r] = 1
            # coins[c - 1] cannot be included.
            # Use the previous solution for making r,
            # excluding coins[c - 1].
            elif coins[c - 1] > r:
                m[c][r] = m[c - 1][r]
            # coins[c - 1] can be used.
            # Decide which one of the following solutions is the best:
            # 1. Using the previous solution for making r (without using coins[c - 1]).
            # 2. Using the previous solution for making r - coins[c - 1] (without
            #      using coins[c - 1]) plus this 1 extra coin.
            else:
                m[c][r] = min(m[c - 1][r], 1 + m[c][r - coins[c - 1]])
    return m[-1][-1]
   
   */

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
