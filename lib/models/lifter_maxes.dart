import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
part 'lifter_maxes.g.dart';

@JsonSerializable()
class LifterMaxes extends ChangeNotifier {
  int deadliftMax;
  int squatMax;
  int benchMax;
  int pressMax;
  int _total;
  int _calculatorReps;
  int _calculatorWeight;
  int calculatedMax;

  set calculatorReps(newValue) {
    //if (newValue != null) {
    _calculatorReps = newValue;
    //}

    calculateMax();
    notifyListeners();
  }

  set calculatorWeight(newValue) {
    //if (newValue != null) {
    _calculatorWeight = newValue;
    //} else {}
    calculateMax();
    notifyListeners();
  }

  calculateMax() {
    if (_calculatorReps != null &&
        _calculatorReps > 0 &&
        _calculatorWeight != null &&
        _calculatorWeight > 0) {
      var tmp = _calculatorWeight * (1 + _calculatorReps / 40);
      calculatedMax = tmp.toInt();
    } else {
      calculatedMax = null;
    }
    notifyListeners();
  }

  /*get calculatedMax {
    //if ((_calculatorReps ?? 0 > 0) && (_calculatorWeight ?? 0 > 0)) {
    calculateMax();
    return _calculatedMax;
    //}
  }*/

  int get total =>
      _total ??
      (deadliftMax ?? 0) + (squatMax ?? 0) + (benchMax ?? 0) + (pressMax ?? 0);

  LifterMaxes({
    this.deadliftMax,
    this.squatMax,
    this.benchMax,
    this.pressMax,
  }) {
    _total = (this.deadliftMax ?? 0) +
        (this.squatMax ?? 0) +
        (this.benchMax ?? 0) +
        (this.pressMax ?? 0);
  }

  void updateMax(String string, int newValue) {
    switch (string.toLowerCase()) {
      case "deadlift":
        deadliftMax = newValue;
        break;
      case "bench":
        benchMax = newValue;
        break;
      case "squat":
        squatMax = newValue;
        break;
      case "press":
        pressMax = newValue;
        break;
    }
    _total = (deadliftMax ?? 0) +
        (squatMax ?? 0) +
        (benchMax ?? 0) +
        (pressMax ?? 0);
    notifyListeners();
  }

  List<Object> get props => [
        deadliftMax,
        squatMax,
        benchMax,
        pressMax,
        _total,
      ];
  factory LifterMaxes.fromJson(Map<String, dynamic> json) =>
      _$LifterMaxesFromJson(json);

  Map<String, dynamic> toJson() => _$LifterMaxesToJson(this);
}
