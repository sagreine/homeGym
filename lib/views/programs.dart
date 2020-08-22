import 'package:flutter/material.dart';
import 'package:home_gym/controllers/controllers.dart';

class Programs extends StatefulWidget {
  @override
  _ProgramsState createState() => _ProgramsState();
}

class _ProgramsState extends State<Programs> {
  ProgramController programsController = ProgramController();

  @override
  void initState() {
    //programsController.updateProgramList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
      ),
      body: _buildSuggestions(),
    );
  }

  //TODO: this works, but a) depenent on GCP (couldn't immediately get the future parsing to return List to behave given async)
  // b) will likely not want to use documentID in reality, but rather a display name..
  Widget _buildSuggestions() {
    return FutureBuilder(
      // once we have data put it in.
      builder: (context, programSnap) {
        if (programSnap.hasData == false) {
          return Container(child: Text("waiting"));
        }
        return ListView.builder(
            itemCount: programSnap.data.documents.length * 2,
            padding: EdgeInsets.all(16.0),
            itemBuilder: (context, i) {
              if (i.isOdd) return Divider();
              final index = i ~/ 2;
              return ListTile(
                  title: Text(programSnap.data.documents[index].documentID));
            });
      },
      future: programsController.updateProgramList(),
    );
  }
}
