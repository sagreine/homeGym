import 'dart:io';

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
  HttpServer httpServer;
  bool testyTest = false;
  int secondTest = 1;
  // this is set once we have listened to something with our httpServer -> we only want to listen to one port, 1 time, and nothing else can listen to that port
  // in production that'd have to be a randomly selected one > 1024, not hardcoded, in case user has something there already...
  bool isListening;

  void addFlingDevices(RemoteMediaPlayer remoteMediaPlayer) {
    flingDevices.add(remoteMediaPlayer);
    notifyListeners();
  }

  void removeFlingDevice(RemoteMediaPlayer remoteMediaPlayer) {
    if (remoteMediaPlayer == selectedPlayer) {
      selectedPlayer = null;
    }
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
    //httpServer.close()
    notifyListeners();
  }

  FlingMediaModel(
      {this.flingDevices,
      this.selectedPlayer,
      this.mediaCondition,
      this.mediaPosition,
      this.mediaState,
      this.httpServer,
      this.isListening}) {
    flingDevices = Set();
    isListening = false;
  }

  //@override
  List<Object> get props => [
        flingDevices,
        selectedPlayer,
        mediaCondition,
        mediaState,
        mediaPosition,
        httpServer,
        isListening,
      ];
}
