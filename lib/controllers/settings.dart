import 'package:flutter/material.dart';
import 'package:home_gym/controllers/controllers.dart';

class SettingsController {
  TextEditingController barWeightTextController = new TextEditingController();
  FlingController flingController = FlingController();
  LiftMaxController liftMaxController = LiftMaxController();
  LifterWeightsController lifterWeightsController = LifterWeightsController();
}
