import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
//import 'package:flutter_bloc/flutter_bloc.dart'
//import 'package:home_gym/blocs/blocs.dart';
//import 'package:home_gym/blocs/timer/timer_bloc.dart';
//import 'package:home_gym/ticker.dart';
import 'package:home_gym/views/home.dart';
import 'package:provider/provider.dart';
//import 'package:home_gym/simple_bloc_delegate.dart';
//import 'package:bloc/bloc.dart';
//import 'package:flutter_fling/flutter_fling.dart';

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

void main() {
  //Bloc.observer = SimpleBlocObserver();
  runApp(MultiProvider(providers: [
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
        primaryColor: Color.fromRGBO(109, 234, 255, 1),
        accentColor: Color.fromRGBO(72, 74, 126, 1),
        brightness: Brightness.dark,
      ),
      title: 'Home Gym',
      home: Home(),

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
