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

// we're given a target weight but we know we need to subtract the bar weigth!
  String pickPlates({int targetWeight}) {
    CoinChangeLimitedCoins changeLimitedCoins = new CoinChangeLimitedCoins();

    String toReturn = changeLimitedCoins.platesAsStrings(
        plates: this.plates, targetWeight: (targetWeight - barWeight) / 2);
    return toReturn;
    //return [(targetWeight - barWeight) / 2];
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
// TODO: return the minimum # of plates - not thinking about future/previous sets at this point...
// TODO: Issue has extensive discussion on optimization over the day
// TODO: plates is a map so there is a lot of VERY DANGEROUS assuming going on here. instead of converting back and forth from
// TODO: we don't want to expose just a string here, because we will need to return 'actual value' if we don't have an exact match
// with the person's current plates. that is, if the closest you can get is X-3 we need to tell the user it is X-3....
// map to uncoupled 'trust me' lists, do it right.
// TODO: this sure feels like UI here in our friendly model code.......
class CoinChangeLimitedCoins {
  //List<int> values = [10, 20, 50, 100, 200];
  List<int> _closestYet = new List<int>();
  double _closestTotalYet = 0;
  int _platesUsed = 1000;
  Map<dynamic, int> closestYetMap = new Map<dynamic, int>();
  List<Map<dynamic, int>> _exactMatches;

  String platesAsStrings(
      {@required Map<dynamic, int> plates, @required double targetWeight}) {
    Map<dynamic, int> tmp =
        _endSolution(plates: plates, targetWeight: targetWeight);
    String toReturn = "";
    // sort so we get the heaviest weights first
    List<double> sorted = (new List.from(tmp.keys))
      ..sort((a, b) => b.compareTo(a));
    // then put how many of each weight we're to add. e.g. "2 45s 1 35 4 10s"
    sorted.forEach((element) {
      print(tmp[element].toString());
      if (tmp[element] > 0) {
        toReturn += "${tmp[element]} $element${tmp[element] > 1 ? "'s" : ""}  ";
      }
    });
    toReturn = toReturn.trim();
    toReturn = toReturn.replaceAll("  ", ",");

    print(toReturn);
    return toReturn;
  }

  // this is the solution we're returning. right now of course this is only considering current set.
  Map<dynamic, int> _endSolution(
      {@required Map<dynamic, int> plates, @required double targetWeight}) {
    _exactMatches = _doit(plates: plates, targetWeight: targetWeight);
    // if we have an exact match, let's use it. if we don't, use the closest one we have.
    if (_exactMatches != null && _exactMatches.isNotEmpty) {
      return _exactMatches.last;
    } else {
      return closestYetMap;
    }
  }

  // a better way is to not make lists like this...
  List<Map<dynamic, int>> _doit(
      {@required Map<dynamic, int> plates, @required double targetWeight}) {
    // available plates
    //List<int> values = [5, 10, 25, 35, 45];
    List<double> _plates = new List.from(plates.keys); //[10, 20, 50, 100, 200];
    // how many plates you have
    //List<int> ammounts = [4, 2, 2, 2, 2];
    List<int> _plateCounts = new List.from(plates.values); //[4, 2, 2, 2, 2];
    _plateCounts.forEach((element) {
      element = (element / 2).floor();
    });

    // always 0s
    List<int> tmpVariation = List<int>.filled(_plates.length, 0);
    // weight (excluding weight of the bar)
    // start at 0 ALWAYS
    List<Map<dynamic, int>> toReturn = new List<Map<dynamic, int>>();

    List<List<int>> results =
        _solutions(_plates, _plateCounts, tmpVariation, targetWeight, 0);
    // platecounts is the way in, results is the way out.
    for (List<int> result in results) {
      print(result);
      Map<dynamic, int> mapToReturn = new Map<dynamic, int>();
      for (int i = 0; i < _plates.length; ++i) {
        mapToReturn[_plates[i]] = result[i];
      }
      //Map.from(result);

      toReturn.add(mapToReturn);
    }
    print(_closestTotalYet.toString());
    print(_closestYet);
    print(_platesUsed);

    for (int i = 0; i < _plates.length; ++i) {
      closestYetMap[_plates[i]] = _closestYet[i];
    }
    //return results;
    return toReturn;
  }

  List<List<int>> _solutions(
    List<double> values,
    List<int> ammounts,
    List<int> variation,
    double price,
    int position,
  ) {
    List<List<int>> list = new List<List<int>>();

    double value = compute(values, variation);
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
              _solutions(values, ammounts, newvariation, price, i);
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
          // Remove this to not limit to small # of plates. for instance if we want to care about what was on the bar
          // immediately before this....
          variation.fold(0, (previous, current) => previous + current) <
              this._platesUsed) {
        this._platesUsed =
            variation.fold(0, (previous, current) => previous + current);
        list.add(myCopy(variation));
      }
    }
    return list;
  }

  static double compute(List<double> values, List<int> variation) {
    double ret = 0;
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
