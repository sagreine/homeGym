import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fling/flutter_fling.dart';
import 'package:flutter_fling/remote_media_player.dart';

import 'package:home_gym/models/models.dart';

import 'package:provider/provider.dart';

// change this to singleton?
class FlingController {
  getCastDevices(BuildContext context) async {
    var prov = Provider.of<FlingMediaModel>(context, listen: false);

    await FlutterFling.startDiscoveryController((status, player) {
      if (prov == null) {
        prov.flingDevices = Set();
      }
      if (status == PlayerDiscoveryStatus.Found) {
        prov.addFlingDevices(player);
      } else {
        prov.removeFlingDevice(player);
      }
    });
  }

  getSelectedDevice(BuildContext context) async {
    RemoteMediaPlayer selectedDevice;
    try {
      selectedDevice = await FlutterFling.selectedPlayer;
    } on PlatformException {
      print('Failed to get selected device');
    }
    Provider.of<FlingMediaModel>(context, listen: false).selectedPlayer =
        selectedDevice;
  }
}
