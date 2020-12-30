//import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
//import 'package:home_gym/models/models.dart';
//import 'package:provider/provider.dart';

class SettingsController {
  FlingController flingController = FlingController();
  // TODO: note that default settings are set in Main.dart for shared preferences
  updateBoolVal(
      {@required BuildContext context,
      @required String key,
      @required bool value}) async {
    var settings = Provider.of<Settings>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    if (key == "saveLocal") {
      settings.updateSaveLocal(value);
    } else if (key == "saveCloud") {
      settings.updateSaveCloud(value);
    } else if (key == "MeanQuotes") {
      settings.updateMeanQuotes(value);
    } else if (key == "timerVibrate") {
      settings.updateTimerVibrate(value);
    } else if (key == "wakeLock") {
      await settings.updateWakeLock(value);
    } else if (key == "darkTheme") {
      settings.updateDarkTheme(value, context);
      // we don't manage the prefs for this one so immediately return;
      return;
    } else {
      print("A setting was updated that doesn't exist");
    }
    prefs.setBool(key, value);
  }
}
