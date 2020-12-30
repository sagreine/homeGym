import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_gym/views/views.dart';
//import 'package:flutter/services.dart';

//import 'package:home_gym/models/models.dart';
//import 'package:home_gym/controllers/controllers.dart';
//import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';

class HelpView extends StatefulWidget {
  @override
  HelpViewState createState() => HelpViewState();
}

class HelpViewState extends State<HelpView> {
  //SettingsController settingsController = SettingsController();
  // should these go in the Settingscontroller probably then...
  Future<void> loadHtmlFromAssets(String filename, controller) async {
    String fileText = await rootBundle.loadString(filename);
    controller.loadUrl(Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }

  WebViewController _controller;

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
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Help Page"),
              Divider(
                height: 10,
                thickness: 8,
                color: Colors.blueGrey,
                indent: 20,
                endIndent: 20,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 8),
              ),
              Text(
                "Instructional Screens",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Text(
                  "When you opened the app for the very first time you were shown these screens. Click to show them again",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              RaisedButton(
                child: Text("See Instructions"),
                onPressed: () {
                  print("pressed for help!");
                  Navigator.pushNamed(context, '/intro_screen');
                },
              ),
              SizedBox(
                height: 10,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1.color),
                      text:
                          "To cast: First, use your phone or computer to download the free companion TV app HomeGymTV available in the Amazon App Store. For FireStick: ",
                    ),
                    TextSpan(
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue),
                      text: "click this link ",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final url =
                              'https://www.amazon.com/dp/B08P9TKSPL/ref=mp_s_a_1_1?dchild=1&keywords=homegymtv&qid=1608494257&s=mobile-apps&sr=1-1 ';
                          if (await canLaunch(url)) {
                            await launch(
                              url,
                              forceSafariVC: false,
                            );
                          }
                        },
                    ),
                    TextSpan(
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1.color),
                      text:
                          " then go to settings and click Search. In the future, you should be able to select the FireStick simply by toggling the Cast button on the main lifting page.",
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: "Refer to ",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyText1.color)),
                    TextSpan(
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue),
                      text: "https://sagrehomegym.web.app/",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final url = 'https://sagrehomegym.web.app/';
                          if (await canLaunch(url)) {
                            await launch(
                              url,
                              forceSafariVC: false,
                            );
                          }
                        },
                    ),
                    TextSpan(
                        text: " for user manual with further instructions",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyText1.color)),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              RaisedButton(
                onPressed: () async {
                  PackageInfo packageInfo = await PackageInfo.fromPlatform();
                  showAboutDialog(
                      context: context,
                      children: [
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          Text("Please don't sue me"),
                          Container(
                            height: 160,
                            child: SingleChildScrollView(
                              child: Container(
                                height: 180,

                                /*
                                child: WebviewScaffold(
                                  url: 'public/index.html',
                                  
                                  appBar: AppBar(
                                    title: const Text('Widget'),
                                  ),
                                  withZoom: true,
                                  withLocalStorage: true,
                                  withLocalUrl: true,
                                  hidden: true,
                                ),*/

                                child: WebView(
                                  initialUrl: "",
                                  javascriptMode: JavascriptMode.unrestricted,
                                  gestureRecognizers: [
                                    Factory(() =>
                                        PlatformViewVerticalGestureRecognizer()),
                                  ].toSet(),
                                  //"file:///android_asset/flutter_assets/assets/index.html",
                                  onWebViewCreated: (WebViewController
                                      webViewController) async {
                                    _controller = webViewController;
                                    await loadHtmlFromAssets(
                                        'public/index.html', _controller);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ],
                      applicationVersion: packageInfo.version,
                      applicationName: packageInfo.appName,
                      applicationLegalese: "",
                      applicationIcon:
                          ImageIcon(AssetImage("assets/images/pos_icon.png")));
                },
                child: Text("About, and Legalese for masochists"),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class PlatformViewVerticalGestureRecognizer
    extends VerticalDragGestureRecognizer {
  PlatformViewVerticalGestureRecognizer({PointerDeviceKind kind})
      : super(kind: kind);

  Offset _dragDistance = Offset.zero;

  @override
  void addPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
  }

  @override
  void handleEvent(PointerEvent event) {
    _dragDistance = _dragDistance + event.delta;
    if (event is PointerMoveEvent) {
      final double dy = _dragDistance.dy.abs();
      final double dx = _dragDistance.dx.abs();

      if (dy > dx && dy > kTouchSlop) {
        // vertical drag - accept
        resolve(GestureDisposition.accepted);
        _dragDistance = Offset.zero;
      } else if (dx > kTouchSlop && dx > dy) {
        // horizontal drag - stop tracking
        stopTrackingPointer(event.pointer);
        _dragDistance = Offset.zero;
      }
    }
  }

  @override
  String get debugDescription => 'horizontal drag (platform view)';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
