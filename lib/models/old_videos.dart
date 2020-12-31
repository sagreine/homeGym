import 'package:flutter/material.dart';

import 'models.dart';

class OldVideos extends ChangeNotifier {
  int _selectedItemToPlay;
  get selectedItemToPlay => _selectedItemToPlay;
  set selectedItemToPlay(newValue) {
    _selectedItemToPlay = newValue;
    notifyListeners();
  }

  String getBannerAdUnitId() {
    return 'ca-app-pub-6946458461924831~5512430957';
  }

  String getInterstitialAdUnitId() {
    return 'ca-app-pub-6946458461924831~5512430957';
  }

  String getRewardBasedVideoAdUnitId() {
    return 'ca-app-pub-6946458461924831~5512430957';
  }

  ExerciseSet _video;
  get video => _video;
  set video(newValue) {
    _video = newValue;
    notifyListeners();
  }

  OldVideos(
      {
      //this.firebaseUser,
      //isNewUser = true,
      //_selectedItemToPlay = _selectedItemToPlay;
      int selectedItem})
      : _selectedItemToPlay = selectedItem;
  List<Object> get props => [_selectedItemToPlay];
}
