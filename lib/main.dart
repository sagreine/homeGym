//import 'package:firebase_auth_ui/firebase_auth_ui.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
//import 'package:flutter_bloc/flutter_bloc.dart'
//import 'package:home_gym/blocs/blocs.dart';
//import 'package:home_gym/blocs/timer/timer_bloc.dart';
//import 'package:home_gym/ticker.dart';
import 'package:home_gym/views/views.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
//import 'package:home_gym/simple_bloc_delegate.dart';
//import 'package:bloc/bloc.dart';
//import 'package:flutter_fling/flutter_fling.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' as Foundation;

// BLoC for each page
// complex page-children should have their own block, parent subscribes to state changes

// what events will happen?
// those go in event

// what goes in state?
/// the variables or data the screen/app will use in certain states
/// initial state first, then e.g. loaded, not loaded, etc.

// bloc - computation, querying.
/// Event in, state out. deliver to UI via sending a state

// UI defined elsewhere
// default: stateless background UI, stateless action widgets

//flutter pub run build_runner watch

void main() async {
  //Bloc.observer = SimpleBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // TODO if we stop using this plugin, remove this. at least
  await FlutterDownloader.initialize(
      debug: Foundation
          .kDebugMode // optional: set false to disable printing logs to console
      );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => Muser(),
    ),
    ChangeNotifierProvider(create: (context) => Settings()),
    // most of these can move down now...
    ChangeNotifierProvider(create: (context) => LifterWeights()),
    ChangeNotifierProvider(create: (context) => LifterMaxes()),
    ChangeNotifierProvider(
      create: (context) => ExerciseSet(), //context: context),
    ),
    ChangeNotifierProvider(
      create: (context) => ExerciseDay(),
    ),
    ChangeNotifierProvider(
      create: (context) => Programs(),
    ),
    ChangeNotifierProvider(
      create: (context) => FlingMediaModel(),
    ),
  ], child: MyApp()));
}

/*
void getInitialPull(BuildContext context) async {
  var programs = Provider.of<Programs>(context, listen: false);
  List<QueryDocumentSnapshot> list =
      new List.from((await getPrograms()).docs.toList());

  programs.setProgram(
      programs: list.map((QueryDocumentSnapshot docSnapshot) {
    return docSnapshot.id.toString();
    // this is a first step towards how to get a step further for if/when we're not (stupidly) using the ID and want e.g. a display name.
    //return docSnapshot.data().entries.toString();
  }).toList());
}
*/
void _getInitialPull(BuildContext context) async {
  var programs = Provider.of<Programs>(context, listen: false);
  // don't want await here. use .then()
  programs.setProgram(programs: await getPrograms());
  print("Initial pull of programss: ${programs.programs}");
  FlingController flingController = FlingController();
  flingController.getCastDevices(context);
}

void _getSharedPrerferences(BuildContext context) async {
  var settings = Provider.of<Settings>(context, listen: false);
  final prefs = await SharedPreferences.getInstance();
  settings.saveLocal = prefs.getBool("saveLocal") ?? false;
  settings.saveCloud = prefs.getBool("saveCloud") ?? true;
}

void _serverInit(context) {
  var serverRequest = Provider.of<FlingMediaModel>(context, listen: false);
  // we only want to allow sharing in debug mode, simply to allow live-refreshes more easily...
  HttpServer.bind('0.0.0.0', 4040, shared: Foundation.kDebugMode)
      .then((serverRequests) {
    serverRequest.httpServer = serverRequests;
    // note: autocompress doesn't allow non-compressed videos of meaningful length to go well...
    print(
        "listening to ${serverRequests.address} address and port: ${serverRequests.port}");
  });
}

void _clearOlddata() async {
  var appDir = (await getTemporaryDirectory()).path;

  var videosDr = (await getApplicationDocumentsDirectory()).path.toString();
  // + "/files/video_compress";
  new Directory(appDir).delete(recursive: true);
  new Directory(videosDr).delete(recursive: true);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //var day = Provider.of<ExerciseDay>(context, listen: false);
    // load all non-user-specific things async (not waiting for them) during the splash.
    // okay to be here because this is only to be built once --- if the screen goes black during splash though?
    // but this is running over and over again....? just on hot reload though actually.
    _getInitialPull(context);
    _serverInit(context);
    _getSharedPrerferences(context);
    _clearOlddata();

    // maybe check if the user is already authorized here, and go to login if not?
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF282828), //Color.fromRGBO(109, 234, 255, 1),
        accentColor: Color.fromRGBO(72, 74, 126, 1),
        brightness: Brightness.dark,
      ),
      title: 'Home Gym',
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => SplashScreen.navigate(
              backgroundColor: Colors.grey[850],
              name: 'assets/flares/logo1.flr',
              next: (context) => LoginView(),
              until: () => Future.delayed(Duration(seconds: 2)),
              startAnimation: 'Untitled',
            ),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/login': (context) => LoginView(),
        '/do_lift': (context) => DoLiftView(),
        '/help': (context) => HelpView(),
        '/lifter_maxes': (context) => LifterMaxesView(),
        '/lifter_weights': (context) => LifterWeightsView(),
        '/pick_day': (context) => PickDayView(),
        '/profile': (context) => ProfileView(),
        '/programs': (context) => ProgramsView(),
        '/settings': (context) => SettingsView(),
        '/intro_screen': (context) => IntroScreenView(),
        '/excerciseday': (context) => ExcerciseDayView(),
        "/lifter_videos": (context) => OldVideosView(),
        '/form_check': (context) => FormCheckView(),
        '/form_check_copy': (context) => FormCheckView(),
        '/today': (context) => TodayView(),
      },
    );
  }
}
