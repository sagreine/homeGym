import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:provider/provider.dart';

class ExcerciseDayView extends StatefulWidget {
  @override
  _ExcerciseDayViewState createState() => _ExcerciseDayViewState();
}

class _ExcerciseDayViewState extends State<ExcerciseDayView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseDay>(builder: (context, day, child) {
      return ListView.builder(
        itemCount: day.sets * 2,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();
          final index = i ~/ 2;
          return ListTile(
            leading: Text(day.exercises[index].weight.toString()),
            //onTap: () => Navigator.pop(context, programSnap.data[index]),
            title: Text(day.exercises[index].title),
            subtitle: Text(day.exercises[index].reps.toString()),
            trailing: Text("currentSet = ${day.currentSet}"),
          );
        },
      );
    });
  }
}
