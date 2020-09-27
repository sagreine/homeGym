// could/should save this to user prefences.... maytbe the cast device too?
// singleton..... or just use provider
import 'package:flutter/material.dart';

class Settings extends ChangeNotifier {
  bool saveLocal;
  bool saveCloud;

  Settings() {
    saveCloud = true;
    saveLocal = false;
  }
  updateSaveLocal(bool value) {
    saveLocal = value;
    notifyListeners();
  }

  updateSaveCloud(bool value) {
    saveCloud = value;
    notifyListeners();
  }
}
