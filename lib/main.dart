//import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/material.dart';
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
      create: (context) => ExerciseSet(),
    ),
    ChangeNotifierProvider(
      create: (context) => ExerciseDay(),
    ),
    ChangeNotifierProvider(
      create: (context) => FlingMediaModel(),
    ),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF282828), //Color.fromRGBO(109, 234, 255, 1),
        accentColor: Color.fromRGBO(72, 74, 126, 1),
        brightness: Brightness.dark,
      ),
      title: 'Home Gym',
      home: Container(
        color: Colors.grey[850],
        child: SplashScreen.navigate(
          name: 'assets/flares/logo1.flr',
          next: (context) => Login(),
          until: () => Future.delayed(Duration(seconds: 2)),
          startAnimation: 'Untitled',
        ),
      ),
      //Login(),
      //Splash(),

      /*BlocProvider(
        create: (context) => VideoBloc(),
        child: Timer(),*/
      /*BlocProvider(
        create: (context) => TimerBloc(ticker: Ticker()),
        child: Timer(),*/
      //),
    );
  }
}
