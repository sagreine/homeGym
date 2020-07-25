/*
part of 'video_bloc.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object> get props => [];
}

class VideoRecordStart extends VideoEvent {
  const VideoRecordStart();
  @override
  List<Object> get props => [];
  @override
  String toString() => "VideoRecordStarted";
}

class VideoRecordSuccess extends VideoEvent {
  final Video video;
  const VideoRecordSuccess(this.video);
  @override
  List<Object> get props => [video];
  @override
  String toString() => "VideoRecordSuccess {video: $video}";
}

class VideoRecordCanceled extends VideoEvent {}
*/
