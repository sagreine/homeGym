import 'dart:async';

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
  var _streamController = StreamController<List<ExerciseSet>>.broadcast();
  QuerySnapshot collectionState;
  bool _isRequesting = false;
  String userId;
  var numDocumentsToPaginateNext = 5;
  bool gottenLastDocument = false;
  String search = "";

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
        int indexWhere = _videos.indexWhere((video) {
          return (productChange.doc.data()['title'] == video.title &&
              productChange.doc.data()['reps'] == video.reps &&
              productChange.doc.data()['weight'] == video.weight &&
              DateTime.parse(productChange.doc.data()['dateTime']) ==
                  video.dateTime);
        });
        // if we haven't, add it to the list at the start so it shows up on top
        if (indexWhere == -1) {
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
        }
      }
    });
  }

  bool isLoaded = false;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) async {
      _videos = await getDocuments(context, search);
      setState(() {
        isLoaded = true;
      });
    });
    super.initState();
    //_videos = <ExerciseSet>[];
    userId = (Provider.of<Muser>(context, listen: false)).fAuthUser.uid;
    // grab the first several exercises
//    getDocuments(context, search);
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

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    // then, listen but only to the latest change or so - they'll unlikely to add more than 1 at a time
    /*FirebaseFirestore.instance
        .collection('/USERDATA/$userId/LIFTS')
        .orderBy("dateTime", descending: true)
        .limit(1)
        .snapshots()
        .listen((data) => onChangeData(data.docChanges));*/
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
                    // TODO: if you later can pass a quote, consider posting the homegymtv logo from assets + quote.
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

  /*_getListView(List<ExerciseSet> _videos) {
    return ListView.builder(
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      controller: scrollController,
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        return _buildListItem(_videos[index]);
      },
    );
  }*/

  StreamBuilder<List<ExerciseSet>> _getStreamBuilder() {
    //if (_videos == null || _videos?.length == 0 ?? null) {
//      getDocuments(context, search).then((value) {
    return StreamBuilder<List<ExerciseSet>>(
        stream: _streamController.stream,
        builder:
            (BuildContext context, AsyncSnapshot<List<ExerciseSet>> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              getDocuments(context, "");
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
    //});
  }
  //}

/*
  _getFutureBuilder(BuildContext context1) {
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
        future: getDocuments(context1, search));
  }
*/
  // TODO: use https://stackoverflow.com/questions/59191492/flutter-firestore-pagination-using-streambuilder
  // to get newly submitted videos included as they come in too...

  // TODO: to actually let them search, and do pagination,
  // https://firebase.google.com/docs/firestore/solutions/search - agolia or elasticsearch ($$$)

  // TODO: this combines our current approach with better search, try this next:
  // https://medium.com/@ken11zer01/firebase-firestore-text-search-and-pagination-91a0df8131ef

  Future<List<ExerciseSet>> getDocuments(
      BuildContext context, String search) async {
    _videos = <ExerciseSet>[];
    gottenLastDocument = false;
    //_streamController = StreamController<List<ExerciseSet>>.broadcast();
    // this is a mess but.... kick off future builder if this is the first build. otherwise, just return the list
    // note that this precludes us from getting updates (things that are being written right now, e.g. video we just took)
    //if (_videos == null || _videos.length == 0) {
    var userId = (Provider.of<Muser>(context, listen: false)).fAuthUser.uid;
    // where and order by have to be same field in firestore. we value order by higher but we risk not returning any/enough if we don't filter first
    // so filter, then order results? but that's super stupid, because we might have to fetch tons and tons and reorder every time
    // but could handle that via a refresh indicator or something...

    var collection = FirebaseFirestore.instance
        .collection('/USERDATA/$userId/LIFTS')
        .where('keywords', arrayContains: search.toLowerCase())
        .orderBy("dateTime", descending: true)
        .limit(numDocumentsToPaginateNext + 10);
    print('getDocuments');

    await fetchDocuments(collection);
    //}

    // then, listen but only to the latest change or so - they'll unlikely to add more than 1 at a time
    FirebaseFirestore.instance
        .collection('/USERDATA/$userId/LIFTS')
        .where('keywords', arrayContains: search.toLowerCase())
        .orderBy("dateTime", descending: true)
        .limit(1)
        .snapshots()
        .listen((data) => onChangeData(data.docChanges));
    // this line only for the stream controlloer, obviously. if using future, uncomment setState
    _streamController.add(_videos);
    return _videos;
    //setState(() {});
  }

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
      // this line only for the stream controlloer, obviously. if using future, uncomment setState
      _streamController.add(_videos);
      _isRequesting = false;
    }
    //setState(() {});
  }

  fetchDocuments(Query collection) async {
    await collection.get().then((value) {
      collectionState =
          value; // store collection state to set where to start next
      value.docs
          // only uploads that have videos can have their videos searched :)
          // will want to use this to know if we need to restart though,
          // check if documentSnapshots.size is = the limit and if it is, and we have no records to return, fire again
          //.where((element) => element.data()["videoPath"] != null)
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
      // if we have gotten the last document, say so, in order to not just query indefinitely.
      gottenLastDocument = value.docs.length < numDocumentsToPaginateNext;
    });
  }

  // TODO: make this search by anything instead of just title? or even e.g. "TITLE:Squat"
  //Future<List<ExerciseSet>>
  //Stream<List<ExerciseSet>>
  Future<List<ExerciseSet>> _getSearchResults(String text) async {
    // if this is already our search term and we're calling it again, that means we are here because we're re-adding
    if (text == "") {
      search = text;
      await getDocuments(context, text);
      setState(() {});
      return _videos;
    } else if (search == text) {
      //await getDocumentsNext(context, search);
    } else {
      search = text;
      await getDocuments(context, text);
    }
    //return
    //yield
    setState(() {});
    return _videos;
  }

  Future<List<ExerciseSet>> Function(String) _pickResults(
      List<ExerciseSet> videos) {
    /*if (_videos.length == 15) {
      setState(() {});
    }*/
    return _getSearchResults;
  }

  final SearchBarController<ExerciseSet> _searchBarController =
      SearchBarController();
  //var redrawObject;
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
                  //print("$notification");
                  //notification.metrics.maxScrollExtent
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
                            /*setState(() {
                              redrawObject = Object();
                            });*/
                            // we've updated the source we're pulling from, so the same search will give more data
                            _searchBarController.replayLastSearch();
                          }
                          /*setState(() {
                          print("added to the list");
                          print("${_videos.length}");
                        });*/
                        });
                      }
                    }
                  }
                  return true;
                },
                // this is crazy misleading though, beacuse it only searches what you have locally. so you'd need
                // to continually repull to get more...
                child: SearchBar<ExerciseSet>(
                  //key: ValueKey<Object>(redrawObject),
                  searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
                  headerPadding: EdgeInsets.symmetric(horizontal: 10),
                  listPadding: EdgeInsets.symmetric(horizontal: 10),
                  onSearch:
                      /*(_) {
                    setState(() {
                      
                    });
                    return _getSearchResults(_);
                    //_pickResults(_videos);
                  },*/
                      _getSearchResults,
                  searchBarController: _searchBarController,
                  minimumChars: 1,
                  //suggestions: _videos,
                  placeHolder: _getStreamBuilder(),
                  // _getFutureBuilder(context), //_getListView(_videos),
                  cancellationWidget: Text("Cancel"),
                  emptyWidget: Text("None"),
                  // could put buttons here and _searchBarController.filter or otherwise modify the search field....
                  header: Row(
                    children: <Widget>[],
                  ),
                  onCancelled: () async {
                    //_getStreamBuilder(context);
                    search = "";
                    await getDocuments(context, search);
                    print("Cancelled triggered");
                    print("${_videos.length}");
                  },
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  onItemFound: (exercise, int index) {
                    /*
                FirebaseFirestore.instance
                    .collection('/USERDATA/$userId/LIFTS')
                    .orderBy("dateTime", descending: true)
                    .limit(1)
                    .snapshots()
                    .listen((data) => onChangeData(data.docChanges));*/
                    return _buildListItem(exercise);

                    //  return _getStreamBuilder(context);
                  },
                ),
              )

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
