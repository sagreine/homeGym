// could/should save this to user prefences.... maytbe the cast device too?
// singleton..... or just use provider
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';

class Settings extends ChangeNotifier {
  // TODO: note that default settings are set in Main.dart for shared preferences so if you add a setting set it there too.
  bool saveLocal;
  bool saveCloud;
  bool meanQuotes;
  bool wakeLock;
  bool darkTheme;
  bool timerVibrate;

  Settings() {
    this.saveCloud = true;
    this.saveLocal = false;
    this.meanQuotes = true;
    this.wakeLock = true;
    this.timerVibrate = true;
    //this.darkTheme = true;
  }
  // golly this looks awfully like copying and pasting code...
  updateSaveLocal(bool value) {
    saveLocal = value;
    notifyListeners();
  }

  updateSaveCloud(bool value) {
    saveCloud = value;
    notifyListeners();
  }

  updateMeanQuotes(bool value) {
    meanQuotes = value;
    notifyListeners();
  }

  updateWakeLock(bool value) async {
    wakeLock = value;
    await Wakelock.toggle(on: value);
    notifyListeners();
  }

  updateDarkTheme(bool value, BuildContext context) async {
    darkTheme = value;
    AdaptiveTheme.of(context).toggleThemeMode();
    notifyListeners();
  }

  updateTimerVibrate(bool value) async {
    timerVibrate = value;
    notifyListeners();
  }
}
