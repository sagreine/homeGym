import 'package:flutter/material.dart';
import 'package:flutter_fling/remote_media_player.dart';

// mods to pub_dev flutter_fling:
// 1) set sid to custom reciever (java code) instead of firestick itself
// 2) remotemediaplayer now extends equatable so Set works
class FlingMediaModel extends ChangeNotifier {
  Set<RemoteMediaPlayer> flingDevices;
  RemoteMediaPlayer selectedPlayer;
  String mediaState;
  String mediaCondition;
  String mediaPosition;

  void addFlingDevices(RemoteMediaPlayer remoteMediaPlayer) {
    flingDevices.add(remoteMediaPlayer);
    notifyListeners();
  }

  void removeFlingDevice(RemoteMediaPlayer remoteMediaPlayer) {
    flingDevices.remove(remoteMediaPlayer);
    notifyListeners();
  }

  void selectPlayer(RemoteMediaPlayer _selectedPlayer) {
    selectedPlayer = _selectedPlayer;
    notifyListeners();
  }

// dispose though...
  void reset() {
    flingDevices = Set();
    mediaState = 'null';
    mediaCondition = 'null';
    mediaPosition = '0';
    selectedPlayer = null;
    notifyListeners();
  }

  FlingMediaModel(
      {this.flingDevices,
      this.selectedPlayer,
      this.mediaCondition,
      this.mediaPosition,
      this.mediaState}) {
    flingDevices = Set();
  }

  //@override
  List<Object> get props =>
      [flingDevices, selectedPlayer, mediaCondition, mediaState, mediaPosition];
}
