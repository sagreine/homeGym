// may want this to be a changeNotifier just to simplify things..
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
part 'lifter_weights.g.dart';

@JsonSerializable()
//@CustomDoubleConverter()
class LifterWeights extends ChangeNotifier {
  int barWeight;
  Map<dynamic, int> plates;
  PlateFinder _plateFinder;
  bool bumpers;

  LifterWeights({this.barWeight, this.plates, this.bumpers});

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

  bool updateBumpers({bool bumpers}) {
    if (this.bumpers != bumpers) {
      this.bumpers = bumpers;
      notifyListeners();
      return true;
    }
    return false;
    ;
  }

// we're given a target weight but we know we need to subtract the bar weigth!
// cached, but this is dangerous for maintenance.
  void _calculatePlates({int targetWeight}) {
    double tempweight = (targetWeight - barWeight) / 2;
    // if not initiated or initiated with a different weight
    if (_plateFinder == null ||
        _plateFinder.targetWeight.toInt() != tempweight.toInt()) {
      _plateFinder = PlateFinder(plates: plates, targetWeight: tempweight);
    }
  }

  String getPickedPlatesAsString({int targetWeight}) {
    _calculatePlates(targetWeight: targetWeight);

    return _plateFinder.platesAsStrings();
  }

  double getPickedPlatesTotal({int targetWeight}) {
    _calculatePlates(targetWeight: targetWeight);
    return _plateFinder.valueOfFoundPlates;
  }

  double getPickedOverallTotal({int targetWeight}) {
    _calculatePlates(targetWeight: targetWeight);
    return getPickedPlatesTotal(targetWeight: targetWeight) * 2 + barWeight;
  }

  List<Object> get props => [
        barWeight,
        plates,
        bumpers,
      ];

  factory LifterWeights.fromJson(Map<String, dynamic> json) =>
      _$LifterWeightsFromJson(json);

  Map<String, dynamic> toJson() => _$LifterWeightsToJson(this);
}

// stolen shamelessly from https://stackoverflow.com/questions/22128759/atm-algorithm-of-giving-money-with-limited-amount-of-bank-notes
// TODO: return the minimum # of plates - not thinking about future/previous sets at this point...
// TODO: Issue has extensive discussion on optimization over the day
// TODO: plates is a map so there is a lot of VERY DANGEROUS assuming going on here. instead of converting back and forth from
// with the person's current plates. that is, if the closest you can get is X-3 we need to tell the user it is X-3....
// map to uncoupled 'trust me' lists, do it right.
// TODO: there's some strange bleed in here. why am i calculating and returning deep within instead of just at the end? i guess we have to calc along the way
// to go faster (performance) but it makes the code harder to read...
class PlateFinder {
  final double targetWeight;
  final Map<dynamic, int> plates;

  PlateFinder({@required this.targetWeight, @required this.plates});
  //List<int> values = [10, 20, 50, 100, 200];
  List<int> _closestYet = List<int>();
  int _platesUsed = 9999; // max.
  Map<dynamic, int> _closestYetMap = Map<dynamic, int>();
  List<Map<dynamic, int>> _exactMatches;

  double _closestTotalYet = 0;
  Map<dynamic, int> _foundPlates;

//caching. // this gets scary - highlights that we're subject to change in plates
  Map<dynamic, int> get foundPlates {
    if (_foundPlates == null) {
      _foundPlates = _endSolution();
    }
    return _foundPlates;
  }

  double get valueOfFoundPlates {
    if (_closestTotalYet != 0) {
      return _closestTotalYet;
    } else {
      _foundPlates = _endSolution();
      return _closestTotalYet;
    }
  }

  String platesAsStrings() {
    // initialize this to 0, necessary for calculation.
    // perform calculation
    if (_foundPlates == null) {
      _closestTotalYet = 0;
      _foundPlates = _endSolution();
    }
    String toReturn = "";
    // sort so we get the heaviest weights first
    // TODO: use toList() not List.from()
    List<double> sorted = (new List.from(_foundPlates.keys))
      ..sort((a, b) => b.compareTo(a));
    // then put how many of each weight we're to add. e.g. "2 45s 1 35 4 10s"
    sorted.forEach((element) {
      print(_foundPlates[element].toString());
      if (_foundPlates[element] > 0) {
        toReturn +=
            "${_foundPlates[element]} $element${_foundPlates[element] > 1 ? "'s" : ""}  ";
      }
    });
    // obvioulsy refactor this, but this says to replace spaces with commas after removing the trailing space.
    toReturn = toReturn.trim();
    toReturn = toReturn.replaceAll("  ", ",");

    print(toReturn);
    return toReturn;
  }

  // this is the solution we're returning. right now of course this is only considering current set.
  Map<dynamic, int> _endSolution() {
    _exactMatches = _doit();
    // if we have an exact match, let's use it. if we don't, use the closest one we have.
    if (_exactMatches != null && _exactMatches.isNotEmpty) {
      return _exactMatches.last;
    } else {
      return _closestYetMap;
    }
  }

  // a better way is to not make lists like this...
  List<Map<dynamic, int>> _doit() {
    // available plates
    //List<int> values = [5, 10, 25, 35, 45];
    List<double> _plates = new List.from(plates.keys); //[10, 20, 50, 100, 200];
    // how many plates you have
    //List<int> ammounts = [4, 2, 2, 2, 2];
    List<int> _plateCounts = new List.from(plates.values); //[4, 2, 2, 2, 2];
    // because we only need to calculate what goes on 1/2 the barbell, we can
    // pass in a collection of plates (that has only even numbers) and divide in half, since we'll need the same on the
    // other side of the barbell
    // (this cuts down on the size of our solution via DP., as opposed to dividing by two at the end)
    _plateCounts.asMap().forEach((index, element) =>
        _plateCounts[index] = (element / 2).floor()); // [2, 1, 1, 1, 1]

    // always 0s
    List<int> tmpVariation = List<int>.filled(_plates.length, 0);
    _closestYet = List<int>.filled(_plates.length, 0);
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
      _closestYetMap[_plates[i]] = _closestYet[i];
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
          if (value > _closestTotalYet ||
              (value == _closestTotalYet &&
                  variation.fold(0, (previous, current) => previous + current) <
                      _platesUsed)) {
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
              _platesUsed) {
        _platesUsed =
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
