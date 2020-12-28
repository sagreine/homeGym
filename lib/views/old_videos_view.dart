import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:home_gym/models/models.dart';
import 'package:home_gym/views/views.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:transparent_image/transparent_image.dart';
import 'package:social_share_plugin/social_share_plugin.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class OldVideosView extends StatefulWidget {
  @override
  OldVideosViewState createState() => OldVideosViewState();
}

class OldVideosViewState extends State<OldVideosView> {
  List<ExerciseSet> _videos; // = ;
  var scrollController = ScrollController();
  var _streamController = StreamController<List<ExerciseSet>>.broadcast();
  QuerySnapshot collectionState;
  bool _isRequesting = false;
  String userId;
  var numDocumentsToPaginateNext = 5;
  bool gottenLastDocument = false;
  String search = "";
  bool getDocsInStreamBuilder;
  final SearchBarController<ExerciseSet> _searchBarController =
      SearchBarController();

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    //_streamController.close();
  }

  // listen to newly added items - this might be stupid because of where it puts it in the array...
  void onChangeData(List<DocumentChange> documentChanges) {
    documentChanges.forEach((productChange) {
      if (productChange.type == DocumentChangeType.added) {
        // check if we have already pulled this video -- hmmm shure should define equality in the model eh
        var temp = List<String>.from(productChange.doc.data()['keywords']);
        // if this is not a search, add it. otherwise, if it is a search and the item is one of our desired search results,
        // it is not yet ineligible to add
        bool searchCheck = search == "" || temp.contains(search);

        int indexWhere = _videos.indexWhere((video) {
          return (productChange.doc.data()['title'] == video.title &&
              productChange.doc.data()['reps'] == video.reps &&
              productChange.doc.data()['weight'] == video.weight &&
              DateTime.parse(productChange.doc.data()['dateTime']) ==
                  video.dateTime);
        });
        // if we haven't, add it to the list at the start so it shows up on top unless this is a search result and this item
        // does not match our search criteria
        if (indexWhere == -1 && searchCheck) {
          _videos.insert(
              0,
              ExerciseSet(
                videoPath: productChange.doc.data()['videoPath'],
                thumbnailPath: productChange.doc.data()['thumbnailPath'],
                aspectRatio: productChange.doc.data()['aspectRatio'],
                title: productChange.doc.data()['title'],
                reps: productChange.doc.data()['reps'],
                weight: productChange.doc.data()['weight'],
                dateTime:
                    DateTime.parse(productChange.doc.data()['dateTime']) ??
                        DateTime.now(),
              ));
          _streamController.add(_videos);
          // below lets us do "streaming" to search results
          if (search != "") {
            _searchBarController.replayLastSearch();
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // set up the non-search scroll listner to paginate
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels == 0)
          print('ListView scroll at top');
        else {
          print('ListView scroll at bottom');
          getDocumentsNext(context, search).then((value) {
            // Load next documents
            setState(() {});
          });
        }
      }
    });
  }

  Container _shareBox(ExerciseSet video) {
    return Container(
      width: 260,
      height: video.videoPath == null ? 68 : 150,
      margin: new EdgeInsets.only(left: 20.0),
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(children: <Widget>[
              Text(
                "${video.title}",
                textScaleFactor: 1.2,
              ),
              // sometimes the weight is 0, so just put " reps" in for that case
              Text(
                "${video.reps}" +
                    (video.weight != 0
                        ? "x" + video.weight.toString()
                        : " reps"),
                textScaleFactor: 1.2,
              ),
              Container(
                child: Text(
                  '${timeago.format(video.dateTime)}',
                  textScaleFactor: 1.2,
                ),
              ),
            ]),
            Column(
              children: [
                Text(
                  "Share this lift!",
                  textScaleFactor: 1.2,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Image.asset("assets/images/Twitter_Logo_Blue.png"),
                      onPressed: () async {
                        // TODO: this plugin, or Twitter? breaks the link. it parses the '%' sigsn i think and that breaks everything...
                        // but in any event the links aren't public and you don't upload vidoes to twitter. could have a public bucket
                        // we movfe things to or someting i guess...
                        await SocialSharePlugin.shareToTwitterLink(
                            text:
                                "${Quotes().getQuote(greatnessQuote: true)}. ${video.title}, ${video.reps}" +
                                    (video.weight != 0
                                        ? "x" + video.weight.toString()
                                        : " reps") +
                                    " @HomeGymTV",
                            url: ""); //video.videoPath ?? "");
                      },
                    ),
                    // TODO need to limit to videos < 60 seconds long for instagram's requirements.
                    // only let them share on instagram if there is a video - can't pass a quote so no value in it
                    // TODO: if you later can pass a quote, consider posting the logo from assets + quote.
                    video.videoPath != null
                        ? IconButton(
                            icon:
                                Image.asset("assets/images/Instagram_Logo.png"),
                            onPressed: () async {
                              if (video.videoPath != null) {
                                final saveDir =
                                    (await getExternalStorageDirectory()).path;

                                await FlutterDownloader.enqueue(
                                  url: video.videoPath,
                                  savedDir: saveDir,
                                  fileName: "tempVideo.mp4",
                                  showNotification: false,
                                  openFileFromNotification: false,
                                );
                                await FlutterDownloader.loadTasks();
                                await SocialSharePlugin.shareToFeedInstagram(
                                    type: 'video',
                                    path: "$saveDir/tempVideo.mp4");
                              }
                            })
                        : Container(),
                  ],
                ),
              ],
            ),
          ]),
    );
  }

  _buildListItem(ExerciseSet video) {
    if (video.videoPath == null) {
      return Card(
          child: new Container(
              padding: new EdgeInsets.all(10.0),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 80,
                    ),
                    _shareBox(video),
                  ])));
    } else {
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
                      width: 80,
                      height: 150,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    Container(
                      width: 80,
                      height: 150,
                      child: ClipRRect(
                        borderRadius: new BorderRadius.circular(8.0),
                        child: FadeInImage.memoryNetwork(
                            fit: BoxFit.cover,
                            placeholder: kTransparentImage,
                            image: video.thumbnailPath ??
                                "https://imgur.com/gallery/5PKoKz7"),
                      ),
                    ),
                  ],
                ),
                _shareBox(video),
              ],
            ),
          ),
        ),
      );
    }
  }

  StreamBuilder<List<ExerciseSet>> _getStreamBuilder() {
    return StreamBuilder<List<ExerciseSet>>(
        stream: _streamController.stream,
        builder:
            (BuildContext context, AsyncSnapshot<List<ExerciseSet>> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              // on initializing the page OR after clearing a search, go get starter documents for this streambuilder to build with
              if (getDocsInStreamBuilder ?? true) {
                getDocsInStreamBuilder = false;
                // clear this to be sure here (if they delete, not cancel, out of search)
                search = "";
                getDocuments(context, "");
                print("get documents from streambuilder");
              }
              return new Text('Loading...');
            default:
              return ListView.builder(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return _buildListItem(_videos[index]);
                  });
          }
        });
  }

  Future<List<ExerciseSet>> getDocuments(BuildContext context, String search,
      {bool firstLoad}) async {
    // this is a refresh of sorts, so clear our our cache of videos and that we've gotten all videos.
    _videos = <ExerciseSet>[];
    gottenLastDocument = false;
    // go get a 15 sample, most recent first
    var userId = (Provider.of<Muser>(context, listen: false)).fAuthUser.uid;
    var collection = FirebaseFirestore.instance
        .collection('/USERDATA/$userId/LIFTS')
        .where('keywords', arrayContains: search.toLowerCase())
        .orderBy("dateTime", descending: true)
        .limit(numDocumentsToPaginateNext + 10);
    print('getDocuments');

    await fetchDocuments(collection);
    // then, listen but only to the latest change (addition, we'll define it in the function) - they'll unlikely to add more than 1 at a time
    FirebaseFirestore.instance
        .collection('/USERDATA/$userId/LIFTS')
        .where('keywords', arrayContains: search.toLowerCase())
        .orderBy("dateTime", descending: true)
        .limit(1)
        .snapshots()
        .listen((data) => onChangeData(data.docChanges));
    _streamController.add(_videos);
    // this line may not actually be necessary since we're using a global..
    return _videos;
  }

  // get the next page
  Future<void> getDocumentsNext(BuildContext context, String search) async {
    if (_isRequesting == false && gottenLastDocument == false) {
      _isRequesting = true;
      // Get the last pulled document and go from there
      var userId = (Provider.of<Muser>(context, listen: false)).fAuthUser.uid;
      var lastVisible = collectionState.docs[collectionState.docs.length - 1];
      print('listDocument legnth: ${collectionState.size} last: $lastVisible');
      var collection = FirebaseFirestore.instance
          .collection('/USERDATA/$userId/LIFTS')
          .where('keywords', arrayContains: search.toLowerCase())
          .orderBy("dateTime", descending: true)
          .startAfterDocument(lastVisible)
          .limit(numDocumentsToPaginateNext);

      await fetchDocuments(collection);
      _streamController.add(_videos);
      _isRequesting = false;
    }
  }

  fetchDocuments(Query collection) async {
    await collection.get().then((value) {
      collectionState =
          value; // store collection state to set where to start next
      value.docs.forEach((element) {
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
      // if we have gotten the last document, say so, in order to not just query indefinitely.
      gottenLastDocument = value.docs.length < numDocumentsToPaginateNext;
    });
  }

  // TODO: make this search by anything instead of just title? or even e.g. "TITLE:Squat"
  // TODO: may yet be
  Future<List<ExerciseSet>> _getSearchResults(String text) async {
    getDocsInStreamBuilder = true;
    // if search is null, we'll go get documents - might be ablet o get rid of this
    if (text == "") {
      search = text;
      await getDocuments(context, text);
      setState(() {});
      return _videos;
    }
    // if ths is the same search term, don't do anything.
    else if (search == text) {
    }
    // if this is a new term, we need to repull initial values. this definitely needs to be here
    else {
      search = text;
      await getDocuments(context, text);
    }
    // might be able to put this in the conditional block above
    setState(() {});
    return _videos;
  }

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
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // if we're searching and have hit the bottom index.
                  if (search != "") {
                    if (notification.metrics.atEdge) {
                      if (notification.metrics.pixels != 0) {
                        var temp = _videos.length;
                        print(
                            "number of search results before getting next page: ${_videos.length}");
                        getDocumentsNext(context, search).then((value) {
                          print(
                              "number of search results after getting next page: ${_videos.length}");
                          if (temp != _videos.length) {
                            // we've updated the source we're pulling from, so the same search will give more data
                            _searchBarController.replayLastSearch();
                          }
                        });
                      }
                    }
                  }
                  return true;
                },
                child: SearchBar<ExerciseSet>(
                  searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
                  headerPadding: EdgeInsets.symmetric(horizontal: 10),
                  listPadding: EdgeInsets.symmetric(horizontal: 10),
                  onSearch: _getSearchResults,
                  searchBarController: _searchBarController,
                  minimumChars: 1,
                  placeHolder: _getStreamBuilder(),
                  cancellationWidget: Text("Cancel"),
                  emptyWidget: Text("None"),
                  // could put buttons here and _searchBarController.filter or otherwise modify the search field....
                  header: Row(
                    children: <Widget>[],
                  ),
                  onCancelled: () async {
                    search = "";
                    getDocsInStreamBuilder = true;
                  },
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  onItemFound: (exercise, int index) {
                    return _buildListItem(exercise);
                  },
                ),
              )),
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
