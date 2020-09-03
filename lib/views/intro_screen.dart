import 'package:flutter/material.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';

/*
Problems that the app solves
The primary benefits the app creates
The app’s “toothbrush features” (meaning, a feature you would use once or twice a day)
*/

class IntroScreenView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IntroScreenViewState();
}

class IntroScreenViewState extends State<IntroScreenView> {
  List<PageViewModel> listPagesViewModel() {
    return [
      PageViewModel(
        pageColor: const Color(0xFF607D8B),
        iconImageAssetPath: 'assets/images/pos_icon.png',
        bubbleBackgroundColor: Colors.blueGrey[400],
        body: Text(
          "Log your workouts, record them, cast to a TV so you don't stare at your phone",
        ),
        title: Text('Cabs'),
        mainImage: Image.asset(
          'assets/images/animation_1.gif',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        ),
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
      PageViewModel(
        pageColor: Colors.greenAccent[700],
        iconImageAssetPath: 'assets/images/pos_icon.png',
        bubbleBackgroundColor: Colors.greenAccent[400],
        body: Text("You can focus on lifting, not thinking, not your phone"),
        title: Text('Cabs'),
        mainImage: Image.asset(
          'assets/images/pos_icon.png',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        ),
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Widget introViews = new IntroViewsFlutter(
      listPagesViewModel(),
      onTapDoneButton: () {
// TODO: would be putting the pre-load stuff here too, then?

        Navigator.pushReplacementNamed(context, '/pick_day');
      },
      showSkipButton: true,
      pageButtonTextStyles: new TextStyle(
        color: Colors.white,
        fontSize: 18.0,
        fontFamily: "Regular",
      ),
    );

    return new Scaffold(
      body: introViews,
    );
  }
}
