// may want this to be a changeNotifier just to simplify things..

import 'dart:math';

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
    print("new bar weight: ${barWeight.toString()}");
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
  }

  List<Object> get props => [
        barWeight,
        plates,
      ];

  factory LifterWeights.fromJson(Map<String, dynamic> json) =>
      _$LifterWeightsFromJson(json);

  Map<String, dynamic> toJson() => _$LifterWeightsToJson(this);
}

// stolen shamelessly from https://stackoverflow.com/questions/22128759/atm-algorithm-of-giving-money-with-limited-amount-of-bank-notes
// TODO: discard ones taking more plates than we need along the way for efficiency
// TODO: if we can't make exact change, get as close as possible without going over.
// TODO: return the minimum # of plates - not thinking about future/previous sets at this point...
class CoinChangeLimitedCoins {
  //List<int> values = [10, 20, 50, 100, 200];
  List<int> _closestYet = new List<int>();
  int _closestTotalYet = 0;
  int _platesUsed = 1000;

  void doit() {
    // available plates
    //List<int> values = [5, 10, 25, 35, 45];
    List<int> values = [10, 20, 50, 100, 200];
    // how many plates you have
    //List<int> ammounts = [4, 2, 2, 2, 2];
    List<int> ammounts = [4, 2, 2, 2, 2];
    // always 0s
    List<int> tmpVariation = [0, 0, 0, 0, 0];
    // weight (excluding weight of the bar)
    int targetWeight = 140;
    // start at 0 ALWAYS
    List<List<int>> results =
        solutions(values, ammounts, tmpVariation, targetWeight, 0);
    for (List<int> result in results) {
      print(result);
    }
    print(_closestTotalYet.toString());
    print(_closestYet);
    print(_platesUsed);
  }

  List<List<int>> solutions(
    List<int> values,
    List<int> ammounts,
    List<int> variation,
    int price,
    int position,
  ) {
    List<List<int>> list = new List<List<int>>();

    int value = compute(values, variation);
    if (value < price) {
      for (int i = position; i < values.length; i++) {
        if (ammounts[i] > variation[i]) {
          List<int> newvariation = new List.from(variation);
          newvariation[i]++;
          // in case we can't make a value that is exactly equal to our target value, track along the way
          // for which one is closest so far without going over, and (to break ties) uses the fewest plates
          if (value > this._closestTotalYet ||
              (value == this._closestTotalYet &&
                  variation.fold(0, (previous, current) => previous + current) <
                      this._platesUsed)) {
            _closestTotalYet = value;
            _closestYet = new List.from(variation);
            _platesUsed =
                variation.fold(0, (previous, current) => previous + current);
          }
          List<List<int>> newList =
              solutions(values, ammounts, newvariation, price, i);
          if (newList != null) {
            list.addAll(newList);
          }
        }
      }
    } else if (value == price) {
      // so we'll never track the closest yet anymore, since we have an exact solution
      _closestTotalYet = value;
      // if we haven't added any lists yet or this one uses fewer plates than any list we have so far, add it.
      if (list == null ||
          variation.fold(0, (previous, current) => previous + current) <
              this._platesUsed) {
        this._platesUsed =
            variation.fold(0, (previous, current) => previous + current);
        list.add(myCopy(variation));
      }
    }
    return list;
  }

  static int compute(List<int> values, List<int> variation) {
    int ret = 0;
    for (int i = 0; i < variation.length; i++) {
      ret += values[i] * variation[i];
    }
    return ret;
  }

  static List<int> myCopy(List<int> ar) {
    List<int> ret = new List<int>(ar.length);
    for (int i = 0; i < ar.length; i++) {
      ret[i] = ar[i];
    }
    return ret;
  }
}
