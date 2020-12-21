// could/should save this to user prefences.... maytbe the cast device too?
// singleton..... or just use provider
import 'package:flutter/material.dart';

class Settings extends ChangeNotifier {
  // TODO: note that default settings are set in Main.dart for shared preferences so if you add a setting set it there too.
  bool saveLocal;
  bool saveCloud;
  bool meanQuotes;

  Settings() {
    this.saveCloud = true;
    this.saveLocal = false;
    this.meanQuotes = true;
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
}
