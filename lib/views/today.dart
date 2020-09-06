import 'package:flutter/material.dart';
import 'package:home_gym/views/views.dart';

class TodayView extends StatefulWidget {
  @override
  TodayViewState createState() => TodayViewState();
}

class TodayViewState extends State<TodayView>
    with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    new Tab(text: 'This Lift'),
    new Tab(text: 'All Day'),
  ];

  TabController defaultTabController;

  @override
  void initState() {
    super.initState();
    defaultTabController = new TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose for controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ReusableWidgets.getDrawer(context),
      appBar: ReusableWidgets.getAppBar(
          tabController: defaultTabController, tabs: myTabs),
      body: TabBarView(
        controller: defaultTabController,
        children: [
          DoLiftView(),
          ExcerciseDayView(),
        ],
      ),
    );
  }
}
