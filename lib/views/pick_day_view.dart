import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_gym/controllers/controllers.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:provider/provider.dart';

class PickDayView extends StatefulWidget {
  @override
  _PickDayViewState createState() => _PickDayViewState();
}

class _PickDayViewState extends State<PickDayView> {
  PickDayController pickDayController = PickDayController();
  AdmobBannerSize bannerSize;

  @override
  Widget build(BuildContext context) {
    bannerSize = AdmobBannerSize.SMART_BANNER(context);
    // somewhat sketchy, but this is used to populate childAspectRatio and allow us to
    // size for both phone orientations.
    var size = MediaQuery.of(context).size;
    // for now just messing with these to get a size that doesn't require scrolling on my phone in landscape,so not ideal but not breaking for others either..
    final double itemWidth = size.width / 2;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 5;
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(),
      drawer: ReusableWidgets.getDrawer(context),
      body: Column(
        //mainAxisSize: MainAxisSize.min,
        children: [
          //Expanded(
          //flex: 1,
          //child:
          Text("Select Exercise", style: TextStyle(fontSize: 24)),
          //),
          Expanded(
            flex: 5,
            child: GridView.count(
              //padding: EdgeInsets.all(5),
              shrinkWrap: true,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              crossAxisCount: 2,
              childAspectRatio: (itemWidth / itemHeight),
              children: List.generate(4, (index) {
                return

                    //return
                    Material(
                        elevation:
                            !pickDayController.selectedExercise[index] ? 60 : 0,
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color:
                                    !pickDayController.selectedExercise[index]
                                        ? Theme.of(context)
                                            .canvasColor //Colors.transparent
                                        : Theme.of(context).backgroundColor,
                              )
                            ],
                            color: !pickDayController.selectedExercise[index]
                                ? Theme.of(context).canvasColor
                                : Theme.of(context).backgroundColor,
                            border: Border(
                              left: BorderSide(color: Colors.blueGrey
                                  /*color: !pickDayController
                                          .selectedExercise[index]
                                      ? Colors.blueGrey
                                      : Colors.greenAccent*/ //Color(0xFF06ac51)
                                  ),
                              right: BorderSide(color: Colors.blueGrey
                                  /*color: !pickDayController
                                          .selectedExercise[index]
                                      ? Colors.blueGrey
                                      : Colors.greenAccent*/ //Color(0xFF06ac51)
                                  ),
                              top: BorderSide(color: Colors.blueGrey
                                  /*color: !pickDayController
                                          .selectedExercise[index]
                                      ? Colors.blueGrey
                                      : Colors.greenAccent*/ //Color(0xFF06ac51)
                                  ),
                              bottom: BorderSide(color: Colors.blueGrey
                                  /*
                                  color: !pickDayController
                                          .selectedExercise[index]
                                      ? Colors.blueGrey
                                      : Colors.greenAccent */
                                  //Color(0xFF06ac51)
                                  ),
                            ),
                            /*gradient: 
                            // TODO: maybe do a grey-gunmetal gradient for when selected looks cool maybe? but dosn't match the Day view
                            // but it already doesn't for some reason soooo.
                        ? LinearGradient(
                            colors: <Color>[
                              Color(0xFF0D47A1),
                              Color(0xFF1976D2),
                              Color(0xFF0D47A1),
                              //Color(0xFF42A5F5),
                            ],
                          )
                        : LinearGradient(
                            colors: <Color>[
                              Color(0xFF058f43),
                              Color(0xFF06ac51),
                              Color(0xFF058f43),
                              //Color(0xFF1bcc50),
                            ],
                          ),*/
                          ),
                          //color: isPickedTest ? Colors.blue : Colors.yellow[200],
                          duration: Duration(milliseconds: 300),
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(0),

                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: () {
                                // this is lazy and bad.
                                setState(() {
                                  pickDayController.pickExercise(
                                      index, context);
                                });
                              },
                              splashColor:
                                  !pickDayController.selectedExercise[index]
                                      ? Theme.of(context).backgroundColor
                                      : Theme.of(context).canvasColor,
                              /* ? Color(0xFF06ac51)
                                      : Color(0xFF1976D2),*/
                              child:
                                  // this allows splash and clickable on the whole area of the box (max x max),
                                  // because alignment: up above would otherwise shrink this to the size of the text box...
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                    Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              pickDayController.exercises[index]
                                                  .toString(),
                                              style: TextStyle(fontSize: 50)),
                                        ]),
                                  ]),
                            ),
                          ),
                        ));
              }),
            ),
          ),
          if (MediaQuery.of(context).orientation == Orientation.portrait)
            Container(
              margin: EdgeInsets.only(bottom: 80.0),
              child: AdmobBanner(
                adUnitId: Provider.of<OldVideos>(context, listen: false)
                    .getBannerAdUnitId(),
                adSize: bannerSize,
                /* listener: (AdmobAdEvent event, Map<String, dynamic> args) {
                  handleEvent(event, args, 'Banner');
                },*/
                onBannerCreated: (AdmobBannerController controller) {
                  // Dispose is called automatically for you when Flutter removes the banner from the widget tree.
                  // Normally you don't need to worry about disposing this yourself, it's handled.
                  // If you need direct access to dispose, this is your guy!
                  // controller.dispose();
                },
              ),
            ),

          TextFormField(
            controller: pickDayController.programController,
            decoration: new InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blueGrey, //Color(0xFF1976D2),
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.blueGrey,
                    //Color(0xFF06ac51),
                    width: 1.0),
              ),
              labelText: "Select Program",
            ),
            readOnly: true,
            style: TextStyle(fontSize: 30),
            onTap: () async {
              await pickDayController.pickProgram(context);
              setState(() {});
            },
          ),
          SizedBox(height: 6),
          Consumer<PickDay>(builder: (context, pickDay, child) {
            return Visibility(
              visible: pickDay.pickedProgram.type == "5/3/1" &&
                  pickDayController.tmController.text != null &&
                  pickDayController.tmController.text.length != 0,
              child: TextFormField(
                controller: pickDayController.tmController,
                onChanged: (newValue) {
                  pickDay.pickedProgram.trainingMaxPct =
                      double.parse(pickDayController.tmController.text);
                },
                keyboardType: TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                //validator: numberValidator,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
                decoration: new InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey, //Color(0xFF1976D2),
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blueGrey,
                        //Color(0xFF06ac51),
                        width: 1.0),
                  ),
                  labelText: "Override TM% (optional)",
                ),
                //onChanged: (value) => ,
                readOnly: false,
                style: TextStyle(fontSize: 15),
              ),
            );
          }),
          SizedBox(height: 10),

          //),
          //SizedBox(height: 10),
          //Expanded(
          //flex: 1,
          //child:
          RaisedButton(
            child: Text("Go!", style: TextStyle(fontSize: 50)),
            onPressed: !pickDayController.readyToGo
                ? null
                : () => pickDayController.launchDay(context),
            disabledColor: Theme.of(context).canvasColor,
            color: Theme.of(context).backgroundColor,
            //)
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
