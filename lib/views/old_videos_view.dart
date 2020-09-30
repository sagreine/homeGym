import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/scaled_tile.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:transparent_image/transparent_image.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';

class OldVideosView extends StatefulWidget {
  @override
  OldVideosViewState createState() => OldVideosViewState();
}

class OldVideosViewState extends State<OldVideosView> {
  //SettingsController settingsController = SettingsController();
  // should these go in the Settingscontroller probably then...
  List<ExerciseSet> _videos = <ExerciseSet>[];

  @override
  void dispose() {
    // TODO: implement dispose for controllers
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    FirebaseProvider.listenToVideos((newVideos) {
      setState(() {
        _videos = newVideos;
      });
    });
  }

  _getListView() {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _videos.length,
        itemBuilder: (BuildContext context, int index) {
          final video = _videos[index];
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
                child: Stack(
                  children: <Widget>[
                    Row(
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
                        Expanded(
                          child: Container(
                            margin: new EdgeInsets.only(left: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text("${video.title}"),
                                Text("${video.reps}x${video.weight}"),
                                Container(
                                  margin: new EdgeInsets.only(top: 12.0),
                                  child:
                                      Text('${timeago.format(video.dateTime)}'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<List<ExerciseSet>> _getALlPosts(String text) async {
    await Future.delayed(Duration(seconds: text.length == 4 ? 10 : 1));
    //if (isReplay) return [Post("Replaying !", "Replaying body")];
    //if (text.length == 5) throw Error();
    //if (text.length == 6) return [];
    //List<Post> posts = [];

    //var random = new Random();
    /*for (int i = 0; i < 10; i++) {
      posts.add(Post("$text $i", "body random number : "));
    }*/

    var abc = _videos
        .where((element) => element.title.toUpperCase() == text.toUpperCase())
        .toList();

    return abc;
  }

  SearchBarController _searchBarController = SearchBarController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(),
      drawer: ReusableWidgets.getDrawer(context),
      body: Column(
        children: [
          //ListView(
          //children: [
          Container(
            height: MediaQuery.of(context).size.height - kToolbarHeight - 50,
            child:
                //child:
                SearchBar(
              searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
              headerPadding: EdgeInsets.symmetric(horizontal: 10),
              listPadding: EdgeInsets.symmetric(horizontal: 10),
              onSearch: _getALlPosts,
              searchBarController: _searchBarController,
              placeHolder: //Container(
                  //height: 500,
                  //child:
                  Container(
                height:
                    MediaQuery.of(context).size.height - kToolbarHeight - 50,
                child: _getListView(),
              ),
              // ), //Text("placeholder"),
              cancellationWidget: Text("Cancel"),
              emptyWidget: Text("empty"),
              indexedScaledTileBuilder: (int index) =>
                  ScaledTile.count(1, index.isEven ? 2 : 1),
              header: Row(
                children: <Widget>[
                  /*RaisedButton(
                    child: Text("sort"),
                    onPressed: () {
                      _searchBarController.sortList((Post a, Post b) {
                        return a.body.compareTo(b.body);
                      });
                    },
                  ),*/
                  /*RaisedButton(
                    child: Text("Desort"),
                    onPressed: () {
                      _searchBarController.removeSort();
                    },
                  ),*/
                  /*RaisedButton(
                    child: Text("Replay"),
                    onPressed: () {
                      isReplay = !isReplay;
                      _searchBarController.replayLastSearch();
                    },
                  ),*/
                ],
              ),
              onCancelled: () {
                print("Cancelled triggered");
              },
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              crossAxisCount: 2,
              onItemFound: (post, int index) {
                return (Container());
                /*return Container(
                  color: Colors.lightBlue,
                  child: ListTile(
                    title: Text(post.title),
                    isThreeLine: true,
                    subtitle: Text(post.body),
                    onTap: () {
                      //Navigator.of(context).push(
                          //MaterialPageRoute(builder: (context) => Detail()));
                    },
                  ),
                );*/
              },
            ),
          ),
          //),
        ],
      ),
      //],
      //)
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

class FirebaseProvider {
  static var userID = "4DchyEpIYyMAlgSOdiWuQycCqeC2";

  static listenToVideos(callback) async {
    FirebaseFirestore.instance
        .collection('/USERDATA/$userID/LIFTS')
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
}

class Post {
  final String title;
  final String body;

  Post(this.title, this.body);
}
