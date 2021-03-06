import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fling/flutter_fling.dart';
import 'package:flutter_fling/remote_media_player.dart';

import 'package:home_gym/models/models.dart';

import 'package:provider/provider.dart';

// change this to singleton?
class FlingController {
  Future<void> getCastDevices(BuildContext context) async {
    var prov = Provider.of<FlingMediaModel>(context, listen: false);

    await FlutterFling.startDiscoveryController((status, player) {
      if (prov == null) {
        prov.flingDevices = List();
      }
      if (status == PlayerDiscoveryStatus.Found) {
        prov.addFlingDevices(player);
        prov.flingDevices.sort((player1, player2) {
          return player1.name.compareTo(player2.name);
        });
      } else {
        prov.removeFlingDevice(player);
      }
    });
  }

  void selectPlayer(
      BuildContext context, RemoteMediaPlayer _selectedPlayer) async {
    try {
      Provider.of<FlingMediaModel>(context, listen: false)
          .selectPlayer(_selectedPlayer);
    } on PlatformException {
      print('Failed to get selected device');
    }
  }

  Future<void> dispose(context) async {
    var prov = Provider.of<FlingMediaModel>(context, listen: false);
    await FlutterFling.stopDiscoveryController();
    prov.reset();
    prov = null;
    //prov.dispose();
  }
}
