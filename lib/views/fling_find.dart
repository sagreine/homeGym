import 'package:flutter/material.dart';
import 'package:flutter_fling/flutter_fling.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:provider/provider.dart';

class FlingFinder extends StatefulWidget {
  @override
  FlingFinderState createState() => FlingFinderState();
}

class FlingFinderState extends State<FlingFinder> {
  //static const TextStyle timerTextStyle = TextStyle(
  //fontSize: 60,
  //fontWeight: FontWeight.bold,
  FlingController controller = FlingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Gym TV')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Consumer<FlingMediaModel>(
            builder: (context, flingy, child) {
              return flingy.selectedPlayer == null
                  ? Text("Search, then pick a player by tapping on it")
                  : Text("Select Player State: ${flingy.selectedPlayer.name}");
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Consumer<FlingMediaModel>(
            builder: (context, flingy, child) {
              return Column(
                children: <Widget>[
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: flingy.flingDevices == null
                        ? 0
                        : flingy.flingDevices.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(flingy.flingDevices.elementAt(index).name),
                        subtitle:
                            Text(flingy.flingDevices.elementAt(index).uid),
                        onTap: () => {
                          setState(() {
                            flingy.selectedPlayer =
                                flingy.flingDevices.elementAt(index);
                          })
                        },
                      );
                    },
                  ),
                  RaisedButton(
                      child: Text('Search'),
                      onPressed: () async {
                        await controller.getCastDevices(context);
                        setState(() {});
                      }),
                  RaisedButton(
                    child: Text('Dispose Controller'),
                    onPressed: () async {
                      // should be in controller - imagine using Cast instead of fling...
                      await FlutterFling.stopDiscoveryController();
                      setState(() {
                        // call a Controller function to do this instead.....
                        flingy.flingDevices = Set();
                        flingy.mediaState = 'null';
                        flingy.mediaCondition = 'null';
                        flingy.mediaPosition = '0';
                        flingy.selectedPlayer = null;
                      });
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
