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

  String deadliftWeightAdjustmentPrefix = "";
  String deadliftWeightAdjustmentSuffix = "";

  void _calculatePlates({int targetWeight, @required String lift}) {
    double oneSidePlateWeight = (targetWeight - barWeight) / 2;
    //Map<dynamic, int> _plates = new Map<dynamic, int>.from(plates);
    //deadliftWeightAdjustmentPrefix = "";
    deadliftWeightAdjustmentSuffix = "";
    bool require45 = false;
    /*Map<dynamic, int> mapToReturn = new Map<dynamic, int>();
    for (int i = 0; i < _plates.length; ++i) {
        mapToReturn[_plates[i]] = result[i];
      }*/
    // if you're doing deadlife and don't own bumpers, the least you can do is
    // a 45 pounder on each side (unless you have some boxes)
    if (bumpers == false && lift.toLowerCase() == "deadlift") {
      // if they don't have bumpers and they don't have 45s, don't adjust, but complain.
      // this might throw, the second condition?
      if (!plates.containsKey(45.0) || plates[45.0] < 2) {
        print("deadlift above min, but don't own 45 pound weights");
        deadliftWeightAdjustmentSuffix =
            ", Buy bumpers or 45 pound weights to deadlift safely. Ignore if you're a monster with 60 pound weights or something";
      } else if (oneSidePlateWeight < 45) {
        print("deadlift weigth adjusted up, for form reasons");
        deadliftWeightAdjustmentSuffix =
            ", adjusted up to minimum using 45 pounders";
        oneSidePlateWeight = 45;
        require45 = true;
      } else {
        print("deadlift above min, adjusted so a 45 is always used if owned");
        // if they have at least 2 45s, use them and set it as such
        //oneSidePlateWeight -= 45;
        //deadliftWeightAdjustmentPrefix = "1 45 pound, ";
        require45 = true;
        //_plates[45.0] -= 2;
      }
    }

    // if not initiated or initiated with a different weight OR we no longer / now need a 45 but didn't last time.
    if (_plateFinder == null ||
        _plateFinder.targetWeight.toInt() != oneSidePlateWeight.toInt() ||
        _plateFinder.require45 != require45) {
      _plateFinder = PlateFinder(
          plates: plates,
          targetWeight: oneSidePlateWeight,
          require45: require45);
    }
  }

  String getPickedPlatesAsString({int targetWeight, @required String lift}) {
    _calculatePlates(targetWeight: targetWeight, lift: lift);

    return _plateFinder.platesAsStrings() + deadliftWeightAdjustmentSuffix;
  }

  double getPickedPlatesTotal({int targetWeight, @required String lift}) {
    _calculatePlates(targetWeight: targetWeight, lift: lift);
    return _plateFinder.valueOfFoundPlates;
  }

  double getPickedOverallTotal({int targetWeight, @required String lift}) {
    _calculatePlates(targetWeight: targetWeight, lift: lift);
    return getPickedPlatesTotal(targetWeight: targetWeight, lift: lift) * 2 +
        barWeight;
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
  final bool require45;

  PlateFinder({
    @required this.targetWeight,
    @required this.plates,
    @required this.require45,
  });
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

    int indexOf45 = _plates.indexOf(45.0);
    // because we only need to calculate what goes on 1/2 the barbell, we can
    // pass in a collection of plates (that has only even numbers) and divide in half, since we'll need the same on the
    // other side of the barbell
    // (this cuts down on the size of our solution via DP., as opposed to dividing by two at the end)
    _plateCounts.asMap().forEach((index, element) =>
        _plateCounts[index] = (element / 2).floor()); // [2, 1, 1, 1, 1]

    // always 0s --- lock to include a 45 though?
    List<int> tmpVariation = List<int>.filled(_plates.length, 0);
    _closestYet = List<int>.filled(_plates.length, 0);
    // weight (excluding weight of the bar)
    // start at 0 ALWAYS
    List<Map<dynamic, int>> toReturn = new List<Map<dynamic, int>>();

    List<List<int>> results = _solutions(
        _plates, _plateCounts, tmpVariation, targetWeight, 0, indexOf45);
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
    int indexOf45,
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
          if (require45 == false || variation[indexOf45] > 0) {
            if (value > _closestTotalYet ||
                (value == _closestTotalYet &&
                    variation.fold(
                            0, (previous, current) => previous + current) <
                        _platesUsed)) {
              _closestTotalYet = value;
              _closestYet = new List.from(variation);
              _platesUsed =
                  variation.fold(0, (previous, current) => previous + current);
            }
          }
          List<List<int>> newList =
              _solutions(values, ammounts, newvariation, price, i, indexOf45);
          if (newList != null) {
            list.addAll(newList);
          }
        }
      }
    } else if (value == price) {
      if (require45 == false || variation[indexOf45] > 0) {
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
