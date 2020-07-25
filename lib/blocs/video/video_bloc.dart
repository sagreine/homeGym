/*
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:home_gym/models/models.dart';
//import 'package:camera/camera.dart';
import 'package:home_gym/widgets/widgets.dart';

part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  VideoBloc() : super(VideoInitial());

  Video video;

  @override
  VideoState get initialState => VideoRecordingInProgress();

  @override
  Stream<VideoState> mapEventToState(
    VideoEvent event,
  ) async* {
    // TODO: implement mapEventToState
    if (event is VideoRecordStart) {
      yield* _mapVideoRecordStartToState();
    } else if (event is VideoRecordSuccess) {
      yield* _mapVideoRecordCompleteToState();
    }
  }

  Stream<VideoState> _mapVideoRecordCompleteToState() async* {
    try {
      //final todos = await this.todosRepository.loadTodos();

      yield VideoRecordComplete(
        //todos.map(Video.fromEntity).toList(),
        video,
      );
    } catch (_) {
      yield VideoRecordFailure();
    }
  }

  Stream<VideoState> _mapVideoRecordStartToState() async* {
    try {
      //final todos = await this.todosRepository.loadTodos();
      WidgetsFlutterBinding.ensureInitialized();
      List<CameraDescription> cameras = await availableCameras();

      CameraExampleHome camera = CameraExampleHome(
        cameras,
      ); 

      yield VideoRecordingInProgress(
          //todos.map(todo.fromEntity).toList(),
          camera,
          );
    } catch (_) {
      yield VideoRecordFailure();
    }
  }
}
*/
