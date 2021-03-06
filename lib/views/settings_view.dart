import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/controllers/settings.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/views/views.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatefulWidget {
  final AdaptiveThemeMode savedThemeMode;
  SettingsView({Key key, this.savedThemeMode}) : super(key: key);

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  SettingsController settingsController = SettingsController();
  // should these go in the Settingscontroller probably then...

  @override
  void dispose() {
    // TODO: implement dispose for controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(),
      drawer: ReusableWidgets.getDrawer(context),
      body: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Settings",
                style: TextStyle(fontSize: 16),
              ),
              Divider(
                height: 10,
                thickness: 8,
                color: Colors.blueGrey,
                indent: 20,
                endIndent: 20,
              ),
              Consumer<Settings>(builder: (context, settings, child) {
                return Column(
                  children: [
                    SwitchListTile.adaptive(
                      value: settings.saveLocal ?? false,
                      onChanged: (value) {
                        settingsController.updateBoolVal(
                            context: context, key: "saveLocal", value: value);
                      },
                      secondary: const Icon(Icons.save_alt),
                      title: Text("Save local copy of video too"),
                    ),
                    SwitchListTile.adaptive(
                      value: settings.saveCloud ?? false,
                      onChanged: (value) {
                        settingsController.updateBoolVal(
                            context: context, key: "saveCloud", value: value);
                      },
                      secondary: const Icon(Icons.cloud),
                      title: Text("Save to Cloud"),
                    ),
                    SwitchListTile.adaptive(
                      value: settings.meanQuotes ?? false,
                      onChanged: (value) {
                        settingsController.updateBoolVal(
                            context: context, key: "MeanQuotes", value: value);
                      },
                      secondary: const Icon(Icons.format_quote),
                      title: Text("'Motivational' Quotes"),
                    ),
                    SwitchListTile.adaptive(
                      value: settings.wakeLock ?? false,
                      onChanged: (value) {
                        settingsController.updateBoolVal(
                            context: context, key: "wakeLock", value: value);
                      },
                      secondary: settings.wakeLock
                          ? Icon(Icons.lock_open)
                          : Icon(Icons.lock),
                      title: Text("Keep screen unlocked"),
                    ),
                    SwitchListTile.adaptive(
                      value: settings.timerVibrate ?? true,
                      onChanged: (value) {
                        try {
                          settingsController.updateBoolVal(
                              context: context,
                              key: "timerVibrate",
                              value: value);
                        } catch (err) {
                          throw Exception("error setting vibrate. Error: $err");
                        }
                      },
                      secondary: Icon(Icons.vibration),
                      title: Text("Vibrate at timer end"),
                    ),
                    SwitchListTile.adaptive(
                      value: settings.darkTheme ??
                          (widget.savedThemeMode == AdaptiveThemeMode.dark) ??
                          true,
                      onChanged: (value) {
                        /*Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text("This may take a moement"),
                        ));*/
                        settingsController.updateBoolVal(
                            context: context, key: "darkTheme", value: value);
                      },
                      secondary: settings.darkTheme ??
                              (widget.savedThemeMode ==
                                  AdaptiveThemeMode.dark) ??
                              true
                          ? Icon(Icons.brightness_low)
                          : Icon(Icons.brightness_high),
                      title: Text("Toggle Dark Mode"),
                    ),
                  ],
                );
              }),
              Divider(
                height: 10,
                thickness: 8,
                color: Colors.blueGrey,
                indent: 20,
                endIndent: 20,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 12, 0, 8),
                child: Text(
                  "Reset and pick a Fling Device",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Consumer<FlingMediaModel>(
                builder: (context, flingy, child) {
                  return Column(children: <Widget>[
                    flingy.selectedPlayer == null
                        ? Text(
                            "Reset, search, then pick a player by tapping on it")
                        : Text(
                            "Select Player State: ${flingy.selectedPlayer.name}"),
                    RaisedButton(
                        child: Text('Reset'),
                        onPressed: () async {
                          await settingsController.flingController
                              .dispose(context);
                          await settingsController.flingController
                              .getCastDevices(context);
                        }),
                    // future builder though?
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: flingy.flingDevices == null
                          ? 0
                          : flingy.flingDevices.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title:
                              Text(flingy.flingDevices.elementAt(index).name),
                          subtitle:
                              Text(flingy.flingDevices.elementAt(index).uid),
                          onTap: () => {
                            settingsController.flingController.selectPlayer(
                                context, flingy.flingDevices.elementAt(index))
                          },
                        );
                      },
                    ),
                  ]);
                },
              ),
            ],
          ),
        ],
      ),
      /*floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Consumer<FlingMediaModel>(
            builder: (context, flingy, child) {
              return Column(
                children: <Widget>[],
              );
            },
          ),
        ],
      ),*/
    );
  }
}
