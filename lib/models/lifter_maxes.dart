import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
part 'lifter_maxes.g.dart';

@JsonSerializable()
class LifterMaxes extends ChangeNotifier {
  int deadliftMax;
  int squatMax;
  int benchMax;
  int pressMax;

  LifterMaxes({
    this.deadliftMax,
    this.squatMax,
    this.benchMax,
    this.pressMax,
  });

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
    notifyListeners();
  }

  List<Object> get props => [
        deadliftMax,
        squatMax,
        benchMax,
        pressMax,
      ];
  factory LifterMaxes.fromJson(Map<String, dynamic> json) =>
      _$LifterMaxesFromJson(json);

  Map<String, dynamic> toJson() => _$LifterMaxesToJson(this);
}
