import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:transparent_image/transparent_image.dart';
//import 'package:instagram_share/instagram_share.dart';
import 'package:social_share_plugin/social_share_plugin.dart';
//import 'package:http/http.dart' as http;
import 'package:flutter_downloader/flutter_downloader.dart';

class OldVideosView extends StatefulWidget {
  @override
  OldVideosViewState createState() => OldVideosViewState();
}

class OldVideosViewState extends State<OldVideosView> {
  List<ExerciseSet> _videos; // = ;
  var scrollController = ScrollController();
  QuerySnapshot collectionState;

  @override
  void dispose() {
    // TODO: implement dispose for controllers
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _videos = <ExerciseSet>[];
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels == 0)
          print('ListView scroll at top');
        else {
          print('ListView scroll at bottom');
          getDocumentsNext(context); // Load next documents
        }
      }
    });
  }

  _buildListItem(ExerciseSet video) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Player(
                video: video,
              );
            },
          ),
        );
      },
      child: Card(
        child: new Container(
          padding: new EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  //BoxDecoration(image:
                  Container(
                    width: 100,
                    height: 150,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(8.0),
                      child: FadeInImage.memoryNetwork(
                          fit: BoxFit.cover,
                          //height: 360,
                          //width: 360,
                          placeholder: kTransparentImage,
                          image: video.thumbnailPath ??
                              ////NetworkImage(
                              "https://imgur.com/gallery/5PKoKz7" //),
                          ),
                    ),
                  ),
                ],
              ),
              //Expanded(
              //child:
              Container(
                width: 100,
                height: 150,
                margin: new EdgeInsets.only(left: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("${video.title}"),
                    // sometimes the weight is 0, so just put " reps" in for that case
                    Text("${video.reps}" +
                        (video.weight != 0
                            ? "x" + video.weight.toString()
                            : " reps")),
                    Container(
                      margin: new EdgeInsets.only(top: 12.0),
                      child: Text('${timeago.format(video.dateTime)}'),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text("Share this lift!"),
                    Row(
                      children: [
                        /*RaisedButton(
                      child: Text("check form"),
                      onPressed: () {
                        Navigator.pushNamed(context, "/form_check");
                      },
                    ),*/
                        IconButton(
                          //child: Text('Share to Twitter'),
                          icon: Image.asset(
                              "assets/images/Twitter_Logo_Blue.png"),
                          onPressed: () async {
                            //_shareFile();
                            //File file = await ImagePicker.pickImage(source: ImageSource.gallery);
                            //File file = File(video.thumbnailPath);
/*
                        // generate random number.
                        var rng = new Random();
// get temporary directory of device.
                        Directory tempDir = await getTemporaryDirectory();
// get temporary path from temporary directory.
                        String tempPath = tempDir.path;
// create a new file in temporary path with random file name.
                        File file = new File('$tempPath' +
                            '/' +
                            (rng.nextInt(100)).toString() +
                            '.png');
// call http.get method and pass imageUrl into it to get response.
                        var response = await http.get(video.thumbnailPath);
// write bodyBytes received in response to file.
                        await file.writeAsBytes(response.bodyBytes);
// now return the file which is created with random name in
// temporary directory and image bytes from response is written to // that file.
                        //return file;*/

                            //Uri photoURI = FileProvider.getUriForFile(this,
                            //"com.example.navigationdrawerfinal.fileprovider", // Over here
                            //photoFile);

                            /*FileProvider.getUriForFile(Objects.requireNonNull(getApplicationContext()),
                    BuildConfig.APPLICATION_ID + ".provider", file);*/

                            /*await SocialSharePlugin.shareToFeedInstagram(
                            path:
                                //"com.example.home_gym.social.share.fileprovider.provider" +
                                file.path);*/

                            // TODO: this plugin, or Twitter? breaks the link. it parses the '%' sigsn i think and that breaks everything...
                            // but in any event the links aren't public and you don't upload vidoes to flutter. could have a public bucket
                            // we movfe things to or someting i guess...
                            await SocialSharePlugin.shareToTwitterLink(
                                text:
                                    "${Quotes().getQuote(greatnessQuote: true)} ${video.title}, ${video.reps}" +
                                        (video.weight != 0
                                            ? "x" + video.weight.toString()
                                            : " reps") +
                                        " @HomeGymTV",
                                //url: ""
                                url: video.videoPath);
                          },
                        ),
                        // TODO need to limit to videos < 60 seconds long for instagram's requirements.
                        IconButton(
                            icon:
                                Image.asset("assets/images/Instagram_Logo.png"),
                            onPressed: () async {
                              /*final saveDir =
                                  (await getApplicationDocumentsDirectory())
                                      .absolute
                                      .path;*/

                              final saveDir =
                                  (await getExternalStorageDirectory())
                                      .path; //from path_provide package

                              //final taskId =
                              await FlutterDownloader.enqueue(
                                url: video.videoPath,
                                savedDir: saveDir,
                                fileName: "tempVideo.mp4",
                                showNotification:
                                    false, // show download progress in status bar (for Android)
                                openFileFromNotification:
                                    false, // click on notification to open downloaded file (for Android)
                              );
                              await FlutterDownloader.loadTasks();
                              /*final directory =
                                  (await getApplicationDocumentsDirectory())
                                      .path;
                              List files = Directory("$directory").listSync();*/
                              /*await InstagramShare.share(
                                  "$saveDir/tempVideo.mp4", 'video');*/

                              await SocialSharePlugin.shareToFeedInstagram(
                                  type: 'video',
                                  path: "$saveDir/tempVideo.mp4");
                            }),
                      ],
                    ),
                  ],
                ),
              ),
              //),
            ],
          ),
        ),
      ),
    );
  }

  _getListView(List<ExerciseSet> _videos) {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      controller: scrollController,
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        return _buildListItem(_videos[index]);
      },
    );
  }

  _getFutureBuilder(BuildContext context1 /*List<ExerciseSet> videos*/) {
    return FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [CircularProgressIndicator()]);
          } else {
            return _getListView(snapshot.data);
          }
        },
        future: getDocuments(context1));
  }

  // TODO: use https://stackoverflow.com/questions/59191492/flutter-firestore-pagination-using-streambuilder
  // to get newly submitted videos included as they come in too...

  // TODO: to actually let them search, and do pagination,
  // https://firebase.google.com/docs/firestore/solutions/search - agolia or elasticsearch ($$$)

  // TODO: this combines our current approach with better search, try this next:
  // https://medium.com/@ken11zer01/firebase-firestore-text-search-and-pagination-91a0df8131ef

  Future<List<ExerciseSet>> getDocuments(BuildContext context) async {
    // this is a mess but.... kick off future builder if this is the first build. otherwise, just return the list
    // note that this precludes us from getting updates (things that are being written right now, e.g. video we just took)
    if (_videos == null || _videos.length == 0) {
      var userId = (Provider.of<Muser>(context, listen: false)).fAuthUser.uid;
      // where and order by have to be same field in firestore. we value order by higher but we risk not returning any/enough if we don't filter first
      // so filter, then order results? but that's super stupid, because we might have to fetch tons and tons and reorder every time
      // but could handle that via a refresh indicator or something...

      var collection = FirebaseFirestore.instance
          .collection('/USERDATA/$userId/LIFTS')
          .orderBy("dateTime", descending: true)
          .limit(25);
      print('getDocuments');

      await fetchDocuments(collection);
    }
    return _videos;
    //setState(() {});
  }

  Future<void> getDocumentsNext(BuildContext context) async {
    // Get the last pulled document and go from there
    var userId = (Provider.of<Muser>(context, listen: false)).fAuthUser.uid;
    var lastVisible = collectionState.docs[collectionState.docs.length - 1];
    print('listDocument legnth: ${collectionState.size} last: $lastVisible');
    var collection = FirebaseFirestore.instance
        .collection('/USERDATA/$userId/LIFTS')
        .orderBy("dateTime", descending: true)
        .startAfterDocument(lastVisible)
        .limit(20);

    fetchDocuments(collection);
    setState(() {});
  }

  fetchDocuments(Query collection) async {
    await collection.get().then((value) {
      collectionState =
          value; // store collection state to set where to start next
      value.docs
          // only uploads that have videos can have their videos searched :)
          .where((element) => element.data()["videoPath"] != null)
          .forEach((element) {
        _videos.add(ExerciseSet(
          videoPath: element.data()['videoPath'],
          thumbnailPath: element.data()['thumbnailPath'],
          aspectRatio: element.data()['aspectRatio'],
          title: element.data()['title'],
          reps: element.data()['reps'],
          weight: element.data()['weight'],
          dateTime:
              DateTime.parse(element.data()['dateTime']) ?? DateTime.now(),
        ));
      });
    });
  }

  // TODO: make this search by anything instead of just title? or even e.g. "TITLE:Squat"
  Future<List<ExerciseSet>> _getSearchResults(String text) async {
    List<ExerciseSet> searchResults = _videos
        .where((element) =>
            element.title.toUpperCase().contains(text.toUpperCase()))
        .toList();

    return searchResults;
  }

  final SearchBarController<ExerciseSet> _searchBarController =
      SearchBarController();
  //final SearchBarController<Post> _searchBarController = SearchBarController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(),
      drawer: ReusableWidgets.getDrawer(context),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: FlexFit.loose,
            // this is crazy misleading though, beacuse it only searches what you have locally. so you'd need
            // to continually repull to get more...
            child: SearchBar<ExerciseSet>(
              searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
              headerPadding: EdgeInsets.symmetric(horizontal: 10),
              listPadding: EdgeInsets.symmetric(horizontal: 10),
              onSearch: _getSearchResults,
              searchBarController: _searchBarController,
              minimumChars: 1,

              placeHolder: _getFutureBuilder(context), //_getListView(_videos),

              cancellationWidget: Text("Cancel"),
              emptyWidget: Text("None"),
              // could put buttons here and _searchBarController.filter or otherwise modify the search field....
              header: Row(
                children: <Widget>[],
              ),
              onCancelled: () {
                print("Cancelled triggered");
              },
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              onItemFound: (exercise, int index) {
                return _buildListItem(exercise);
              },
            ),

            // could put this in a refresh indicator to re-start it though?
            //_getFutureBuilder(context)

            /*_videos?.length == 0 ?? null
                ? _getFutureBuilder(context)
                : _getListView(_videos), // this sucks because we lose scroll position and it is stupid in general*/
          ),
        ],
      ),
    );
  }
}

class Player extends StatefulWidget {
  final ExerciseSet video;

  const Player({Key key, this.video}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  String _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          _error == null
              ? NetworkPlayerLifeCycle(
                  widget.video.videoPath ??
                      "https://firebasestorage.googleapis.com/v0/b/sagrehomegym.appspot.com/o/animation_1.mkv?alt=media&token=95062198-8a3a-4cba-8de4-6fcb8cb0bf22",
                  (BuildContext context, VideoPlayerController controller) =>
                      AspectRatioVideo(controller),
                )
              : Center(
                  child: Text(_error),
                ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayPause extends StatefulWidget {
  VideoPlayPause(this.controller);

  final VideoPlayerController controller;

  @override
  State createState() {
    return _VideoPlayPauseState();
  }
}

class _VideoPlayPauseState extends State<VideoPlayPause> {
  _VideoPlayPauseState() {
    listener = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  FadeAnimation imageFadeAnim =
      FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
  VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
    controller.setVolume(1.0);
    controller.play();
  }

  @override
  void deactivate() {
    controller.setVolume(0.0);
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      GestureDetector(
        child: VideoPlayer(controller),
        onTap: () {
          if (!controller.value.initialized) {
            return;
          }
          if (controller.value.isPlaying) {
            imageFadeAnim =
                FadeAnimation(child: const Icon(Icons.pause, size: 100.0));
            controller.pause();
          } else {
            imageFadeAnim =
                FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
            controller.play();
          }
        },
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: VideoProgressIndicator(
          controller,
          allowScrubbing: true,
        ),
      ),
      Center(child: imageFadeAnim),
      Center(
          child: controller.value.isBuffering
              ? const CircularProgressIndicator()
              : null),
    ];

    return Stack(
      fit: StackFit.passthrough,
      children: children,
    );
  }
}

class FadeAnimation extends StatefulWidget {
  FadeAnimation(
      {this.child, this.duration = const Duration(milliseconds: 500)});

  final Widget child;
  final Duration duration;

  @override
  _FadeAnimationState createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: widget.duration, vsync: this);
    animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    animationController.forward(from: 0.0);
  }

  @override
  void deactivate() {
    animationController.stop();
    super.deactivate();
  }

  @override
  void didUpdateWidget(FadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    if (animationController != null) animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return animationController.isAnimating
        ? Opacity(
            opacity: 1.0 - animationController.value,
            child: widget.child,
          )
        : Container();
  }
}

typedef Widget VideoWidgetBuilder(
    BuildContext context, VideoPlayerController controller);

abstract class PlayerLifeCycle extends StatefulWidget {
  PlayerLifeCycle(this.dataSource, this.childBuilder);

  final VideoWidgetBuilder childBuilder;
  final String dataSource;
}

/// A widget connecting its life cycle to a [VideoPlayerController] using
/// a data source from the network.
class NetworkPlayerLifeCycle extends PlayerLifeCycle {
  NetworkPlayerLifeCycle(String dataSource, VideoWidgetBuilder childBuilder)
      : super(dataSource, childBuilder);

  @override
  _NetworkPlayerLifeCycleState createState() => _NetworkPlayerLifeCycleState();
}

abstract class _PlayerLifeCycleState extends State<PlayerLifeCycle> {
  VideoPlayerController controller;

  @override

  /// Subclasses should implement [createVideoPlayerController], which is used
  /// by this method.
  void initState() {
    super.initState();
    controller = createVideoPlayerController();
    controller.addListener(() {
      if (controller.value.hasError) {
        setState(() {});
      }
    });
    controller.initialize();
    controller.setLooping(true);
    controller.play();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    if (controller != null) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(context, controller);
  }

  VideoPlayerController createVideoPlayerController();
}

class _NetworkPlayerLifeCycleState extends _PlayerLifeCycleState {
  @override
  VideoPlayerController createVideoPlayerController() {
    return VideoPlayerController.network(widget.dataSource);
  }
}

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  VoidCallback listener;

  @override
  void initState() {
    super.initState();
    listener = () {
      if (!mounted) {
        return;
      }
      if (initialized != controller.value.initialized) {
        initialized = controller.value.initialized;
        if (mounted) {
          setState(() {});
        }
      }
    };
    controller.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    if (controller.value.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(controller.value.errorDescription,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
      );
    }

    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayPause(controller),
        ),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}

/*class FirebaseProvider {
  //static var userID = "4DchyEpIYyMAlgSOdiWuQycCqeC2";

  static listenToVideos(BuildContext context, callback) async {
    var userId = (Provider.of<Muser>(context, listen: false)).fAuthUser.uid;
    FirebaseFirestore.instance
        .collection('/USERDATA/$userId/LIFTS')
        .snapshots()
        .listen((qs) {
      // only uploads that have videos can have their videos searched :)
      final videos = mapQueryToVideoInfo(
          qs.docs.where((element) => element.data()["videoPath"] != null));
      callback(videos);
    });
  }

  static mapQueryToVideoInfo(Iterable<QueryDocumentSnapshot> qs) {
    return qs.map((DocumentSnapshot ds) {
      if (ds.data()["videoPath"] != null)
        return ExerciseSet(
          videoPath: ds.data()['videoPath'],
          thumbnailPath: ds.data()['thumbnailPath'],
          aspectRatio: ds.data()['aspectRatio'],
          title: ds.data()['title'],
          reps: ds.data()['reps'],
          weight: ds.data()['weight'],
          dateTime: DateTime.parse(ds.data()['dateTime']) ?? DateTime.now(),
        );
    }).toList();
  }
}*/
