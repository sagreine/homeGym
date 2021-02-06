import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:provider/provider.dart';

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
    defaultTabController =
        TabController(initialIndex: 0, length: 2, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose for controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PickedProgram program = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      drawer: ReusableWidgets.getDrawer(context),
      appBar: MediaQuery.of(context).orientation == Orientation.portrait
          ? ReusableWidgets.getAppBar(
              tabController: this.defaultTabController, tabs: myTabs)
          : ReusableWidgets.getAppBar(tabController: null, tabs: myTabs),
      body: ChangeNotifierProvider<PickedProgram>.value(
        value: program,
        child: TabBarView(
          controller: this.defaultTabController,
          children: [
            DoLiftView(),
            ExcerciseDayView(),
          ],
        ),
      ),
    );
  }
}
