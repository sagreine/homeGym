import 'package:flutter/material.dart';
import 'package:flutter_fling/remote_media_player.dart';

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
