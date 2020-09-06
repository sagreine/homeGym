//import 'package:firebase_auth_ui/firebase_auth_ui.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
//import 'package:flutter_bloc/flutter_bloc.dart'
//import 'package:home_gym/blocs/blocs.dart';
//import 'package:home_gym/blocs/timer/timer_bloc.dart';
//import 'package:home_gym/ticker.dart';
import 'package:home_gym/views/views.dart';
import 'package:provider/provider.dart';
//import 'package:home_gym/simple_bloc_delegate.dart';
//import 'package:bloc/bloc.dart';
//import 'package:flutter_fling/flutter_fling.dart';
import 'package:firebase_core/firebase_core.dart';

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
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => Muser(),
    ),
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

// TODO: also pull in fling/cast devices? will still need to pull in elsewhere of course, cuz that changes over time.
void getInitialPull(BuildContext context) async {
  var programs = Provider.of<Programs>(context, listen: false);
  programs.setProgram(programs: await getPrograms());
  print("Initial pull of programss: ${programs.programs}");
  FlingController flingController = FlingController();
  flingController.getCastDevices(context);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var day = Provider.of<ExerciseDay>(context, listen: false);
    // load all non-user-specific things async (not waiting for them) during the splash.
    // okay to be here because this is only to be built once --- if the screen goes black during splash though?
    // but this is running over and over again....? just on hot reload though actually.
    getInitialPull(context);
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
        '/today': (context) => TodayView(),
      },
    );
  }
}
